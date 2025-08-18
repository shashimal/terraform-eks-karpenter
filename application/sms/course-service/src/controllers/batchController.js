const Course = require('../models/Course');
const axios = require('axios');

// Batch enroll a student in multiple courses
exports.batchEnrollStudent = async (req, res) => {
    try {
        const { studentId, courseIds } = req.body;

        if (!studentId || !courseIds || !Array.isArray(courseIds)) {
            return res.status(400).json({ message: 'Invalid request data' });
        }

        const results = [];
        const errors = [];

        // Process each course enrollment
        for (const courseId of courseIds) {
            try {
                const course = await Course.findById(courseId);

                if (!course) {
                    errors.push({ courseId, message: 'Course not found' });
                    continue;
                }

                if (course.enrolledStudents >= course.capacity) {
                    errors.push({ courseId, message: 'Course is at full capacity' });
                    continue;
                }

                // Increment enrolled students count
                course.enrolledStudents += 1;
                await course.save();

                results.push({ courseId, status: 'success' });
            } catch (error) {
                errors.push({ courseId, message: error.message });
            }
        }

        res.status(200).json({
            studentId,
            results,
            errors,
            message: errors.length > 0 ? 'Some enrollments failed' : 'All enrollments successful'
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get enrollment status for multiple courses
exports.getEnrollmentStatus = async (req, res) => {
    try {
        const { courseIds } = req.query;

        if (!courseIds) {
            return res.status(400).json({ message: 'Course IDs are required' });
        }

        const ids = courseIds.split(',');
        const courses = await Course.find({ _id: { $in: ids } });

        const statuses = courses.map(course => ({
            courseId: course._id,
            title: course.title,
            code: course.code,
            enrolledStudents: course.enrolledStudents,
            capacity: course.capacity,
            isFull: course.enrolledStudents >= course.capacity
        }));

        res.status(200).json(statuses);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
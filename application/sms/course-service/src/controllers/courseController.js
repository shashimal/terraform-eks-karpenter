const Course = require('../models/Course');
const axios = require('axios');

// Get all courses
exports.getAllCourses = async (req, res) => {
    try {
        const courses = await Course.find();
        res.status(200).json(courses);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get a single course by ID
exports.getCourseById = async (req, res) => {
    try {
        const course = await Course.findById(req.params.id);
        if (!course) {
            return res.status(404).json({ message: 'Course not found' });
        }
        res.status(200).json(course);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Create a new course
exports.createCourse = async (req, res) => {
    try {
        const course = new Course(req.body);
        const newCourse = await course.save();
        res.status(201).json(newCourse);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Update a course
exports.updateCourse = async (req, res) => {
    try {
        const course = await Course.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );
        if (!course) {
            return res.status(404).json({ message: 'Course not found' });
        }
        res.status(200).json(course);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Delete a course
exports.deleteCourse = async (req, res) => {
    try {
        const course = await Course.findByIdAndDelete(req.params.id);
        if (!course) {
            return res.status(404).json({ message: 'Course not found' });
        }
        res.status(200).json({ message: 'Course deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Enroll a student in a course
exports.enrollStudent = async (req, res) => {
    try {
        const { studentId } = req.body;
        const course = await Course.findById(req.params.id);

        if (!course) {
            return res.status(404).json({ message: 'Course not found' });
        }

        if (course.enrolledStudents >= course.capacity) {
            return res.status(400).json({ message: 'Course is at full capacity' });
        }

        // Update the student record in the student service
        try {
            await axios.post(`http://student-service:3001/api/students/${studentId}/courses`, {
                courseId: course._id
            });

            // Increment enrolled students count
            course.enrolledStudents += 1;
            await course.save();

            res.status(200).json(course);
        } catch (error) {
            res.status(500).json({ message: 'Failed to update student record', error: error.message });
        }
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Unenroll a student from a course
exports.unenrollStudent = async (req, res) => {
    try {
        const { studentId } = req.body;
        const course = await Course.findById(req.params.id);

        if (!course) {
            return res.status(404).json({ message: 'Course not found' });
        }

        // Update the student record in the student service
        try {
            await axios.delete(`http://student-service:3001/api/students/${studentId}/courses`, {
                data: { courseId: course._id }
            });

            // Decrement enrolled students count if greater than 0
            if (course.enrolledStudents > 0) {
                course.enrolledStudents -= 1;
                await course.save();
            }

            res.status(200).json(course);
        } catch (error) {
            res.status(500).json({ message: 'Failed to update student record', error: error.message });
        }
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};
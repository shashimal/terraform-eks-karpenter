const Student = require('../models/Student');

// Get all students
exports.getAllStudents = async (req, res) => {
    try {
        const students = await Student.find();
        res.status(200).json(students);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get a single student by ID
exports.getStudentById = async (req, res) => {
    try {
        const student = await Student.findById(req.params.id);
        if (!student) {
            return res.status(404).json({ message: 'Student not found' });
        }
        res.status(200).json(student);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Create a new student
exports.createStudent = async (req, res) => {
    try {
        const { courses, ...studentData } = req.body;
        const student = new Student(studentData);

        // Save the student first to get an ID
        const newStudent = await student.save();

        // If courses are provided, assign them to the student
        if (courses && Array.isArray(courses) && courses.length > 0) {
            try {
                // Add courses to student
                newStudent.courses = courses;
                await newStudent.save();

                // Update course enrollment counts by calling the course service for each course
                const axios = require('axios');
                for (const courseId of courses) {
                    try {
                        await axios.post(`http://course-service:3002/api/courses/${courseId}/enroll`, {
                            studentId: newStudent._id
                        });
                    } catch (enrollError) {
                        console.error(`Error enrolling in course ${courseId}:`, enrollError);
                    }
                }
            } catch (courseError) {
                console.error('Error assigning courses:', courseError);
                // We don't want to fail the student creation if course assignment fails
            }
        }

        res.status(201).json(newStudent);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Update a student
exports.updateStudent = async (req, res) => {
    try {
        const { courses, ...studentData } = req.body;

        // Get the current student to compare courses
        const currentStudent = await Student.findById(req.params.id);
        if (!currentStudent) {
            return res.status(404).json({ message: 'Student not found' });
        }

        // Update basic student data
        const student = await Student.findByIdAndUpdate(
            req.params.id,
            studentData,
            { new: true, runValidators: true }
        );

        // Handle course updates if provided
        if (courses && Array.isArray(courses)) {
            const axios = require('axios');
            const currentCourses = currentStudent.courses.map(c => c.toString());

            // Find courses to add and remove
            const coursesToAdd = courses.filter(c => !currentCourses.includes(c));
            const coursesToRemove = currentCourses.filter(c => !courses.includes(c));

            // Update student's courses
            student.courses = courses;
            await student.save();

            // Update course enrollment counts
            if (coursesToAdd.length > 0) {
                try {
                    for (const courseId of coursesToAdd) {
                        try {
                            await axios.post(`http://course-service:3002/api/courses/${courseId}/enroll`, {
                                studentId: student._id
                            });
                        } catch (enrollError) {
                            console.error(`Error enrolling in course ${courseId}:`, enrollError);
                        }
                    }
                } catch (error) {
                    console.error('Error adding courses:', error);
                }
            }

            // Handle course removals
            for (const courseId of coursesToRemove) {
                try {
                    await axios.delete(`http://course-service:3002/api/courses/${courseId}/enroll`, {
                        data: { studentId: student._id }
                    });
                } catch (error) {
                    console.error(`Error removing course ${courseId}:`, error);
                }
            }
        }

        res.status(200).json(student);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Delete a student
exports.deleteStudent = async (req, res) => {
    try {
        const student = await Student.findByIdAndDelete(req.params.id);
        if (!student) {
            return res.status(404).json({ message: 'Student not found' });
        }
        res.status(200).json({ message: 'Student deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Add a course to a student
exports.addCourseToStudent = async (req, res) => {
    try {
        const { courseId } = req.body;
        const student = await Student.findById(req.params.id);

        if (!student) {
            return res.status(404).json({ message: 'Student not found' });
        }

        if (!student.courses.includes(courseId)) {
            student.courses.push(courseId);
            await student.save();
        }

        res.status(200).json(student);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Remove a course from a student
exports.removeCourseFromStudent = async (req, res) => {
    try {
        const { courseId } = req.body;
        const student = await Student.findById(req.params.id);

        if (!student) {
            return res.status(404).json({ message: 'Student not found' });
        }

        student.courses = student.courses.filter(course => course.toString() !== courseId);
        await student.save();

        res.status(200).json(student);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};
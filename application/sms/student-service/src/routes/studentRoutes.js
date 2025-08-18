const express = require('express');
const router = express.Router();
const studentController = require('../controllers/studentController');
const uploadController = require('../controllers/uploadController');
const upload = require('../middleware/upload');

// GET all students
router.get('/', studentController.getAllStudents);

// GET a single student
router.get('/:id', studentController.getStudentById);

// POST a new student
router.post('/', studentController.createStudent);

// PUT update a student
router.put('/:id', studentController.updateStudent);

// DELETE a student
router.delete('/:id', studentController.deleteStudent);

// POST add a course to a student
router.post('/:id/courses', studentController.addCourseToStudent);

// DELETE remove a course from a student
router.delete('/:id/courses', studentController.removeCourseFromStudent);

// POST upload profile picture
router.post('/:id/profile-picture', upload.single('profilePicture'), uploadController.uploadProfilePicture);

// GET profile picture
router.get('/:id/profile-picture', uploadController.getProfilePicture);

module.exports = router;
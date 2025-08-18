const express = require('express');
const router = express.Router();
const courseController = require('../controllers/courseController');

// GET all courses
router.get('/', courseController.getAllCourses);

// GET a single course
router.get('/:id', courseController.getCourseById);

// POST a new course
router.post('/', courseController.createCourse);

// PUT update a course
router.put('/:id', courseController.updateCourse);

// DELETE a course
router.delete('/:id', courseController.deleteCourse);

// POST enroll a student in a course
router.post('/:id/enroll', courseController.enrollStudent);

// DELETE unenroll a student from a course
router.delete('/:id/enroll', courseController.unenrollStudent);

module.exports = router;
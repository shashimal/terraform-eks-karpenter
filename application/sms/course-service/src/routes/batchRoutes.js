const express = require('express');
const router = express.Router();
const batchController = require('../controllers/batchController');

// POST batch enroll a student in multiple courses
router.post('/enroll', batchController.batchEnrollStudent);

// GET enrollment status for multiple courses
router.get('/enrollment-status', batchController.getEnrollmentStatus);

module.exports = router;
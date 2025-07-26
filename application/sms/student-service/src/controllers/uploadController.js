const Student = require('../models/Student');
const fs = require('fs');
const path = require('path');

// Upload profile picture
exports.uploadProfilePicture = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'No file uploaded' });
        }

        const studentId = req.params.id;
        const student = await Student.findById(studentId);

        if (!student) {
            // Delete the uploaded file if student doesn't exist
            fs.unlinkSync(req.file.path);
            return res.status(404).json({ message: 'Student not found' });
        }

        // If student already has a profile picture, delete the old one
        if (student.profilePicture) {
            const oldPicturePath = path.join(__dirname, '../../uploads', path.basename(student.profilePicture));
            if (fs.existsSync(oldPicturePath)) {
                fs.unlinkSync(oldPicturePath);
            }
        }

        // Update student with new profile picture URL
        const profilePictureUrl = `/uploads/${req.file.filename}`;
        student.profilePicture = profilePictureUrl;
        await student.save();

        res.status(200).json({
            message: 'Profile picture uploaded successfully',
            profilePicture: profilePictureUrl
        });
    } catch (error) {
        console.error('Error uploading profile picture:', error);
        res.status(500).json({ message: error.message });
    }
};

// Get profile picture
exports.getProfilePicture = async (req, res) => {
    try {
        const studentId = req.params.id;
        const student = await Student.findById(studentId);

        if (!student) {
            return res.status(404).json({ message: 'Student not found' });
        }

        if (!student.profilePicture) {
            return res.status(404).json({ message: 'No profile picture found' });
        }

        const picturePath = path.join(__dirname, '../../uploads', path.basename(student.profilePicture));

        if (!fs.existsSync(picturePath)) {
            return res.status(404).json({ message: 'Profile picture file not found' });
        }

        res.sendFile(picturePath);
    } catch (error) {
        console.error('Error getting profile picture:', error);
        res.status(500).json({ message: error.message });
    }
};
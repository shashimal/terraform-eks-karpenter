import axios from 'axios';

const API_URL = process.env.REACT_APP_STUDENT_API_URL || 'http://localhost:3001/api/students';

export const getAllStudents = async () => {
    try {
        const response = await axios.get(API_URL);
        return response.data;
    } catch (error) {
        console.error('Error fetching students:', error);
        throw error;
    }
};

export const getStudentById = async (id) => {
    try {
        const response = await axios.get(`${API_URL}/${id}`);
        return response.data;
    } catch (error) {
        console.error(`Error fetching student with id ${id}:`, error);
        throw error;
    }
};

export const createStudent = async (studentData) => {
    try {
        const response = await axios.post(API_URL, studentData);
        return response.data;
    } catch (error) {
        console.error('Error creating student:', error);
        throw error;
    }
};

export const updateStudent = async (id, studentData) => {
    try {
        const response = await axios.put(`${API_URL}/${id}`, studentData);
        return response.data;
    } catch (error) {
        console.error(`Error updating student with id ${id}:`, error);
        throw error;
    }
};

export const deleteStudent = async (id) => {
    try {
        const response = await axios.delete(`${API_URL}/${id}`);
        return response.data;
    } catch (error) {
        console.error(`Error deleting student with id ${id}:`, error);
        throw error;
    }
};

export const addCourseToStudent = async (studentId, courseId) => {
    try {
        const response = await axios.post(`${API_URL}/${studentId}/courses`, { courseId });
        return response.data;
    } catch (error) {
        console.error(`Error adding course to student:`, error);
        throw error;
    }
};

export const removeCourseFromStudent = async (studentId, courseId) => {
    try {
        const response = await axios.delete(`${API_URL}/${studentId}/courses`, {
            data: { courseId }
        });
        return response.data;
    } catch (error) {
        console.error(`Error removing course from student:`, error);
        throw error;
    }
};

export const uploadProfilePicture = async (studentId, file) => {
    try {
        const formData = new FormData();
        formData.append('profilePicture', file);

        const response = await axios.post(
            `${API_URL}/${studentId}/profile-picture`,
            formData,
            {
                headers: {
                    'Content-Type': 'multipart/form-data'
                }
            }
        );
        return response.data;
    } catch (error) {
        console.error(`Error uploading profile picture:`, error);
        throw error;
    }
};

export const getProfilePictureUrl = (studentId) => {
    return `${API_URL}/${studentId}/profile-picture`;
};
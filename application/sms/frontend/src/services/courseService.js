import axios from 'axios';

const API_URL = process.env.REACT_APP_COURSE_API_URL || 'http://localhost:3002/api/courses';

export const getAllCourses = async () => {
    try {
        const response = await axios.get(API_URL);
        return response.data;
    } catch (error) {
        console.error('Error fetching courses:', error);
        throw error;
    }
};

export const getCourseById = async (id) => {
    try {
        const response = await axios.get(`${API_URL}/${id}`);
        return response.data;
    } catch (error) {
        console.error(`Error fetching course with id ${id}:`, error);
        throw error;
    }
};

export const createCourse = async (courseData) => {
    try {
        const response = await axios.post(API_URL, courseData);
        return response.data;
    } catch (error) {
        console.error('Error creating course:', error);
        throw error;
    }
};

export const updateCourse = async (id, courseData) => {
    try {
        const response = await axios.put(`${API_URL}/${id}`, courseData);
        return response.data;
    } catch (error) {
        console.error(`Error updating course with id ${id}:`, error);
        throw error;
    }
};

export const deleteCourse = async (id) => {
    try {
        const response = await axios.delete(`${API_URL}/${id}`);
        return response.data;
    } catch (error) {
        console.error(`Error deleting course with id ${id}:`, error);
        throw error;
    }
};

export const enrollStudent = async (courseId, studentId) => {
    try {
        const response = await axios.post(`${API_URL}/${courseId}/enroll`, { studentId });
        return response.data;
    } catch (error) {
        console.error(`Error enrolling student in course:`, error);
        throw error;
    }
};

export const unenrollStudent = async (courseId, studentId) => {
    try {
        const response = await axios.delete(`${API_URL}/${courseId}/enroll`, {
            data: { studentId }
        });
        return response.data;
    } catch (error) {
        console.error(`Error unenrolling student from course:`, error);
        throw error;
    }
};
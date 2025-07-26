import axios from 'axios';

const API_URL = process.env.REACT_APP_AUTH_API_URL?.replace('/api/auth', '/api/users') || 'http://localhost:3003/api/users';

// Get all users (admin only)
export const getAllUsers = async () => {
    try {
        const response = await axios.get(API_URL);
        return response.data;
    } catch (error) {
        console.error('Error fetching users:', error);
        throw error;
    }
};

// Get a single user by ID (admin only)
export const getUserById = async (id) => {
    try {
        const response = await axios.get(`${API_URL}/${id}`);
        return response.data;
    } catch (error) {
        console.error(`Error fetching user with id ${id}:`, error);
        throw error;
    }
};

// Create a new user (admin only)
export const createUser = async (userData) => {
    try {
        const response = await axios.post(API_URL, userData);
        return response.data;
    } catch (error) {
        console.error('Error creating user:', error);
        throw error;
    }
};

// Update a user (admin only)
export const updateUser = async (id, userData) => {
    try {
        const response = await axios.put(`${API_URL}/${id}`, userData);
        return response.data;
    } catch (error) {
        console.error(`Error updating user with id ${id}:`, error);
        throw error;
    }
};

// Delete a user (admin only)
export const deleteUser = async (id) => {
    try {
        const response = await axios.delete(`${API_URL}/${id}`);
        return response.data;
    } catch (error) {
        console.error(`Error deleting user with id ${id}:`, error);
        throw error;
    }
};

// Toggle user status (admin only)
export const toggleUserStatus = async (id) => {
    try {
        const response = await axios.patch(`${API_URL}/${id}/toggle-status`);
        return response.data;
    } catch (error) {
        console.error(`Error toggling status for user with id ${id}:`, error);
        throw error;
    }
};
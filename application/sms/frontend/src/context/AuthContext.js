import React, { createContext, useState, useEffect, useContext } from 'react';
import {
    login as loginService,
    logout as logoutService,
    getCurrentUser,
    isAuthenticated as checkAuth,
    setupAuthInterceptor
} from '../services/authService';

// Create context
const AuthContext = createContext();

// Provider component
export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const [isAuthenticated, setIsAuthenticated] = useState(false);

    // Initialize auth state
    useEffect(() => {
        const initAuth = () => {
            const currentUser = getCurrentUser();
            const authenticated = checkAuth();

            setUser(currentUser);
            setIsAuthenticated(authenticated);
            setLoading(false);

            // Setup axios interceptors for authentication
            setupAuthInterceptor();
        };

        initAuth();
    }, []);

    // Login function
    const login = async (credentials) => {
        try {
            const response = await loginService(credentials);
            setUser(response.user);
            setIsAuthenticated(true);
            return response;
        } catch (error) {
            throw error;
        }
    };

    // Logout function
    const logout = () => {
        logoutService();
        setUser(null);
        setIsAuthenticated(false);
    };

    // Update user in context
    const updateUser = (userData) => {
        setUser(userData);
        localStorage.setItem('user', JSON.stringify(userData));
    };

    // Context value
    const value = {
        user,
        loading,
        isAuthenticated,
        login,
        logout,
        updateUser
    };

    return (
        <AuthContext.Provider value={value}>
            {children}
        </AuthContext.Provider>
    );
};

// Custom hook to use the auth context
export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};

export default AuthContext;
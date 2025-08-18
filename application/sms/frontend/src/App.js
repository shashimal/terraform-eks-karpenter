import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { Container } from 'react-bootstrap';
import AppNavbar from './components/Navbar';
import Home from './pages/Home';
import StudentList from './pages/StudentList';
import StudentDetail from './pages/StudentDetail';
import StudentForm from './pages/StudentForm';
import CourseList from './pages/CourseList';
import CourseDetail from './pages/CourseDetail';
import CourseForm from './pages/CourseForm';
import Login from './pages/Login';
import Register from './pages/Register';
import Profile from './pages/Profile';
import UserList from './pages/UserList';
import UserDetail from './pages/UserDetail';
import UserEdit from './pages/UserEdit';
import Unauthorized from './pages/Unauthorized';
import ProtectedRoute from './components/ProtectedRoute';
import { AuthProvider, useAuth } from './context/AuthContext';
import { setupAuthInterceptor } from './services/authService';
import './App.css';

// Initialize auth interceptor
setupAuthInterceptor();

function AppContent() {
    const { isAuthenticated } = useAuth();

    return (
        <div className="App">
            <AppNavbar />
            <Container className="py-4">
                <Routes>
                    {/* Public routes */}
                    <Route path="/login" element={!isAuthenticated ? <Login /> : <Navigate to="/" replace />} />
                    <Route path="/unauthorized" element={<Unauthorized />} />

                    {/* Protected routes - require authentication */}
                    <Route path="/" element={
                        <ProtectedRoute>
                            <Home />
                        </ProtectedRoute>
                    } />

                    <Route path="/profile" element={
                        <ProtectedRoute>
                            <Profile />
                        </ProtectedRoute>
                    } />

                    {/* Student routes */}
                    <Route path="/students" element={
                        <ProtectedRoute>
                            <StudentList />
                        </ProtectedRoute>
                    } />
                    <Route path="/students/:id" element={
                        <ProtectedRoute>
                            <StudentDetail />
                        </ProtectedRoute>
                    } />
                    <Route path="/students/new" element={
                        <ProtectedRoute>
                            <StudentForm />
                        </ProtectedRoute>
                    } />
                    <Route path="/students/edit/:id" element={
                        <ProtectedRoute>
                            <StudentForm />
                        </ProtectedRoute>
                    } />

                    {/* Course routes */}
                    <Route path="/courses" element={
                        <ProtectedRoute>
                            <CourseList />
                        </ProtectedRoute>
                    } />
                    <Route path="/courses/:id" element={
                        <ProtectedRoute>
                            <CourseDetail />
                        </ProtectedRoute>
                    } />
                    <Route path="/courses/new" element={
                        <ProtectedRoute>
                            <CourseForm />
                        </ProtectedRoute>
                    } />
                    <Route path="/courses/edit/:id" element={
                        <ProtectedRoute>
                            <CourseForm />
                        </ProtectedRoute>
                    } />

                    {/* Admin routes */}
                    <Route path="/users" element={
                        <ProtectedRoute requiredRole="admin">
                            <UserList />
                        </ProtectedRoute>
                    } />
                    <Route path="/users/new" element={
                        <ProtectedRoute requiredRole="admin">
                            <Register />
                        </ProtectedRoute>
                    } />
                    <Route path="/users/edit/:id" element={
                        <ProtectedRoute requiredRole="admin">
                            <UserEdit />
                        </ProtectedRoute>
                    } />
                    <Route path="/users/:id" element={
                        <ProtectedRoute requiredRole="admin">
                            <UserDetail />
                        </ProtectedRoute>
                    } />

                    {/* Catch all - redirect to home or login */}
                    <Route path="*" element={isAuthenticated ? <Navigate to="/" /> : <Navigate to="/login" />} />
                </Routes>
            </Container>
        </div>
    );
}

function App() {
    return (
        <Router>
            <AuthProvider>
                <AppContent />
            </AuthProvider>
        </Router>
    );
}

export default App;
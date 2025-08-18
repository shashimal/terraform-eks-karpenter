import React from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { Navbar, Nav, Container, NavDropdown } from 'react-bootstrap';
import { FaGraduationCap, FaBook, FaHome, FaUser, FaSignOutAlt, FaUsers, FaCog } from 'react-icons/fa';
import { useAuth } from '../context/AuthContext';

const AppNavbar = () => {
    const location = useLocation();
    const navigate = useNavigate();
    const { user, isAuthenticated, logout } = useAuth();

    const handleLogout = () => {
        logout();
        navigate('/login');
    };

    return (
        <Navbar bg="primary" variant="dark" expand="lg" sticky="top" className="mb-3">
            <Container>
                <Navbar.Brand as={Link} to="/">
                    <FaGraduationCap className="me-2" />
                    Student Management System
                </Navbar.Brand>
                <Navbar.Toggle aria-controls="basic-navbar-nav" />
                <Navbar.Collapse id="basic-navbar-nav">
                    {isAuthenticated && (
                        <Nav className="me-auto">
                            <Nav.Link
                                as={Link}
                                to="/"
                                active={location.pathname === '/'}
                            >
                                <FaHome className="me-1" /> Home
                            </Nav.Link>
                            <Nav.Link
                                as={Link}
                                to="/students"
                                active={location.pathname.includes('/students')}
                            >
                                <FaGraduationCap className="me-1" /> Students
                            </Nav.Link>
                            <Nav.Link
                                as={Link}
                                to="/courses"
                                active={location.pathname.includes('/courses')}
                            >
                                <FaBook className="me-1" /> Courses
                            </Nav.Link>
                            {user?.role === 'admin' && (
                                <Nav.Link
                                    as={Link}
                                    to="/users"
                                    active={location.pathname.includes('/users')}
                                >
                                    <FaUsers className="me-1" /> Users
                                </Nav.Link>
                            )}
                        </Nav>
                    )}

                    <Nav className="ms-auto">
                        {isAuthenticated ? (
                            <NavDropdown
                                title={
                                    <span>
                                        <FaUser className="me-1" />
                                        {user?.firstName} {user?.lastName}
                                    </span>
                                }
                                id="user-dropdown"
                                align="end"
                            >
                                <NavDropdown.Item as={Link} to="/profile">
                                    <FaCog className="me-2" /> Profile
                                </NavDropdown.Item>
                                <NavDropdown.Divider />
                                <NavDropdown.Item onClick={handleLogout}>
                                    <FaSignOutAlt className="me-2" /> Logout
                                </NavDropdown.Item>
                            </NavDropdown>
                        ) : (
                            <Nav.Link
                                as={Link}
                                to="/login"
                                active={location.pathname === '/login'}
                            >
                                Login
                            </Nav.Link>
                        )}
                    </Nav>
                </Navbar.Collapse>
            </Container>
        </Navbar>
    );
};

export default AppNavbar;
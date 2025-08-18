import React from 'react';
import { Link } from 'react-router-dom';
import { Row, Col, Card, Button, Container } from 'react-bootstrap';
import { FaGraduationCap, FaBook, FaUserPlus, FaBookOpen } from 'react-icons/fa';

const Home = () => {
    return (
        <Container>
            <Row className="mb-4">
                <Col>
                    <div className="text-center py-5">
                        <h1 className="display-4 fw-bold text-primary">Student Management System</h1>
                        <p className="lead text-muted">A comprehensive solution for managing students and courses</p>
                    </div>
                </Col>
            </Row>

            <Row className="mb-5">
                <Col md={6} className="mb-4">
                    <Card className="h-100 shadow-sm">
                        <Card.Body className="d-flex flex-column">
                            <div className="text-center mb-4">
                                <FaGraduationCap size={50} className="text-primary" />
                            </div>
                            <Card.Title className="text-center">Student Management</Card.Title>
                            <Card.Text>
                                Manage student information, track enrollment, and assign courses to students.
                                View detailed student profiles and their academic progress.
                            </Card.Text>
                            <div className="mt-auto pt-3 d-flex justify-content-between">
                                <Button as={Link} to="/students" variant="primary">
                                    <FaGraduationCap className="me-2" /> View Students
                                </Button>
                                <Button as={Link} to="/students/new" variant="outline-primary">
                                    <FaUserPlus className="me-2" /> Add Student
                                </Button>
                            </div>
                        </Card.Body>
                    </Card>
                </Col>

                <Col md={6} className="mb-4">
                    <Card className="h-100 shadow-sm">
                        <Card.Body className="d-flex flex-column">
                            <div className="text-center mb-4">
                                <FaBook size={50} className="text-primary" />
                            </div>
                            <Card.Title className="text-center">Course Management</Card.Title>
                            <Card.Text>
                                Create and manage courses, track enrollment capacity, and assign instructors.
                                Monitor course statistics and student participation.
                            </Card.Text>
                            <div className="mt-auto pt-3 d-flex justify-content-between">
                                <Button as={Link} to="/courses" variant="primary">
                                    <FaBook className="me-2" /> View Courses
                                </Button>
                                <Button as={Link} to="/courses/new" variant="outline-primary">
                                    <FaBookOpen className="me-2" /> Add Course
                                </Button>
                            </div>
                        </Card.Body>
                    </Card>
                </Col>
            </Row>

            <Row>
                <Col>
                    <Card className="bg-light">
                        <Card.Body>
                            <Card.Title>Quick Start Guide</Card.Title>
                            <ol>
                                <li>Add courses to the system</li>
                                <li>Register students and assign them to courses</li>
                                <li>Track enrollment and course capacity</li>
                                <li>Update student and course information as needed</li>
                            </ol>
                        </Card.Body>
                    </Card>
                </Col>
            </Row>
        </Container>
    );
};

export default Home;
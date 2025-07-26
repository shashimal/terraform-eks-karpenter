import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Table, Button, Card, Row, Col, Alert, Spinner, Badge, InputGroup, Form } from 'react-bootstrap';
import { FaPlus, FaEye, FaEdit, FaTrash, FaSearch, FaBook } from 'react-icons/fa';
import { toast } from 'react-toastify';
import { getAllCourses, deleteCourse } from '../services/courseService';

const CourseList = () => {
    const [courses, setCourses] = useState([]);
    const [filteredCourses, setFilteredCourses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        fetchCourses();
    }, []);

    useEffect(() => {
        if (searchTerm.trim() === '') {
            setFilteredCourses(courses);
        } else {
            const filtered = courses.filter(course =>
                course.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                course.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
                course.instructor.toLowerCase().includes(searchTerm.toLowerCase())
            );
            setFilteredCourses(filtered);
        }
    }, [searchTerm, courses]);

    const fetchCourses = async () => {
        try {
            setLoading(true);
            const data = await getAllCourses();
            setCourses(data);
            setFilteredCourses(data);
            setError(null);
        } catch (err) {
            setError('Failed to fetch courses. Please try again later.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id, title) => {
        if (window.confirm(`Are you sure you want to delete the course "${title}"?`)) {
            try {
                await deleteCourse(id);
                setCourses(courses.filter(course => course._id !== id));
                toast.success('Course deleted successfully!');
            } catch (err) {
                setError('Failed to delete course. Please try again later.');
                toast.error('Failed to delete course.');
                console.error(err);
            }
        }
    };

    const handleSearch = (e) => {
        setSearchTerm(e.target.value);
    };

    const getEnrollmentStatusClass = (enrolled, capacity) => {
        const ratio = enrolled / capacity;
        if (ratio >= 0.9) return 'danger';
        if (ratio >= 0.7) return 'warning';
        return 'success';
    };

    if (loading) {
        return (
            <div className="d-flex justify-content-center align-items-center" style={{ height: '300px' }}>
                <Spinner animation="border" role="status" variant="primary">
                    <span className="visually-hidden">Loading courses...</span>
                </Spinner>
            </div>
        );
    }

    return (
        <div>
            <Row className="mb-4 align-items-center">
                <Col>
                    <h1 className="mb-0">
                        <FaBook className="me-2" />
                        Courses
                    </h1>
                </Col>
                <Col xs="auto">
                    <Button
                        as={Link}
                        to="/courses/new"
                        variant="primary"
                    >
                        <FaPlus className="me-2" />
                        Add New Course
                    </Button>
                </Col>
            </Row>

            {error && <Alert variant="danger">{error}</Alert>}

            <Card className="shadow-sm mb-4">
                <Card.Body>
                    <InputGroup className="mb-3">
                        <InputGroup.Text>
                            <FaSearch />
                        </InputGroup.Text>
                        <Form.Control
                            placeholder="Search by title, code, or instructor..."
                            value={searchTerm}
                            onChange={handleSearch}
                        />
                    </InputGroup>

                    {filteredCourses.length === 0 ? (
                        <Alert variant="info">
                            {searchTerm ? 'No courses match your search.' : 'No courses found.'}
                        </Alert>
                    ) : (
                        <Table hover responsive>
                            <thead className="table-light">
                                <tr>
                                    <th>Code</th>
                                    <th>Title</th>
                                    <th>Instructor</th>
                                    <th>Credits</th>
                                    <th>Enrollment</th>
                                    <th className="text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {filteredCourses.map(course => (
                                    <tr key={course._id}>
                                        <td className="align-middle">
                                            <strong>{course.code}</strong>
                                        </td>
                                        <td className="align-middle">{course.title}</td>
                                        <td className="align-middle">{course.instructor}</td>
                                        <td className="align-middle">{course.credits}</td>
                                        <td className="align-middle">
                                            <Badge
                                                bg={getEnrollmentStatusClass(course.enrolledStudents, course.capacity)}
                                            >
                                                {course.enrolledStudents}/{course.capacity}
                                            </Badge>
                                        </td>
                                        <td className="text-center">
                                            <Button
                                                as={Link}
                                                to={`/courses/${course._id}`}
                                                variant="outline-primary"
                                                size="sm"
                                                className="me-2"
                                                title="View course details"
                                            >
                                                <FaEye />
                                            </Button>
                                            <Button
                                                as={Link}
                                                to={`/courses/edit/${course._id}`}
                                                variant="outline-secondary"
                                                size="sm"
                                                className="me-2"
                                                title="Edit course"
                                            >
                                                <FaEdit />
                                            </Button>
                                            <Button
                                                onClick={() => handleDelete(course._id, course.title)}
                                                variant="outline-danger"
                                                size="sm"
                                                title="Delete course"
                                            >
                                                <FaTrash />
                                            </Button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </Table>
                    )}
                </Card.Body>
                <Card.Footer className="text-muted">
                    Total Courses: {filteredCourses.length}
                </Card.Footer>
            </Card>
        </div>
    );
};

export default CourseList;
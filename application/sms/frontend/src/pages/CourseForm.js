import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { Form, Button, Card, Row, Col, Alert, Spinner } from 'react-bootstrap';
import { FaArrowLeft, FaSave, FaBook } from 'react-icons/fa';
import { toast } from 'react-toastify';
import { getCourseById, createCourse, updateCourse } from '../services/courseService';

const CourseForm = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const isEditMode = !!id;

    const [formData, setFormData] = useState({
        title: '',
        code: '',
        description: '',
        credits: 3,
        instructor: '',
        startDate: '',
        endDate: '',
        capacity: 30
    });

    const [loading, setLoading] = useState(isEditMode);
    const [submitting, setSubmitting] = useState(false);
    const [error, setError] = useState(null);
    const [validated, setValidated] = useState(false);

    useEffect(() => {
        if (isEditMode) {
            fetchCourse();
        } else {
            setLoading(false);
        }
    }, [id, isEditMode]);

    const fetchCourse = async () => {
        try {
            setLoading(true);
            const course = await getCourseById(id);

            setFormData({
                title: course.title,
                code: course.code,
                description: course.description || '',
                credits: course.credits,
                instructor: course.instructor,
                startDate: course.startDate ? new Date(course.startDate).toISOString().split('T')[0] : '',
                endDate: course.endDate ? new Date(course.endDate).toISOString().split('T')[0] : '',
                capacity: course.capacity
            });

            setError(null);
        } catch (err) {
            setError('Failed to fetch course data. Please try again later.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: name === 'credits' || name === 'capacity' ? parseInt(value, 10) : value
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        const form = e.currentTarget;

        if (form.checkValidity() === false) {
            e.stopPropagation();
            setValidated(true);
            return;
        }

        setValidated(true);
        setSubmitting(true);

        try {
            if (isEditMode) {
                await updateCourse(id, formData);
                toast.success('Course updated successfully!');
            } else {
                await createCourse(formData);
                toast.success('Course created successfully!');
            }
            navigate('/courses');
        } catch (err) {
            setError(`Failed to ${isEditMode ? 'update' : 'create'} course. Please try again later.`);
            toast.error(`Failed to ${isEditMode ? 'update' : 'create'} course.`);
            console.error(err);
        } finally {
            setSubmitting(false);
        }
    };

    if (loading) {
        return (
            <div className="d-flex justify-content-center align-items-center" style={{ height: '300px' }}>
                <Spinner animation="border" role="status" variant="primary">
                    <span className="visually-hidden">Loading...</span>
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
                        {isEditMode ? 'Edit Course' : 'Add New Course'}
                    </h1>
                </Col>
                <Col xs="auto">
                    <Button
                        as={Link}
                        to="/courses"
                        variant="outline-secondary"
                    >
                        <FaArrowLeft className="me-2" />
                        Back to Courses
                    </Button>
                </Col>
            </Row>

            {error && <Alert variant="danger">{error}</Alert>}

            <Card className="shadow-sm">
                <Card.Body>
                    <Form noValidate validated={validated} onSubmit={handleSubmit}>
                        <Row>
                            <Col md={6}>
                                <Form.Group className="mb-3" controlId="title">
                                    <Form.Label>Course Title</Form.Label>
                                    <Form.Control
                                        type="text"
                                        name="title"
                                        value={formData.title}
                                        onChange={handleChange}
                                        required
                                        placeholder="Enter course title"
                                    />
                                    <Form.Control.Feedback type="invalid">
                                        Please provide a course title.
                                    </Form.Control.Feedback>
                                </Form.Group>
                            </Col>

                            <Col md={6}>
                                <Form.Group className="mb-3" controlId="code">
                                    <Form.Label>Course Code</Form.Label>
                                    <Form.Control
                                        type="text"
                                        name="code"
                                        value={formData.code}
                                        onChange={handleChange}
                                        required
                                        placeholder="Enter course code (e.g. CS101)"
                                    />
                                    <Form.Control.Feedback type="invalid">
                                        Please provide a course code.
                                    </Form.Control.Feedback>
                                </Form.Group>
                            </Col>
                        </Row>

                        <Form.Group className="mb-3" controlId="description">
                            <Form.Label>Description</Form.Label>
                            <Form.Control
                                as="textarea"
                                rows={3}
                                name="description"
                                value={formData.description}
                                onChange={handleChange}
                                placeholder="Enter course description"
                            />
                        </Form.Group>

                        <Row>
                            <Col md={6}>
                                <Form.Group className="mb-3" controlId="instructor">
                                    <Form.Label>Instructor</Form.Label>
                                    <Form.Control
                                        type="text"
                                        name="instructor"
                                        value={formData.instructor}
                                        onChange={handleChange}
                                        required
                                        placeholder="Enter instructor name"
                                    />
                                    <Form.Control.Feedback type="invalid">
                                        Please provide an instructor name.
                                    </Form.Control.Feedback>
                                </Form.Group>
                            </Col>

                            <Col md={6}>
                                <Form.Group className="mb-3" controlId="credits">
                                    <Form.Label>Credits</Form.Label>
                                    <Form.Control
                                        type="number"
                                        name="credits"
                                        value={formData.credits}
                                        onChange={handleChange}
                                        required
                                        min="1"
                                        placeholder="Enter number of credits"
                                    />
                                    <Form.Control.Feedback type="invalid">
                                        Please provide a valid number of credits.
                                    </Form.Control.Feedback>
                                </Form.Group>
                            </Col>
                        </Row>

                        <Row>
                            <Col md={6}>
                                <Form.Group className="mb-3" controlId="startDate">
                                    <Form.Label>Start Date</Form.Label>
                                    <Form.Control
                                        type="date"
                                        name="startDate"
                                        value={formData.startDate}
                                        onChange={handleChange}
                                    />
                                </Form.Group>
                            </Col>

                            <Col md={6}>
                                <Form.Group className="mb-3" controlId="endDate">
                                    <Form.Label>End Date</Form.Label>
                                    <Form.Control
                                        type="date"
                                        name="endDate"
                                        value={formData.endDate}
                                        onChange={handleChange}
                                    />
                                </Form.Group>
                            </Col>
                        </Row>

                        <Form.Group className="mb-4" controlId="capacity">
                            <Form.Label>Capacity</Form.Label>
                            <Form.Control
                                type="number"
                                name="capacity"
                                value={formData.capacity}
                                onChange={handleChange}
                                required
                                min="1"
                                placeholder="Enter maximum number of students"
                            />
                            <Form.Control.Feedback type="invalid">
                                Please provide a valid capacity.
                            </Form.Control.Feedback>
                            <Form.Text className="text-muted">
                                Maximum number of students that can enroll in this course
                            </Form.Text>
                        </Form.Group>

                        <div className="d-grid gap-2 d-md-flex justify-content-md-end">
                            <Button
                                variant="secondary"
                                as={Link}
                                to="/courses"
                                className="me-md-2"
                            >
                                Cancel
                            </Button>
                            <Button
                                type="submit"
                                variant="primary"
                                disabled={submitting}
                            >
                                {submitting ? (
                                    <>
                                        <Spinner
                                            as="span"
                                            animation="border"
                                            size="sm"
                                            role="status"
                                            aria-hidden="true"
                                            className="me-2"
                                        />
                                        {isEditMode ? 'Updating...' : 'Creating...'}
                                    </>
                                ) : (
                                    <>
                                        <FaSave className="me-2" />
                                        {isEditMode ? 'Update Course' : 'Add Course'}
                                    </>
                                )}
                            </Button>
                        </div>
                    </Form>
                </Card.Body>
            </Card>
        </div>
    );
};

export default CourseForm;
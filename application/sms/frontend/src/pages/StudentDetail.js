import React, { useState, useEffect } from 'react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import { Row, Col, Card, Button, Table, Form, Alert, Spinner, Image } from 'react-bootstrap';
import { FaGraduationCap, FaEdit, FaTrash, FaArrowLeft, FaEye, FaUserMinus, FaUserPlus } from 'react-icons/fa';
import { toast } from 'react-toastify';
import { getStudentById, deleteStudent, removeCourseFromStudent, getProfilePictureUrl } from '../services/studentService';
import { getAllCourses, enrollStudent } from '../services/courseService';

const StudentDetail = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const [student, setStudent] = useState(null);
    const [courses, setCourses] = useState([]);
    const [availableCourses, setAvailableCourses] = useState([]);
    const [selectedCourse, setSelectedCourse] = useState('');
    const [loading, setLoading] = useState(true);
    const [enrolling, setEnrolling] = useState(false);
    const [error, setError] = useState(null);
    const [profilePictureUrl, setProfilePictureUrl] = useState('');

    useEffect(() => {
        fetchStudentAndCourses();
    }, [id]);

    const fetchStudentAndCourses = async () => {
        try {
            setLoading(true);
            const [studentData, coursesData] = await Promise.all([
                getStudentById(id),
                getAllCourses()
            ]);

            setStudent(studentData);

            // Set profile picture URL if available
            if (studentData.profilePicture) {
                setProfilePictureUrl(getProfilePictureUrl(studentData._id));
            }

            // Get enrolled courses
            const enrolledCourses = coursesData.filter(course =>
                studentData.courses.includes(course._id)
            );
            setCourses(enrolledCourses);

            // Get available courses (not enrolled)
            const notEnrolledCourses = coursesData.filter(course =>
                !studentData.courses.includes(course._id)
            );
            setAvailableCourses(notEnrolledCourses);

            setError(null);
        } catch (err) {
            setError('Failed to fetch data. Please try again later.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async () => {
        if (window.confirm('Are you sure you want to delete this student?')) {
            try {
                await deleteStudent(id);
                toast.success('Student deleted successfully!');
                navigate('/students');
            } catch (err) {
                setError('Failed to delete student. Please try again later.');
                toast.error('Failed to delete student.');
                console.error(err);
            }
        }
    };

    const handleEnroll = async (e) => {
        e.preventDefault();
        if (!selectedCourse) return;

        try {
            setEnrolling(true);
            await enrollStudent(selectedCourse, id);
            fetchStudentAndCourses();
            setSelectedCourse('');
            toast.success('Student enrolled successfully!');
        } catch (err) {
            setError('Failed to enroll in course. Please try again later.');
            toast.error('Failed to enroll in course.');
            console.error(err);
        } finally {
            setEnrolling(false);
        }
    };

    const handleUnenroll = async (courseId, courseName) => {
        if (window.confirm(`Are you sure you want to unenroll from ${courseName}?`)) {
            try {
                await removeCourseFromStudent(id, courseId);
                fetchStudentAndCourses();
                toast.success('Student unenrolled successfully!');
            } catch (err) {
                setError('Failed to unenroll from course. Please try again later.');
                toast.error('Failed to unenroll from course.');
                console.error(err);
            }
        }
    };

    if (loading) {
        return (
            <div className="d-flex justify-content-center align-items-center" style={{ height: '300px' }}>
                <Spinner animation="border" role="status" variant="primary">
                    <span className="visually-hidden">Loading student details...</span>
                </Spinner>
            </div>
        );
    }

    if (!student) {
        return <Alert variant="danger">Student not found</Alert>;
    }

    return (
        <div>
            <Row className="mb-4 align-items-center">
                <Col>
                    <h1 className="mb-0">
                        <FaGraduationCap className="me-2" />
                        Student Details
                    </h1>
                </Col>
                <Col xs="auto">
                    <Button
                        as={Link}
                        to="/students"
                        variant="outline-secondary"
                        className="me-2"
                    >
                        <FaArrowLeft className="me-2" />
                        Back to Students
                    </Button>
                    <Button
                        as={Link}
                        to={`/students/edit/${id}`}
                        variant="outline-primary"
                        className="me-2"
                    >
                        <FaEdit className="me-2" />
                        Edit
                    </Button>
                    <Button
                        onClick={handleDelete}
                        variant="outline-danger"
                    >
                        <FaTrash className="me-2" />
                        Delete
                    </Button>
                </Col>
            </Row>

            {error && <Alert variant="danger">{error}</Alert>}

            <Card className="shadow-sm mb-4">
                <Card.Body>
                    <Row>
                        <Col md={3} className="text-center mb-3 mb-md-0">
                            {profilePictureUrl ? (
                                <Image
                                    src={profilePictureUrl}
                                    roundedCircle
                                    style={{ width: '180px', height: '180px', objectFit: 'cover' }}
                                    className="border"
                                />
                            ) : (
                                <div
                                    className="bg-light d-flex align-items-center justify-content-center rounded-circle border"
                                    style={{ width: '180px', height: '180px', margin: '0 auto' }}
                                >
                                    <FaGraduationCap size={60} className="text-muted" />
                                </div>
                            )}
                        </Col>
                        <Col md={9}>
                            <h2 className="mb-3">{student.firstName} {student.lastName}</h2>
                            <Row>
                                <Col md={6}>
                                    <p><strong>Email:</strong> {student.email}</p>
                                    <p><strong>Date of Birth:</strong> {student.dateOfBirth ? new Date(student.dateOfBirth).toLocaleDateString() : 'Not specified'}</p>
                                </Col>
                                <Col md={6}>
                                    <p><strong>Enrollment Date:</strong> {new Date(student.enrollmentDate).toLocaleDateString()}</p>
                                    <p><strong>Courses Enrolled:</strong> {courses.length}</p>
                                </Col>
                            </Row>
                        </Col>
                    </Row>
                </Card.Body>
            </Card>

            <h2 className="mb-3">
                <FaGraduationCap className="me-2" />
                Enrolled Courses
            </h2>

            {courses.length === 0 ? (
                <Alert variant="info">No courses enrolled.</Alert>
            ) : (
                <Card className="shadow-sm mb-4">
                    <Card.Body>
                        <Table hover responsive>
                            <thead className="table-light">
                                <tr>
                                    <th>Course Code</th>
                                    <th>Title</th>
                                    <th>Instructor</th>
                                    <th>Credits</th>
                                    <th className="text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {courses.map(course => (
                                    <tr key={course._id}>
                                        <td className="align-middle"><strong>{course.code}</strong></td>
                                        <td className="align-middle">{course.title}</td>
                                        <td className="align-middle">{course.instructor}</td>
                                        <td className="align-middle">{course.credits}</td>
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
                                                onClick={() => handleUnenroll(course._id, course.title)}
                                                variant="outline-danger"
                                                size="sm"
                                                title="Unenroll from course"
                                            >
                                                <FaUserMinus />
                                            </Button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </Table>
                    </Card.Body>
                </Card>
            )}

            <h2 className="mb-3">
                <FaUserPlus className="me-2" />
                Enroll in a Course
            </h2>

            {availableCourses.length === 0 ? (
                <Alert variant="info">No available courses to enroll.</Alert>
            ) : (
                <Card className="shadow-sm">
                    <Card.Body>
                        <Form onSubmit={handleEnroll}>
                            <Row className="align-items-end">
                                <Col md={9}>
                                    <Form.Group controlId="course">
                                        <Form.Label>Select Course:</Form.Label>
                                        <Form.Select
                                            value={selectedCourse}
                                            onChange={(e) => setSelectedCourse(e.target.value)}
                                            required
                                        >
                                            <option value="">-- Select a course --</option>
                                            {availableCourses.map(course => (
                                                <option key={course._id} value={course._id}>
                                                    {course.code} - {course.title} ({course.credits} credits)
                                                </option>
                                            ))}
                                        </Form.Select>
                                    </Form.Group>
                                </Col>
                                <Col md={3}>
                                    <Button
                                        type="submit"
                                        variant="primary"
                                        className="w-100"
                                        disabled={enrolling}
                                    >
                                        {enrolling ? (
                                            <>
                                                <Spinner
                                                    as="span"
                                                    animation="border"
                                                    size="sm"
                                                    role="status"
                                                    aria-hidden="true"
                                                    className="me-2"
                                                />
                                                Enrolling...
                                            </>
                                        ) : (
                                            <>
                                                <FaUserPlus className="me-2" />
                                                Enroll
                                            </>
                                        )}
                                    </Button>
                                </Col>
                            </Row>
                        </Form>
                    </Card.Body>
                </Card>
            )}
        </div>
    );
};

export default StudentDetail;
import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { Form, Button, Card, Row, Col, Alert, Spinner, Image } from 'react-bootstrap';
import { FaArrowLeft, FaSave, FaGraduationCap, FaCamera, FaUpload } from 'react-icons/fa';
import Select from 'react-select';
import { toast } from 'react-toastify';
import { getStudentById, createStudent, updateStudent, uploadProfilePicture, getProfilePictureUrl } from '../services/studentService';
import { getAllCourses } from '../services/courseService';

const StudentForm = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const isEditMode = !!id;

    const [formData, setFormData] = useState({
        firstName: '',
        lastName: '',
        email: '',
        dateOfBirth: '',
        enrollmentDate: new Date().toISOString().split('T')[0],
        courses: []
    });

    const [profilePicture, setProfilePicture] = useState(null);
    const [profilePictureUrl, setProfilePictureUrl] = useState('');
    const [uploadingPicture, setUploadingPicture] = useState(false);
    const fileInputRef = useRef(null);

    const [availableCourses, setAvailableCourses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [submitting, setSubmitting] = useState(false);
    const [error, setError] = useState(null);
    const [validated, setValidated] = useState(false);

    useEffect(() => {
        fetchCourses();
        if (isEditMode) {
            fetchStudent();
        } else {
            setLoading(false);
        }
    }, [id, isEditMode]);

    const fetchCourses = async () => {
        try {
            const courses = await getAllCourses();
            setAvailableCourses(courses);
        } catch (err) {
            setError('Failed to fetch courses. Please try again later.');
            console.error(err);
        }
    };

    const fetchStudent = async () => {
        try {
            setLoading(true);
            const student = await getStudentById(id);

            setFormData({
                firstName: student.firstName,
                lastName: student.lastName,
                email: student.email,
                dateOfBirth: student.dateOfBirth ? new Date(student.dateOfBirth).toISOString().split('T')[0] : '',
                enrollmentDate: student.enrollmentDate ? new Date(student.enrollmentDate).toISOString().split('T')[0] : '',
                courses: student.courses || []
            });

            // Set profile picture URL if available
            if (student.profilePicture) {
                setProfilePictureUrl(getProfilePictureUrl(student._id));
            }

            setError(null);
        } catch (err) {
            setError('Failed to fetch student data. Please try again later.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleProfilePictureChange = (e) => {
        if (e.target.files && e.target.files[0]) {
            setProfilePicture(e.target.files[0]);
            setProfilePictureUrl(URL.createObjectURL(e.target.files[0]));
        }
    };

    const handleProfilePictureUpload = async () => {
        if (!profilePicture) return;

        try {
            setUploadingPicture(true);
            await uploadProfilePicture(id, profilePicture);
            toast.success('Profile picture uploaded successfully!');
        } catch (err) {
            setError('Failed to upload profile picture. Please try again later.');
            toast.error('Failed to upload profile picture.');
            console.error(err);
        } finally {
            setUploadingPicture(false);
        }
    };

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
    };

    const handleCourseChange = (selectedOptions) => {
        const courseIds = selectedOptions ? selectedOptions.map(option => option.value) : [];
        setFormData(prev => ({
            ...prev,
            courses: courseIds
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
            let studentId;

            if (isEditMode) {
                await updateStudent(id, formData);
                studentId = id;
                toast.success('Student updated successfully!');
            } else {
                const newStudent = await createStudent(formData);
                studentId = newStudent._id;
                toast.success('Student created successfully!');
            }

            // Upload profile picture if selected
            if (profilePicture && studentId) {
                try {
                    await uploadProfilePicture(studentId, profilePicture);
                } catch (uploadErr) {
                    console.error('Error uploading profile picture:', uploadErr);
                    // Don't fail the whole operation if just the picture upload fails
                }
            }

            navigate('/students');
        } catch (err) {
            setError(`Failed to ${isEditMode ? 'update' : 'create'} student. Please try again later.`);
            toast.error(`Failed to ${isEditMode ? 'update' : 'create'} student.`);
            console.error(err);
        } finally {
            setSubmitting(false);
        }
    };

    // Convert courses array to options for react-select
    const courseOptions = availableCourses.map(course => ({
        value: course._id,
        label: `${course.code} - ${course.title}`
    }));

    // Get selected course options
    const selectedCourseOptions = courseOptions.filter(option =>
        formData.courses.includes(option.value)
    );

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
                        <FaGraduationCap className="me-2" />
                        {isEditMode ? 'Edit Student' : 'Add New Student'}
                    </h1>
                </Col>
                <Col xs="auto">
                    <Button
                        as={Link}
                        to="/students"
                        variant="outline-secondary"
                    >
                        <FaArrowLeft className="me-2" />
                        Back to Students
                    </Button>
                </Col>
            </Row>

            {error && <Alert variant="danger">{error}</Alert>}

            <Card className="shadow-sm">
                <Card.Body>
                    <Form noValidate validated={validated} onSubmit={handleSubmit}>
                        <Row className="mb-4">
                            <Col md={3} className="text-center">
                                <div className="position-relative mb-3">
                                    {profilePictureUrl ? (
                                        <Image
                                            src={profilePictureUrl}
                                            roundedCircle
                                            style={{ width: '150px', height: '150px', objectFit: 'cover' }}
                                            className="border"
                                        />
                                    ) : (
                                        <div
                                            className="bg-light d-flex align-items-center justify-content-center rounded-circle border"
                                            style={{ width: '150px', height: '150px' }}
                                        >
                                            <FaCamera size={40} className="text-muted" />
                                        </div>
                                    )}
                                </div>
                                <input
                                    type="file"
                                    ref={fileInputRef}
                                    onChange={handleProfilePictureChange}
                                    accept="image/*"
                                    style={{ display: 'none' }}
                                />
                                <Button
                                    variant="outline-primary"
                                    size="sm"
                                    onClick={() => fileInputRef.current.click()}
                                    className="mb-2"
                                >
                                    <FaUpload className="me-1" /> Choose Photo
                                </Button>
                                {isEditMode && profilePicture && (
                                    <div>
                                        <Button
                                            variant="primary"
                                            size="sm"
                                            onClick={handleProfilePictureUpload}
                                            disabled={uploadingPicture}
                                        >
                                            {uploadingPicture ? (
                                                <>
                                                    <Spinner
                                                        as="span"
                                                        animation="border"
                                                        size="sm"
                                                        role="status"
                                                        aria-hidden="true"
                                                        className="me-1"
                                                    />
                                                    Uploading...
                                                </>
                                            ) : (
                                                <>Upload</>
                                            )}
                                        </Button>
                                    </div>
                                )}
                            </Col>
                            <Col md={9}>
                                <Row>
                                    <Col md={6}>
                                        <Form.Group className="mb-3" controlId="firstName">
                                            <Form.Label>First Name</Form.Label>
                                            <Form.Control
                                                type="text"
                                                name="firstName"
                                                value={formData.firstName}
                                                onChange={handleChange}
                                                required
                                                placeholder="Enter first name"
                                            />
                                            <Form.Control.Feedback type="invalid">
                                                Please provide a first name.
                                            </Form.Control.Feedback>
                                        </Form.Group>
                                    </Col>

                                    <Col md={6}>
                                        <Form.Group className="mb-3" controlId="lastName">
                                            <Form.Label>Last Name</Form.Label>
                                            <Form.Control
                                                type="text"
                                                name="lastName"
                                                value={formData.lastName}
                                                onChange={handleChange}
                                                required
                                                placeholder="Enter last name"
                                            />
                                            <Form.Control.Feedback type="invalid">
                                                Please provide a last name.
                                            </Form.Control.Feedback>
                                        </Form.Group>
                                    </Col>
                                </Row>
                            </Col>
                        </Row>

                        <Form.Group className="mb-3" controlId="email">
                            <Form.Label>Email</Form.Label>
                            <Form.Control
                                type="email"
                                name="email"
                                value={formData.email}
                                onChange={handleChange}
                                required
                                placeholder="Enter email address"
                            />
                            <Form.Control.Feedback type="invalid">
                                Please provide a valid email address.
                            </Form.Control.Feedback>
                        </Form.Group>

                        <Row>
                            <Col md={6}>
                                <Form.Group className="mb-3" controlId="dateOfBirth">
                                    <Form.Label>Date of Birth</Form.Label>
                                    <Form.Control
                                        type="date"
                                        name="dateOfBirth"
                                        value={formData.dateOfBirth}
                                        onChange={handleChange}
                                    />
                                </Form.Group>
                            </Col>

                            <Col md={6}>
                                <Form.Group className="mb-3" controlId="enrollmentDate">
                                    <Form.Label>Enrollment Date</Form.Label>
                                    <Form.Control
                                        type="date"
                                        name="enrollmentDate"
                                        value={formData.enrollmentDate}
                                        onChange={handleChange}
                                        required
                                    />
                                    <Form.Control.Feedback type="invalid">
                                        Please provide an enrollment date.
                                    </Form.Control.Feedback>
                                </Form.Group>
                            </Col>
                        </Row>

                        <Form.Group className="mb-4" controlId="courses">
                            <Form.Label>Assign Courses</Form.Label>
                            <Select
                                isMulti
                                name="courses"
                                options={courseOptions}
                                value={selectedCourseOptions}
                                onChange={handleCourseChange}
                                className="basic-multi-select"
                                classNamePrefix="select"
                                placeholder="Select courses to assign"
                            />
                            <Form.Text className="text-muted">
                                You can select multiple courses for this student
                            </Form.Text>
                        </Form.Group>

                        <div className="d-grid gap-2 d-md-flex justify-content-md-end">
                            <Button
                                variant="secondary"
                                as={Link}
                                to="/students"
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
                                        {isEditMode ? 'Update Student' : 'Add Student'}
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

export default StudentForm;
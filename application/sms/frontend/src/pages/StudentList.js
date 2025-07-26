import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Table, Button, Card, Row, Col, Alert, Spinner, Badge, InputGroup, Form, Image } from 'react-bootstrap';
import { FaPlus, FaEye, FaEdit, FaTrash, FaSearch, FaGraduationCap, FaUser } from 'react-icons/fa';
import { toast } from 'react-toastify';
import { getAllStudents, deleteStudent, getProfilePictureUrl } from '../services/studentService';

const StudentList = () => {
    const [students, setStudents] = useState([]);
    const [filteredStudents, setFilteredStudents] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        fetchStudents();
    }, []);

    useEffect(() => {
        if (searchTerm.trim() === '') {
            setFilteredStudents(students);
        } else {
            const filtered = students.filter(student =>
                `${student.firstName} ${student.lastName}`.toLowerCase().includes(searchTerm.toLowerCase()) ||
                student.email.toLowerCase().includes(searchTerm.toLowerCase())
            );
            setFilteredStudents(filtered);
        }
    }, [searchTerm, students]);

    const fetchStudents = async () => {
        try {
            setLoading(true);
            const data = await getAllStudents();
            setStudents(data);
            setFilteredStudents(data);
            setError(null);
        } catch (err) {
            setError('Failed to fetch students. Please try again later.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id, name) => {
        if (window.confirm(`Are you sure you want to delete ${name}?`)) {
            try {
                await deleteStudent(id);
                setStudents(students.filter(student => student._id !== id));
                toast.success('Student deleted successfully!');
            } catch (err) {
                setError('Failed to delete student. Please try again later.');
                toast.error('Failed to delete student.');
                console.error(err);
            }
        }
    };

    const handleSearch = (e) => {
        setSearchTerm(e.target.value);
    };

    if (loading) {
        return (
            <div className="d-flex justify-content-center align-items-center" style={{ height: '300px' }}>
                <Spinner animation="border" role="status" variant="primary">
                    <span className="visually-hidden">Loading students...</span>
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
                        Students
                    </h1>
                </Col>
                <Col xs="auto">
                    <Button
                        as={Link}
                        to="/students/new"
                        variant="primary"
                    >
                        <FaPlus className="me-2" />
                        Add New Student
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
                            placeholder="Search by name or email..."
                            value={searchTerm}
                            onChange={handleSearch}
                        />
                    </InputGroup>

                    {filteredStudents.length === 0 ? (
                        <Alert variant="info">
                            {searchTerm ? 'No students match your search.' : 'No students found.'}
                        </Alert>
                    ) : (
                        <Table hover responsive>
                            <thead className="table-light">
                                <tr>
                                    <th style={{ width: '50px' }}></th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Enrollment Date</th>
                                    <th>Courses</th>
                                    <th className="text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {filteredStudents.map(student => (
                                    <tr key={student._id}>
                                        <td className="align-middle text-center">
                                            {student.profilePicture ? (
                                                <Image
                                                    src={getProfilePictureUrl(student._id)}
                                                    roundedCircle
                                                    style={{ width: '40px', height: '40px', objectFit: 'cover' }}
                                                />
                                            ) : (
                                                <div className="bg-light d-flex align-items-center justify-content-center rounded-circle"
                                                    style={{ width: '40px', height: '40px', margin: '0 auto' }}>
                                                    <FaUser className="text-muted" />
                                                </div>
                                            )}
                                        </td>
                                        <td className="align-middle">
                                            <strong>{student.firstName} {student.lastName}</strong>
                                        </td>
                                        <td className="align-middle">{student.email}</td>
                                        <td className="align-middle">
                                            {new Date(student.enrollmentDate).toLocaleDateString()}
                                        </td>
                                        <td className="align-middle">
                                            <Badge bg="info">
                                                {student.courses ? student.courses.length : 0} courses
                                            </Badge>
                                        </td>
                                        <td className="text-center">
                                            <Button
                                                as={Link}
                                                to={`/students/${student._id}`}
                                                variant="outline-primary"
                                                size="sm"
                                                className="me-2"
                                                title="View student details"
                                            >
                                                <FaEye />
                                            </Button>
                                            <Button
                                                as={Link}
                                                to={`/students/edit/${student._id}`}
                                                variant="outline-secondary"
                                                size="sm"
                                                className="me-2"
                                                title="Edit student"
                                            >
                                                <FaEdit />
                                            </Button>
                                            <Button
                                                onClick={() => handleDelete(student._id, `${student.firstName} ${student.lastName}`)}
                                                variant="outline-danger"
                                                size="sm"
                                                title="Delete student"
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
                    Total Students: {filteredStudents.length}
                </Card.Footer>
            </Card>
        </div>
    );
};

export default StudentList;
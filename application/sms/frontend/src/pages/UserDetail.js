import React, { useState, useEffect } from 'react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import { Card, Button, Row, Col, Alert, Spinner, Badge } from 'react-bootstrap';
import { FaUser, FaEdit, FaTrash, FaArrowLeft, FaToggleOn, FaToggleOff } from 'react-icons/fa';
import { toast } from 'react-toastify';
import { getUserById, deleteUser, toggleUserStatus } from '../services/userService';

const UserDetail = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        fetchUser();
    }, [id]);

    const fetchUser = async () => {
        try {
            setLoading(true);
            const userData = await getUserById(id);
            setUser(userData);
            setError(null);
        } catch (err) {
            setError('Failed to fetch user data. Please try again later.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async () => {
        if (window.confirm(`Are you sure you want to delete ${user.firstName} ${user.lastName}?`)) {
            try {
                await deleteUser(id);
                toast.success('User deleted successfully!');
                navigate('/users');
            } catch (err) {
                setError('Failed to delete user. Please try again later.');
                toast.error('Failed to delete user.');
                console.error(err);
            }
        }
    };

    const handleToggleStatus = async () => {
        try {
            const result = await toggleUserStatus(id);
            setUser(result.user);
            toast.success(`User ${result.user.active ? 'enabled' : 'disabled'} successfully!`);
        } catch (err) {
            setError('Failed to update user status. Please try again later.');
            toast.error('Failed to update user status.');
            console.error(err);
        }
    };

    if (loading) {
        return (
            <div className="d-flex justify-content-center align-items-center" style={{ height: '300px' }}>
                <Spinner animation="border" role="status" variant="primary">
                    <span className="visually-hidden">Loading user details...</span>
                </Spinner>
            </div>
        );
    }

    if (!user) {
        return <Alert variant="danger">User not found</Alert>;
    }

    return (
        <div>
            <Row className="mb-4 align-items-center">
                <Col>
                    <h1 className="mb-0">
                        <FaUser className="me-2" />
                        User Details
                    </h1>
                </Col>
                <Col xs="auto">
                    <Button
                        as={Link}
                        to="/users"
                        variant="outline-secondary"
                        className="me-2"
                    >
                        <FaArrowLeft className="me-2" />
                        Back to Users
                    </Button>
                    <Button
                        as={Link}
                        to={`/users/edit/${id}`}
                        variant="outline-primary"
                        className="me-2"
                    >
                        <FaEdit className="me-2" />
                        Edit
                    </Button>
                    <Button
                        onClick={handleToggleStatus}
                        variant={user.active ? "outline-warning" : "outline-success"}
                        className="me-2"
                    >
                        {user.active ? (
                            <>
                                <FaToggleOff className="me-2" />
                                Disable
                            </>
                        ) : (
                            <>
                                <FaToggleOn className="me-2" />
                                Enable
                            </>
                        )}
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
                            <div
                                className="bg-light d-flex align-items-center justify-content-center rounded-circle border"
                                style={{ width: '180px', height: '180px', margin: '0 auto' }}
                            >
                                <FaUser size={60} className="text-muted" />
                            </div>
                        </Col>
                        <Col md={9}>
                            <h2 className="mb-3">{user.firstName} {user.lastName}</h2>
                            <Row>
                                <Col md={6}>
                                    <p><strong>Email:</strong> {user.email}</p>
                                    <p>
                                        <strong>Role:</strong>{' '}
                                        <Badge bg={user.role === 'admin' ? 'danger' : 'info'}>
                                            {user.role}
                                        </Badge>
                                    </p>
                                </Col>
                                <Col md={6}>
                                    <p>
                                        <strong>Status:</strong>{' '}
                                        <Badge bg={user.active ? 'success' : 'secondary'}>
                                            {user.active ? 'Active' : 'Inactive'}
                                        </Badge>
                                    </p>
                                    <p><strong>Created:</strong> {new Date(user.createdAt).toLocaleDateString()}</p>
                                </Col>
                            </Row>
                        </Col>
                    </Row>
                </Card.Body>
            </Card>
        </div>
    );
};

export default UserDetail;
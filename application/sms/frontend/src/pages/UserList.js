import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Table, Button, Card, Row, Col, Alert, Spinner, Badge, InputGroup, Form } from 'react-bootstrap';
import { FaPlus, FaEye, FaEdit, FaTrash, FaSearch, FaUsers, FaToggleOn, FaToggleOff } from 'react-icons/fa';
import { toast } from 'react-toastify';
import { getAllUsers, deleteUser, toggleUserStatus } from '../services/userService';

const UserList = () => {
    const [users, setUsers] = useState([]);
    const [filteredUsers, setFilteredUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        fetchUsers();
    }, []);

    useEffect(() => {
        if (searchTerm.trim() === '') {
            setFilteredUsers(users);
        } else {
            const filtered = users.filter(user =>
                `${user.firstName} ${user.lastName}`.toLowerCase().includes(searchTerm.toLowerCase()) ||
                user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                user.role.toLowerCase().includes(searchTerm.toLowerCase())
            );
            setFilteredUsers(filtered);
        }
    }, [searchTerm, users]);

    const fetchUsers = async () => {
        try {
            setLoading(true);
            const data = await getAllUsers();
            setUsers(data);
            setFilteredUsers(data);
            setError(null);
        } catch (err) {
            setError('Failed to fetch users. Please try again later.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id, name) => {
        if (window.confirm(`Are you sure you want to delete ${name}?`)) {
            try {
                await deleteUser(id);
                setUsers(users.filter(user => user._id !== id));
                toast.success('User deleted successfully!');
            } catch (err) {
                setError('Failed to delete user. Please try again later.');
                toast.error('Failed to delete user.');
                console.error(err);
            }
        }
    };

    const handleToggleStatus = async (id, name, currentStatus) => {
        try {
            await toggleUserStatus(id);

            // Update user status in the state
            setUsers(users.map(user =>
                user._id === id ? { ...user, active: !user.active } : user
            ));

            toast.success(`User ${currentStatus ? 'disabled' : 'enabled'} successfully!`);
        } catch (err) {
            setError('Failed to update user status. Please try again later.');
            toast.error('Failed to update user status.');
            console.error(err);
        }
    };

    const handleSearch = (e) => {
        setSearchTerm(e.target.value);
    };

    if (loading) {
        return (
            <div className="d-flex justify-content-center align-items-center" style={{ height: '300px' }}>
                <Spinner animation="border" role="status" variant="primary">
                    <span className="visually-hidden">Loading users...</span>
                </Spinner>
            </div>
        );
    }

    return (
        <div>
            <Row className="mb-4 align-items-center">
                <Col>
                    <h1 className="mb-0">
                        <FaUsers className="me-2" />
                        User Management
                    </h1>
                </Col>
                <Col xs="auto">
                    <Button
                        as={Link}
                        to="/users/new"
                        variant="primary"
                    >
                        <FaPlus className="me-2" />
                        Add New User
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
                            placeholder="Search by name, email, or role..."
                            value={searchTerm}
                            onChange={handleSearch}
                        />
                    </InputGroup>

                    {filteredUsers.length === 0 ? (
                        <Alert variant="info">
                            {searchTerm ? 'No users match your search.' : 'No users found.'}
                        </Alert>
                    ) : (
                        <Table hover responsive>
                            <thead className="table-light">
                                <tr>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Role</th>
                                    <th>Status</th>
                                    <th className="text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                {filteredUsers.map(user => (
                                    <tr key={user._id}>
                                        <td className="align-middle">
                                            <strong>{user.firstName} {user.lastName}</strong>
                                        </td>
                                        <td className="align-middle">{user.email}</td>
                                        <td className="align-middle">
                                            <Badge bg={user.role === 'admin' ? 'danger' : 'info'}>
                                                {user.role}
                                            </Badge>
                                        </td>
                                        <td className="align-middle">
                                            <Badge bg={user.active ? 'success' : 'secondary'}>
                                                {user.active ? 'Active' : 'Inactive'}
                                            </Badge>
                                        </td>
                                        <td className="text-center">
                                            <Button
                                                as={Link}
                                                to={`/users/${user._id}`}
                                                variant="outline-primary"
                                                size="sm"
                                                className="me-2"
                                                title="View user details"
                                            >
                                                <FaEye />
                                            </Button>
                                            <Button
                                                as={Link}
                                                to={`/users/edit/${user._id}`}
                                                variant="outline-secondary"
                                                size="sm"
                                                className="me-2"
                                                title="Edit user"
                                            >
                                                <FaEdit />
                                            </Button>
                                            <Button
                                                onClick={() => handleToggleStatus(user._id, `${user.firstName} ${user.lastName}`, user.active)}
                                                variant={user.active ? "outline-warning" : "outline-success"}
                                                size="sm"
                                                className="me-2"
                                                title={user.active ? "Disable user" : "Enable user"}
                                            >
                                                {user.active ? <FaToggleOff /> : <FaToggleOn />}
                                            </Button>
                                            <Button
                                                onClick={() => handleDelete(user._id, `${user.firstName} ${user.lastName}`)}
                                                variant="outline-danger"
                                                size="sm"
                                                title="Delete user"
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
                    Total Users: {filteredUsers.length}
                </Card.Footer>
            </Card>
        </div>
    );
};

export default UserList;
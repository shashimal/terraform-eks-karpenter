import React from 'react';
import { Container, Row, Col, Card, Button } from 'react-bootstrap';
import { Link } from 'react-router-dom';
import { FaExclamationTriangle, FaHome } from 'react-icons/fa';

const Unauthorized = () => {
    return (
        <Container className="py-5">
            <Row className="justify-content-center">
                <Col md={8} lg={6}>
                    <Card className="shadow-sm text-center">
                        <Card.Body className="p-5">
                            <FaExclamationTriangle size={60} className="text-warning mb-4" />
                            <h1 className="mb-4">Access Denied</h1>
                            <p className="lead mb-4">
                                You don't have permission to access this page. Please contact an administrator if you believe this is an error.
                            </p>
                            <Button as={Link} to="/" variant="primary" size="lg">
                                <FaHome className="me-2" />
                                Go to Home
                            </Button>
                        </Card.Body>
                    </Card>
                </Col>
            </Row>
        </Container>
    );
};

export default Unauthorized;
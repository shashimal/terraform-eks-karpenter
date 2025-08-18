import React, { useState, useEffect } from 'react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import { getCourseById, deleteCourse, unenrollStudent } from '../services/courseService';
import { getAllStudents } from '../services/studentService';

const CourseDetail = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const [course, setCourse] = useState(null);
    const [enrolledStudents, setEnrolledStudents] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        fetchCourseAndStudents();
    }, [id]);

    const fetchCourseAndStudents = async () => {
        try {
            setLoading(true);
            const [courseData, studentsData] = await Promise.all([
                getCourseById(id),
                getAllStudents()
            ]);

            setCourse(courseData);

            // Filter students enrolled in this course
            const enrolled = studentsData.filter(student =>
                student.courses && student.courses.includes(courseData._id)
            );
            setEnrolledStudents(enrolled);

            setError(null);
        } catch (err) {
            setError('Failed to fetch data. Please try again later.');
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async () => {
        if (window.confirm('Are you sure you want to delete this course?')) {
            try {
                await deleteCourse(id);
                navigate('/courses');
            } catch (err) {
                setError('Failed to delete course. Please try again later.');
                console.error(err);
            }
        }
    };

    const handleUnenroll = async (studentId) => {
        if (window.confirm('Are you sure you want to unenroll this student?')) {
            try {
                await unenrollStudent(id, studentId);
                fetchCourseAndStudents();
            } catch (err) {
                setError('Failed to unenroll student. Please try again later.');
                console.error(err);
            }
        }
    };

    if (loading) {
        return <div className="loading">Loading course details...</div>;
    }

    if (!course) {
        return <div className="alert alert-danger">Course not found</div>;
    }

    return (
        <div>
            <div className="page-header">
                <h1>Course Details</h1>
                <div>
                    <Link to="/courses" className="btn">Back to Courses</Link>
                    <Link to={`/courses/edit/${id}`} className="btn">Edit</Link>
                    <button onClick={handleDelete} className="btn btn-danger">Delete</button>
                </div>
            </div>

            {error && <div className="alert alert-danger">{error}</div>}

            <div className="card">
                <h2>{course.title} ({course.code})</h2>
                <p><strong>Description:</strong> {course.description || 'No description available'}</p>
                <p><strong>Instructor:</strong> {course.instructor}</p>
                <p><strong>Credits:</strong> {course.credits}</p>
                <p><strong>Start Date:</strong> {course.startDate ? new Date(course.startDate).toLocaleDateString() : 'Not specified'}</p>
                <p><strong>End Date:</strong> {course.endDate ? new Date(course.endDate).toLocaleDateString() : 'Not specified'}</p>
                <p><strong>Enrollment:</strong> {course.enrolledStudents}/{course.capacity}</p>
            </div>

            <h2>Enrolled Students</h2>
            {enrolledStudents.length === 0 ? (
                <div className="card">No students enrolled in this course.</div>
            ) : (
                <table>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        {enrolledStudents.map(student => (
                            <tr key={student._id}>
                                <td>{student.firstName} {student.lastName}</td>
                                <td>{student.email}</td>
                                <td>
                                    <Link to={`/students/${student._id}`} className="btn">View</Link>
                                    <button onClick={() => handleUnenroll(student._id)} className="btn btn-danger">Unenroll</button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            )}
        </div>
    );
};

export default CourseDetail;
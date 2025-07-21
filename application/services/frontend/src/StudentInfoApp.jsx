import React, { useEffect, useState } from 'react';

export default function StudentInfoApp() {
  const [students, setStudents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('http://student/students')
      .then(response => response.json())
      .then(data => {
        setStudents(data.students);
        setLoading(false);
      })
      .catch(err => {
        setError(err.message);
        setLoading(false);
      });
  }, []);

  if (loading) return <p style={{ textAlign: 'center' }}>Loading...</p>;
  if (error) return <p style={{ textAlign: 'center', color: 'red' }}>Error: {error}</p>;

  return (
    <div style={{ maxWidth: '960px', margin: 'auto', padding: '1rem' }}>
      <h1 style={{ textAlign: 'center' }}>Student Information</h1>
      <div style={{ display: 'grid', gap: '1rem', gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))' }}>
        {students.map(student => (
          <div key={student.id} style={{ border: '1px solid #ccc', borderRadius: '8px', padding: '1rem' }}>
            <p><strong>Name:</strong> {student.firstName} {student.lastName}</p>
            <p><strong>Email:</strong> {student.email}</p>
            <p><strong>Phone:</strong> {student.phone}</p>
            <p><strong>City:</strong> {student.address.city}</p>
              {student.courses && student.courses.length > 0 && (
                  <div>
                      <p><strong>Courses:</strong></p>
                      <ul>
                          {student.courses.map((course, index) => (
                              <li key={index}>
                                  {course.title}
                              </li>
                          ))}
                      </ul>
                  </div>
              )}
          </div>
        ))}
      </div>
    </div>
  );
}

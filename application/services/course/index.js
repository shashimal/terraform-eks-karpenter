const express = require('express');
const app = express();
app.use(express.json());

let courses = [];

app.get('/courses', (req, res) => {
  res.json(courses);
});

app.post('/courses', (req, res) => {
  const course = req.body;
  courses.push(course);
  res.status(201).json(course);
});

app.listen(8081, () => console.log('Course Service on port 8081'));

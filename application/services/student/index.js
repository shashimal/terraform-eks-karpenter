const express = require('express');
const app = express();
app.use(express.json());

let students = [];

app.get('/students', (req, res) => {
  res.json(students);
});

app.post('/students', (req, res) => {
  const student = req.body;
  students.push(student);
  res.status(201).json(student);
});

app.put('/students/:id', (req, res) => {
  const { id } = req.params;
  const index = students.findIndex(s => s.id == id);
  if (index !== -1) {
    students[index] = req.body;
    res.json(students[index]);
  } else {
    res.status(404).send('Student not found');
  }
});

app.delete('/students/:id', (req, res) => {
  const { id } = req.params;
  students = students.filter(s => s.id != id);
  res.send('Deleted');
});

app.post('/students/:id/assign-course', (req, res) => {
  const { id } = req.params;
  const { courseId } = req.body;
  const student = students.find(s => s.id == id);
  if (student) {
    student.courseId = courseId;
    res.json(student);
  } else {
    res.status(404).send('Student not found');
  }
});

app.listen(8082, () => console.log('Student Service on port 8082'));

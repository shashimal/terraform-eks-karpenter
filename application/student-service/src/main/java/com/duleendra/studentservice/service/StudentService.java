package com.duleendra.studentservice.service;

import com.duleendra.studentservice.entity.Student;
import com.duleendra.studentservice.repository.StudentRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class StudentService {

    final StudentRepository studentRepository;

    public StudentService(StudentRepository studentRepository) {
        this.studentRepository = studentRepository;
    }

    public Iterable<Student> getStudents() {
        return studentRepository.findAll();
    }

    public Optional<Student>  getStudentById(Long id) {
        return studentRepository.findById(id);
    }

    public Student save(Student student) {
        System.out.println(student.toString());
        return studentRepository.save(student);
    }

    public void deleteById(Long id) {
        studentRepository.deleteById(id);
    }
}

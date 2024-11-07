const express = require('express');
const router = express.Router();
const studentController = require('../controllers/student.controller');

// 학생 목록 조회
router.get('/', studentController.getStudents);

// 학생 추가
router.post('/create', studentController.createStudent);

// DELETE /api/students/:id
router.delete('/:id', studentController.deleteStudent);

module.exports = router; 
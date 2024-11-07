const Student = require('../models/student.model');

// 학생 목록 조회
exports.getStudents = async (req, res) => {
  try {
    const students = await Student.find().sort({ grade: 1 });
    res.json(students);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 학생 추가
exports.createStudent = async (req, res) => {
  const { name, studentId, grade } = req.body;

  try {
    // 중복된 학생 ID 확인
    const existingStudent = await Student.findOne({ studentId });
    if (existingStudent) {
      return res.status(400).json({ message: '이미 존재하는 학생 ID입니다.' });
    }

    const student = new Student({ name, studentId, grade });
    const newStudent = await student.save();
    res.status(201).json(newStudent);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// 학생 삭제
exports.deleteStudent = async (req, res) => {
  try {
      const student = await Student.findByIdAndDelete(req.params.id);
      if (!student) {
          return res.status(404).json({ 
              success: false, 
              message: '학생을 찾을 수 없습니다' 
          });
      }
      res.status(200).json({ 
          success: true, 
          message: '학생이 성공적으로 삭제되었습니다' 
      });
  } catch (error) {
      res.status(500).json({ 
          success: false, 
          message: error.message 
      });
  }
};
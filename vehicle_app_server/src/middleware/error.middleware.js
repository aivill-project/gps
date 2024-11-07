module.exports = (err, req, res, next) => {
  const status = err.status || 500;
  const message = err.message || '서버 에러가 발생했습니다.';
  
  res.status(status).json({
    status: 'error',
    message
  });
};
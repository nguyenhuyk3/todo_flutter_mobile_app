// ignore_for_file: constant_identifier_names

enum ErrorInformation {
  // Authentication
  EMPTY_PASSWORD(message: 'Mật khẩu không được bỏ trống'),
  EMPTY_CONFIRMED_PASSWORD(message: 'Mật khẩu xác nhận không được bỏ trống'),
  CONFIRMED_PASSWORD_MISSMATCH(message: 'Mật khẩu xác nhận không khớp'),
  EMPTY_FULL_NAME(message: 'Họ và tên không được bỏ trống'),

  EMAIL_CAN_NOT_BE_BLANK(message: 'Email không được bỏ trống'),
  INVALID_EMAIL(message: 'Email không hợp lệ'),
  EMAIL_NOT_EXISTS(message: 'Email không tồn tại trong hệ thống'),
  EMAIL_ALREADY_EXISTS(message: 'Email đã được sử dụng'),
  // Password strength
  PASSWORD_CAN_NOT_BE_BLANK(message: 'Mật khẩu không được bỏ trống'),
  CONFIRMED_PASSWORD_MISMATCH(message: 'Mật khẩu xác nhận không khớp'),
  PASSWORD_TOO_SHORT(message: 'Mật khẩu phải có ít nhất 8 ký tự'),
  PASSWORD_MISSING_LOWERCASE(message: 'Mật khẩu phải chứa chữ thường'),
  PASSWORD_MISSING_UPPERCASE(message: 'Mật khẩu phải chứa chữ hoa'),
  PASSWORD_MISSING_NUMBER(message: 'Mật khẩu phải chứa ít nhất một chữ số'),
  PASSWORD_MISSING_SPECIAL_CHAR(message: 'Mật khẩu phải chứa ký tự đặc biệt'),
  SAME_PASSWORD(message: 'Mật khẩu phải khác với mật khẩu cũ'),
  // OTP / Auth
  OTP_TOO_MANY_REQUESTS(message: 'Bạn đã yêu cầu mã OTP quá nhiều lần'),
  OTP_INVALID(message: 'Mã OTP không hợp lệ hoặc đã hết hạn'),
  OTP_SEND_FAILED(message: 'Không thể gửi mã OTP'),
  AUTH_INVALID_CREDENTIALS(message: 'Thông tin đăng nhập không hợp lệ'),
  OTP_EXPIRED(message: 'Mã OTP đã hết hạn'),
  OTP_VERIFY_FAILED(message: 'Xác thực OTP thất bại'),
  // Password
  PASSWORD_UPDATE_FAILED(message: 'Cập nhật mật khẩu thất bại'),
  // Database
  DB_NOT_NULL_VIOLATION(message: 'Thiếu dữ liệu bắt buộc'),
  DB_FOREIGN_KEY_VIOLATION(message: 'Dữ liệu liên kết không tồn tại'),
  DB_INVALID_FORMAT(message: 'Dữ liệu không đúng định dạng'),
  DB_PERMISSION_DENIED(message: 'Không có quyền thực hiện thao tác'),
  DB_RLS_VIOLATION(message: 'Dữ liệu bị chặn bởi chính sách bảo mật'),
  // Todo
  EMPTY_TITLE(message: 'Tiêu đề không được bỏ trống'),
  EMPTY_DESCRIPTION(message: 'Mô tả không được bỏ trống'),
  EMPTY_DATE_RANGE(message: 'Khoảng thời gian không được bỏ trống'),
  EMPTY_REMINDER_TIME(message: 'Thời gian nhắc nhở không được bỏ trống'),

  UNDEFINED_ERROR(message: 'Lỗi không xác định được');

  final String message;

  const ErrorInformation({required this.message});
}

class Failure {
  final ErrorInformation _error;
  final Object? _details;

  const Failure({required ErrorInformation error, Object? details})
    : _error = error,
      _details = details;

  String get message => _error.message;
  Object? get details => _details;
}

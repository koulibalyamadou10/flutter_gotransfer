import 'http_exception.dart';

class UnauthorizedException extends HttpException {
  UnauthorizedException(String message) : super(message, statusCode: 401);
}
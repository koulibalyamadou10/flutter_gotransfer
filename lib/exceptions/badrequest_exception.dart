import 'http_exception.dart';

class BadRequestException extends HttpException {
  BadRequestException(String message) : super(message, statusCode: 400);
}
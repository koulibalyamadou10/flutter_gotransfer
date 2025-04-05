import 'http_exception.dart';

class NotFoundException extends HttpException {
  NotFoundException(String message) : super(message, statusCode: 404);
}
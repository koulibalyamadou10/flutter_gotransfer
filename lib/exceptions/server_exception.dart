import 'http_exception.dart';

class ServerException extends HttpException {
  ServerException(String message) : super(message, statusCode: 500);
}
class ApiConfig {
  static const String protocol = 'http';
  static const String port = ':8000';
  static const String host = '192.168.100.2';

  static const String apiKey = '54ba8b90cf719f673b689cd6';

  static const String loginEndpoint = '${protocol}://${host}${port}/account/login/';
  static const String getUserEndpoint = '${protocol}://${host}${port}/account/get_user/';
  static const String registerEndpoint = '${protocol}://${host}${port}/account/register/';
  static const String apiTokenEndpoint = '${protocol}://${host}${port}/api/token/';
  static const String apiTokenRefreshEndpoint = '${protocol}://${host}${port}/api/token/refresh/';

  static const String addDestinataireEndpoint = '${protocol}://${host}${port}/destinataire/';

  static const String paymentEndpoint = '/payments';
  static const String transferEndpoint = '/transfers';
  static const String eWalletEndpoint = '/ewallet';
}
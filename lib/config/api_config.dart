class ApiConfig {
  static const String protocol = 'http';
  static const String port = ':8000';
  static const String host = '192.168.43.134';

  static const String apiKey = '54ba8b90cf719f673b689cd6';
  static const String loginEndpoint = '${protocol}://${host}${port}/auth/login';
  static const String registerEndpoint = '${protocol}://${host}${port}/auth/register';
  static const String paymentEndpoint = '/payments';
  static const String transferEndpoint = '/transfers';
  static const String eWalletEndpoint = '/ewallet';
}
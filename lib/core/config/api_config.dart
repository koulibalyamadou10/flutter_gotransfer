class ApiConfig {
  static const String protocol = 'http';
  static const String port = ':8005';
  static const String host = '172.28.112.1';

  static const String apiKey = 'YOUR_API_KEY_HERE';
  static const String loginEndpoint = '${protocol}://${host}${port}/auth/login';
  static const String registerEndpoint = '${protocol}://${host}${port}/auth/register';
  static const String paymentEndpoint = '/payments';
  static const String transferEndpoint = '/transfers';
  static const String eWalletEndpoint = '/ewallet';
}
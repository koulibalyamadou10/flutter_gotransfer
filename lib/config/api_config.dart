class ApiConfig {
  static const String protocol = 'http';
  static const String port = ':8000';
  static const String host = '192.168.100.2';

  static const String baseUrl = '${protocol}://${host}${port}';

  static const String apiKey = '54ba8b90cf719f673b689cd6';

  static const String loginEndpoint = '${protocol}://${host}${port}/account/login/';
  static const String getUserEndpoint = '${protocol}://${host}${port}/account/get_user/';
  static const String registerEndpoint = '${protocol}://${host}${port}/account/register/';
  static const String apiTokenEndpoint = '${protocol}://${host}${port}/api/token/';
  static const String apiTokenRefreshEndpoint = '${protocol}://${host}${port}/api/token/refresh/';

  static const String addDestinataireEndpoint = '${protocol}://${host}${port}/beneficiary/register/';
  static const String getCountryCodeEndpoint = '${protocol}://${host}${port}/beneficiary/get_country_code/';
  static const String getXRateEndpoint = '${protocol}://${host}${port}/xrate/convert/';

  static const String addRemittanceEndpoint = '${protocol}://${host}${port}/remittance/';
  
  static const String addTopupEndpoint = '${protocol}://${host}${port}/topup/create/';
  static const String listProductTopupEndpoint = '${protocol}://${host}${port}/topup/products/';

  // url de config


  static const String paymentEndpoint = '/payments';
  static const String transferEndpoint = '/transfers';
  static const String eWalletEndpoint = '/ewallet';
}
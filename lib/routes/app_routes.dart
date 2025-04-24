import 'package:flutter/material.dart';

import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/auth/register_page.dart';
import '../presentation/pages/bank_cards_page/bank_cards_page.dart';
import '../presentation/pages/history_page/history_page.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/home/home_screen.dart';
import '../presentation/pages/money_transfer_page/money_transfer_page.dart';
import '../presentation/pages/personal_info_page/personal_info_page.dart';
import '../presentation/pages/qr_scanner_page/qr_scanner_page.dart';
import '../presentation/pages/recharge_page/recharge_page.dart';
import '../presentation/pages/splash/splash_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String homescreen = '/homescreen';
  static const String card = '/cartes';
  static const String info = '/info';
  static const String quick_transfer = '/quick-transfer';
  static const String qr_code = '/qr-code';
  static const String mobile_topup = '/mobile-topup';
  static const String historique = '/historique';
  static const String plus = '/plus';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => SplashPage(),
    login: (context) => LoginPage(),
    register: (context) => RegisterPage(),
    home: (context) => HomePage(),
    homescreen: (context) => HomeScreen(),
    card: (context) => BankCardsPage(),
    info: (context) => PersonalInfoPage(),
    quick_transfer: (context) => MoneyTransferPage(),
    qr_code: (context) => QrScannerPage(),
    mobile_topup: (context) => RechargePage(),
    historique: (context) => HistoryPage()
  };
}

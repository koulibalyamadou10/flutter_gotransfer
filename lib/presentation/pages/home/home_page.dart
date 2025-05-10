import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:gotransfer/core/constants/dimensions.dart';
import 'package:gotransfer/data/models/user_model.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import 'package:gotransfer/presentation/pages/digital_banking_page/digital_banking_page.dart';
import 'package:gotransfer/presentation/pages/digital_payments_page/digital_payments_page.dart';
import 'package:gotransfer/presentation/pages/home/home_screen.dart';
import 'package:gotransfer/presentation/pages/money_transfer_page/money_transfer_page.dart';
import 'package:gotransfer/presentation/pages/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageController = PageController(initialPage: 0);
  final _controller = NotchBottomBarController();

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    HomeScreen(),
    MoneyTransferPage(),
    DigitalPaymentsPage(),
    ProfilePage(),
  ];

  late ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          _pages.length,
              (index) => _pages[index],
        ),
      ),
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: colorScheme.primary,
        showLabel: true,
        shadowElevation: 2,
        kBottomRadius: 5,
        notchColor: colorScheme.primary,
        removeMargins: false,
        bottomBarWidth: 500,
        durationInMilliSeconds: 300,
        itemLabelStyle: TextStyle(color: Colors.white),
        bottomBarItems: [
          BottomBarItem(
            inActiveItem: Icon(
              Icons.home_outlined,
              color: Colors.white,
              size: AppDimensions.bottomNavigationBarInactiveIconSize,
            ),
            activeItem: Icon(
              Icons.home_filled,
              color: Colors.white,
              size: AppDimensions.bottomNavigationBarActiveIconSize,
            ),
            itemLabel: 'Accueil',
          ),
          BottomBarItem(
            inActiveItem: FaIcon(
              FontAwesomeIcons.moneyBillTransfer,
              color: Colors.white,
              size: AppDimensions.bottomNavigationBarInactiveIconSize,
            ),
            activeItem: FaIcon(
              FontAwesomeIcons.moneyBillTransfer,
              color: Colors.white,
              size: AppDimensions.bottomNavigationBarActiveIconSize,
            ),
            itemLabel: 'Transfert',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.credit_card_outlined,
              color: Colors.white,
              size: AppDimensions.bottomNavigationBarInactiveIconSize,
            ),
            activeItem: Icon(
              Icons.phone,
              color: Colors.white,
              size: AppDimensions.bottomNavigationBarActiveIconSize,
            ),
            itemLabel: 'Topup',
          ),
          BottomBarItem(
            inActiveItem: Icon(
              Icons.person_outline,
              color: Colors.white,
              size: AppDimensions.bottomNavigationBarInactiveIconSize,
            ),
            activeItem: Icon(
              Icons.person,
              color: Colors.white,
              size: AppDimensions.bottomNavigationBarActiveIconSize,
            ),
            itemLabel: 'Profil',
          ),
        ],
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
        kIconSize: 14,
      ),
    );
  }
}
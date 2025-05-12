import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gotransfer/core/utils/helpers.dart';
import 'package:gotransfer/data/repositories/reference_repository.dart';
import 'package:gotransfer/data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;
  late Animation<Color?> _gradientAnimation;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuint),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    Future.delayed(2500.ms, () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        /*UserRepository.getUserEmail().then((onValue) async {
          String email = onValue;
          if( email.isEmpty )
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          else {
            String password = (await UserRepository.getUserPasswordHashed());
            print('password : $password');
            UserRepository.apiToken(
              context,
              email: email,
              password: Helpers.decrypt(password)
            );
          }
        });*/
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    colorScheme = theme.colorScheme;

    _gradientAnimation = ColorTween(
      begin: colorScheme.primary,
      end: colorScheme.secondary,
    ).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: SweepGradient(
                  center: Alignment.center,
                  startAngle: 0,
                  endAngle: _controller.value.clamp(0.01, 1.0) * 2 * 3.1416,
                  colors: [
                    theme.colorScheme.secondary.withOpacity(0.9),
                    theme.colorScheme.secondary.withOpacity(0.7),
                    theme.colorScheme.secondary.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DotsPainter(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        progress: _controller.value,
                      ),
                    ),
                  ),
        
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'app-logo',
                          child: Material(
                            color: Colors.transparent,
                            child: Animate(
                              effects: [
                                ScaleEffect(
                                  duration: 800.ms,
                                  curve: Curves.elasticOut,
                                ),
                                FadeEffect(duration: 500.ms),
                              ],
                              child: Container(
                                width: 150,
                                height: 150,
                                child: Image.asset(
                                  'assets/logo/original-logo-symbol.png',
                                  //'assets/images/wbg/gotransfer.png',
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'GoTransfer',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onBackground,
                            shadows: [
                              BoxShadow(
                                color: theme.colorScheme.onBackground.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .shimmer(
                          delay: 800.ms,
                          duration: 1500.ms,
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        )
                            .slideY(
                          begin: 0.3,
                          duration: 800.ms,
                          curve: Curves.decelerate,
                        ),
                      ],
                    ),
                  ),
        
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Text(
                          'La banque de demain, aujourd\'hui',
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ).animate().fadeIn(delay: 1000.ms),
                        const SizedBox(height: 12),
                        // Text(
                        //   'Version 1.0.0',
                        //   style: TextStyle(
                        //     color: theme.colorScheme.onBackground.withOpacity(0.7),
                        //     fontSize: 12,
                        //   ),
                        // ).animate().fadeIn(delay: 1500.ms),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color color;
  final double progress;

  const _DotsPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const radius = 1.5;
    const spacing = 30.0;
    final offset = progress * spacing * 2;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final dx = x - offset % spacing;
        final dy = y - offset % spacing;
        canvas.drawCircle(Offset(dx, dy), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
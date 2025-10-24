import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:movie_info_app/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Fade-in animation setup
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Scale animation for logo
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Slide animation for text
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations in sequence
    _startAnimations();

    // Navigate after 5 seconds to show the full animation
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MyHomePage(),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  void _startAnimations() async {
    await _fadeController.forward();
    await _scaleController.forward();
    await _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    // Responsive calculations
    final isTablet = width > 600;
    final isDesktop = width > 900;

    // Dynamic sizing based on screen size
    final animationSize = isDesktop
        ? width * 0.25
        : isTablet
        ? width * 0.3
        : width * 0.4;

    final appNameFont = isDesktop
        ? 48.0
        : isTablet
        ? 36.0
        : width * 0.08;

    final taglineFont = isDesktop
        ? 18.0
        : isTablet
        ? 16.0
        : width * 0.045;

    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff09203f),
              Color(0xff537895),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            ...List.generate(5, (index) => _buildFloatingElement(width, height, index)),

            // Main content
            FadeTransition(
              opacity: _fadeIn,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cool Movie Animation
                    _buildCoolMovieAnimation(animationSize),

                    SizedBox(height: height * 0.04),

                    // App Name with slide animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        "MovieHub",
                        style: TextStyle(
                          fontSize: appNameFont,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.02),

                    // Tagline with slide animation
                    SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        "Discover • Watch • Enjoy Top Movies",
                        style: TextStyle(
                          fontSize: taglineFont,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.08),

                    // Cool Loading Animation
                    buildCoolLoadingIndicator(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoolMovieAnimation(double size) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 4), // Longer duration
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Multiple rotating rings with different speeds
            Transform.rotate(
              angle: value * 4 * 3.14159, // 2 full rotations
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: -value * 3 * 3.14159, // Counter-rotation
              child: Container(
                width: size * 0.8,
                height: size * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Glowing dots around the ring
                    ...List.generate(12, (index) {
                      final angle = (index * 30) * (3.14159 / 180);
                      final radius = size * 0.35;
                      return Positioned(
                        left: size * 0.4 + radius * math.cos(angle) - 4,
                        top: size * 0.4 + radius * math.sin(angle) - 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Pulsing center movie icon
            Transform.scale(
              scale: 0.3 + (value * 0.7) + (math.sin(value * 4 * 3.14159) * 0.1),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.movie_creation_outlined,
                  color: Colors.white,
                  size: size * 0.3,
                ),
              ),
            ),
            // Floating particles
            ...List.generate(8, (index) {
              final angle = (index * 45) * (3.14159 / 180);
              final radius = size * 0.4 + (math.sin(value * 2 * 3.14159 + index) * 15);
              final particleSize = 3 + (math.sin(value * 3 * 3.14159 + index) * 2);
              return Positioned(
                left: size * 0.5 + radius * math.cos(angle) - particleSize,
                top: size * 0.5 + radius * math.sin(angle) - particleSize,
                child: Container(
                  width: particleSize,
                  height: particleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Film strip effects
            Transform.translate(
              offset: Offset(-size * 0.4, 0),
              child: Opacity(
                opacity: 0.4 + (math.sin(value * 6 * 3.14159) * 0.3),
                child: Container(
                  width: size * 0.25,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(size * 0.4, 0),
              child: Opacity(
                opacity: 0.4 + (math.sin(value * 6 * 3.14159 + 3.14159) * 0.3),
                child: Container(
                  width: size * 0.25,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  Widget _buildFloatingElement(double width, double height, int index) {
    return Positioned(
      left: width * (0.05 + (index * 0.2)),
      top: height * (0.05 + (index * 0.15)),
      child: TweenAnimationBuilder<double>(
        duration: Duration(seconds: 3 + index),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 15 * value),
            child: Opacity(
              opacity: 0.1 + (0.1 * value),
              child: Container(
                width: 40 + (index * 8),
                height: 40 + (index * 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
Widget buildCoolLoadingIndicator() {
  return TweenAnimationBuilder<double>(
    duration: const Duration(seconds: 3),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, value, child) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Outer rotating ring with gradient
          Transform.rotate(
            angle: value * 2 * 3.14159,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // Inner pulsing ring
          Transform.scale(
            scale: 0.7 + (math.sin(value * 4 * 3.14159) * 0.1),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

          // Center dot with breathing effect
          Transform.scale(
            scale: 0.5 + (math.sin(value * 6 * 3.14159) * 0.3),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

          // Orbiting dots
          ...List.generate(4, (index) {
            final angle = (value * 2 * 3.14159) + (index * 3.14159 / 2);
            final radius = 18.0;
            final dotSize = 3 + (math.sin(value * 4 * 3.14159 + index) * 1.5);
            return Positioned(
              left: radius * math.cos(angle) - dotSize,
              top: radius * math.sin(angle) - dotSize,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 2,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            );
          }),

          // Loading text
          Positioned(
            bottom: -15,
            child: Opacity(
              opacity: 0.8,
              child: Text(
                "",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

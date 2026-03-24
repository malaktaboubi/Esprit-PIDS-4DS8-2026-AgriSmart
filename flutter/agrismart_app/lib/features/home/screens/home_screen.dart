import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/services/auth_service.dart';

class FarmerHomeScreen extends StatelessWidget {
  const FarmerHomeScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
  }

  Widget _featureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color accent,
    bool showDot = false,
  }) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 0.82,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B2516), Color(0xFF132E1F)],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (showDot)
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.7),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white.withValues(alpha: 0.92), size: 64),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.45,
            colors: [Color(0xFF123F20), Color(0xFF041C10), Color(0xFF03140B)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AGRISMART HUB',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 4,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        
                        const SizedBox(width: 8),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF27F72A),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF27F72A).withValues(alpha: 0.75),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          tooltip: 'Logout',
                          onPressed: () => _handleLogout(context),
                          icon: const Icon(Icons.logout_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _featureCard(
                            context: context,
                            icon: Icons.water_drop_rounded,
                            title: 'WATER',
                            accent: const Color(0xFF3B82F6),
                            showDot: true,
                          ),
                          const SizedBox(width: 16),
                          _featureCard(
                            context: context,
                            icon: Icons.satellite_alt_rounded,
                            title: 'MAP',
                            accent: const Color(0xFFA3E635),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _featureCard(
                            context: context,
                            icon: Icons.center_focus_strong_rounded,
                            title: 'SCAN',
                            accent: const Color(0xFF65E570),
                          ),
                          const SizedBox(width: 16),
                          _featureCard(
                            context: context,
                            icon: Icons.pets_rounded,
                            title: 'ANIMALS',
                            accent: const Color(0xFF22FF41),
                            showDot: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Container(
                        height: 94,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(48),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF0D2A1A), Color(0xFF163824)],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 18),
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22FF1A),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF22FF1A).withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.mic_rounded, size: 42, color: Colors.black),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'TALK',
                                  style: TextStyle(
                                    color: Color(0xFF22FF1A),
                                    fontSize: 50,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

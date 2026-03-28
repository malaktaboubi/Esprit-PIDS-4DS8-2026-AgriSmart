import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';
import '../../auth/services/auth_service.dart';

class ConsultantDashboardScreen extends StatefulWidget {
  const ConsultantDashboardScreen({super.key});

  @override
  State<ConsultantDashboardScreen> createState() => _ConsultantDashboardScreenState();
}

class _ConsultantDashboardScreenState extends State<ConsultantDashboardScreen> {
  int _selectedNavIndex = 0;

  Future<void> _handleLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1E12),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header with greeting and notification
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF27F72A), width: 2),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[700],
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monday, Oct 24',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Good Morning, Silas',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.notifications_rounded, color: Colors.white, size: 24),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF27F72A),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF27F72A).withValues(alpha: 0.75),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        
                        IconButton(
                          tooltip: 'Logout',
                          icon: const Icon(Icons.logout_rounded, color: Colors.white),
                          onPressed: _handleLogout,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        title: 'WATER USAGE',
                        value: '850L',
                        change: '-5% VS AVG',
                        changeColor: Colors.red,
                        icon: Icons.water_drop_rounded,
                        hasProgress: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        title: 'YIELD EST.',
                        value: '4.2 Tons',
                        change: '+12% EXPECTED',
                        changeColor: const Color(0xFF27F72A),
                        icon: Icons.eco_rounded,
                        hasChart: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Critical Alerts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_rounded, color: Color(0xFFFF9800), size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Critical Alerts',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '1 New',
                          style: TextStyle(
                            color: const Color(0xFFFF9800).withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                          width: 2,
                        ),
                        color: const Color(0xFF2A1810),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              color: const Color(0xFFFF9800),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DISEASE ALERT: SECTOR 4',
                                      style: TextStyle(
                                        color: const Color(0xFFFF9800).withValues(alpha: 0.7),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Potential Blight detected',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'AI Scanner identified early-stage blight in tomato crops. Immediate action required.',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF9800),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'VIEW DETAILS',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Icon(Icons.arrow_forward, size: 14, color: Colors.black),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Icon(
                                  Icons.spa_rounded,
                                  color: const Color(0xFF27F72A).withValues(alpha: 0.6),
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _quickActionCard(
                          icon: Icons.home_rounded,
                          iconColor: Colors.blue,
                          title: 'Irrigation',
                          subtitle: 'Scheduled: 6 PM',
                        ),
                        _quickActionCard(
                          icon: Icons.center_focus_strong_rounded,
                          iconColor: const Color(0xFF27F72A),
                          title: 'AI Scanner',
                          subtitle: 'Diagnose Crops',
                          onTap: () => GoRouter.of(context).push('/crop-health'),
                        ),
                        _quickActionCard(
                          icon: Icons.layers_rounded,
                          iconColor: const Color(0xFFFF9800),
                          title: 'Farm Map',
                          subtitle: '4 Active Zones',
                        ),
                        _quickActionCard(
                          icon: Icons.smart_toy_rounded,
                          iconColor: Colors.purple,
                          title: 'AI Advisor',
                          subtitle: 'Ask questions',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Weather
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    color: const Color(0xFF113A1F),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFB800), size: 24),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '24°C Sunny',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Perfect for harvesting today',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF27F72A),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF27F72A).withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.mic_rounded, color: Colors.black, size: 32),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedNavIndex,
          backgroundColor: const Color(0xFF0A1E12),
          selectedItemColor: const Color(0xFF27F72A),
          unselectedItemColor: Colors.white.withValues(alpha: 0.4),
          onTap: (index) {
            setState(() {
              _selectedNavIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_3x3_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors_rounded),
              label: 'Sensors',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String change,
    required Color changeColor,
    required IconData icon,
    bool hasProgress = false,
    bool hasChart = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        color: const Color(0xFF113A1F),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Icon(icon, color: const Color(0xFF27F72A), size: 14),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                changeColor == Colors.red ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                color: changeColor,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  color: changeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (hasProgress) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.6,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27F72A)),
                minHeight: 6,
              ),
            ),
          ],
          if (hasChart) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => Container(
                  width: 12,
                  height: 24 + (index * 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: [2, 3, 4].contains(index)
                        ? const Color(0xFF27F72A)
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        color: const Color(0xFF113A1F),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: iconColor.withValues(alpha: 0.2),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

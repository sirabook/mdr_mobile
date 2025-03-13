import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:mdr_mobile/users/profile_screen.dart';
import 'package:mdr_mobile/users/login_screen.dart';
import 'package:mdr_mobile/users/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBars extends StatelessWidget implements PreferredSizeWidget {
  final int notificationCount;
  final VoidCallback onNotificationTap;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String  userId;
  const AppBars({
    Key? key,
    required this.notificationCount,
    required this.onNotificationTap,
    required this.scaffoldKey,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 255, 240, 199),
      child: Padding(
        padding: EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Row(
          
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildIconWithBorder(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  onTap: () => scaffoldKey.currentState?.openDrawer(),
                ),
                const SizedBox(width: 10),
                _buildIconWithBorder(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications, color: Colors.white, size: 30),
                      if (notificationCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: badges.Badge(
                            badgeContent: Text(
                              '$notificationCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            badgeStyle: const badges.BadgeStyle(badgeColor: Colors.red),
                          ),
                        ),
                    ],
                  ),
                  onTap: onNotificationTap,
                ),
              ],
            ),
            PopupMenuButton<int>(
              icon: const Icon(Icons.account_circle, color: Color(0xFF1B4D41), size: 50),
              color: Colors.white,
              onSelected: (value) async {
                switch (value) {
                  case 1:
                    Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen(userId: userId)),
                    );
                    break;
                  case 2:
                    Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen(userId: userId)),
                    );
                    break;
                  case 3:
                    await FirebaseAuth.instance.signOut();
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 1, child: Text('Profile')),
                const PopupMenuItem(value: 2, child: Text('Settings')),
                const PopupMenuItem(value: 3, child: Text('Logout')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithBorder({
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4D41),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: icon,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
import 'package:flutter/material.dart';
import 'user_home_screen.dart';
import 'profile_screen.dart';
import 'user_notifications_screen.dart';
import 'settings_screen.dart'; // Import the settings screen
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  final String userLocation;
  final String userId;
  final String userName;

  const MainScreen({
    super.key,
    required this.userLocation,
    required this.userId,
    required this.userName,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final screens = [
      UserHomeScreen(userLocation: widget.userLocation),
      ProfileScreen(collection: 'users', docId: widget.userId),
      UserNotificationsScreen(userId: widget.userId),
      SettingsScreen(), // This is your settings tab
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown[800],
        unselectedItemColor: Colors.brown[300],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFFF8F6F0),
      ),
    );
  }
}
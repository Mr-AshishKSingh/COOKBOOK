import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cook_requests_screen.dart';
import 'profile_screen.dart';
import 'cook_notifications_screen.dart'; // Make sure this file exists and defines CookNotificationsScreen
// import your cook home screen if you have one

class CookMainScreen extends StatefulWidget {
  final String cookId;
  final String cookName;

  const CookMainScreen({
    super.key,
    required this.cookId,
    required this.cookName,
  });

  @override
  State<CookMainScreen> createState() => _CookMainScreenState();
}

class _CookMainScreenState extends State<CookMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      CookRequestsScreen(),
      ProfileScreen(collection: 'cooks', docId: widget.cookId),
      CookNotificationsScreen(cookId: widget.cookId), // You need to implement this
      const Center(child: Text('Settings')),
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
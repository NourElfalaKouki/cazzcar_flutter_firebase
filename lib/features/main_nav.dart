import 'package:flutter/material.dart';
import 'buyer/home_screen.dart';
import 'seller/my_ads_screen.dart';
import 'chat/chat_list_screen.dart';
import 'profile/profile_screen.dart'; 

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // The 4 Main Tabs of your App
  final List<Widget> _pages = [
    const HomeScreen(),     // 0: Buyer
    const MyAdsScreen(),    // 1: Seller
    const ChatListScreen(), // 2: Inbox
    const ProfileScreen(),  // 3: Account/Logout
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search), 
            label: 'Buy'
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline), 
            selectedIcon: Icon(Icons.add_circle),
            label: 'Sell'
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline), 
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Inbox'
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline), 
            selectedIcon: Icon(Icons.person),
            label: 'Profile'
          ),
        ],
      ),
    );
  }
}
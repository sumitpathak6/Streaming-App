import 'package:flutter/material.dart';
import 'package:twitch_clone/screens/feed_screen.dart';
import 'package:twitch_clone/screens/go_live_screen.dart';
import 'package:twitch_clone/util/colors.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  List<Widget> pages = [
    const FeedScreen(),
    const GoLiveScreen(),
    const Center(child: Text('Browse')),
  ];
  onPageChange(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: buttonColor,
        unselectedItemColor: primaryColor,
        backgroundColor: backgroundColor,
        unselectedFontSize: 12,
        onTap: onPageChange,
        currentIndex: _page,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Followings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_rounded), label: 'Go LIVE'),
          BottomNavigationBarItem(icon: Icon(Icons.copy), label: 'Browse')
        ],
      ),
      body: pages[_page],
    );
  }
}

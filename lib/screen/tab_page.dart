import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location_share/provider/user_provider.dart';
import 'package:location_share/screen/home.dart';
import 'package:location_share/services/login_api.dart';
import 'package:location_share/widget/assets.dart';
import 'package:provider/provider.dart';
import 'user_info_page.dart';
import 'main_service_page.dart';

class TabPage extends StatefulWidget {
  const TabPage({Key? key}) : super(key: key);

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    MainServicePage(),
    UserInfoPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      try {
        await LoginApi().getUserInfo(userProvider);
      } on TimeoutException catch (e) {
        Assets().showErrorSnackBar(context, e.message);
      } catch (e) {
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Main Service',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User Info',
          ),
        ],
      ),
    );
  }
}

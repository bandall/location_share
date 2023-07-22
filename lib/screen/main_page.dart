import 'package:flutter/material.dart';
import 'package:location_share/provider/user_provider.dart';
import 'package:location_share/screen/login_page.dart';
import 'package:location_share/screen/tab_page.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (!userProvider.isLoaded) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (userProvider.username != null) {
              return const TabPage();
            } else {
              return const LoginPage();
            }
          }
        },
      ),
    );
  }
}

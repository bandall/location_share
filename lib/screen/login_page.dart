import 'package:flutter/material.dart';
import 'package:location_share/provider/user_provider.dart';
import 'package:location_share/screen/login.dart';
import 'package:location_share/services/oauth_api.dart';
import 'package:location_share/widget/assets.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isLoginExpired) {
        Assets().showErrorSnackBar(context, "로그인 토큰이 만료되었습니다. 다시 로그인해주세요.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6E8EFB),
                Color(0xFFB293FC),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        width: 140,
                        height: 140,
                      ),
                      const Icon(
                        Icons.location_on,
                        size: 80,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    // decoration: BoxDecoration(
                    //   color: Colors.white.withOpacity(0.8),
                    //   borderRadius: const BorderRadius.all(
                    //     Radius.circular(25),
                    //   ),
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: Colors.black.withOpacity(0.1),
                    //       blurRadius: 10,
                    //       offset: const Offset(0, 4),
                    //     ),
                    //   ],
                    // ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 30,
                    ),
                    child: const Text(
                      '위치 공유 플랫폼',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Ink(
                    decoration: ShapeDecoration(
                      color: const Color(0xFFfee500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: InkWell(
                      onTap: _loading
                          ? null
                          : () async {
                              setState(() {
                                _loading = true;
                              });
                              bool hasError = await OAuthApi()
                                  .signInWithKakao(context, userProvider);
                              if (!hasError) {
                                if (!mounted) return;
                                Assets().showErrorSnackBar(
                                    context, "로그인 중 오류가 발생했습니다.");
                              }
                              setState(() {
                                _loading = false;
                              });
                            },
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'images/kakao_login_button.png',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                            fontSize: 15, fontFamily: 'Poppins'),
                      ),
                      onPressed: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IdPwLoginPage(),
                          ),
                        ),
                      },
                      child: const Row(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.mail_outline, color: Colors.black),
                              SizedBox(width: 10),
                            ],
                          ),
                          Expanded(
                            child: Text(
                              '이메일로 로그인',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
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
        ),
      ),
    );
  }
}

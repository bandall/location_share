import 'package:flutter/material.dart';
import 'package:location_share/provider/user_provider.dart';
import 'package:location_share/screen/component/assets.dart';
import 'package:location_share/screen/id_pw_login.dart';
import 'package:location_share/services/oauth_api.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isLoginExpired) {
        Assets().showErrorSnackBar(context, "로그인 토큰이 만료되었습니다. 다시 로그인해주세요.");
        userProvider.updateLoginExpired(false, false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.location_on,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 30,
                  ),
                  child: const Text(
                    '위치 공유 플랫폼',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
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
                    onTap: () async {
                      bool hasError = await OAuthApi()
                          .signInWithKakao(context, userProvider);
                      if (!hasError) {
                        if (!mounted) return;
                        Assets()
                            .showErrorSnackBar(context, "로그인 중 오류가 발생했습니다.");
                      }
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
                        borderRadius: BorderRadius.circular(6),
                      ),
                      textStyle:
                          const TextStyle(fontSize: 15, fontFamily: 'Poppins'),
                    ),
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IdPwLoginPage(),
                        ),
                      ),
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.mail_outline, size: 25, color: Colors.black),
                        SizedBox(width: 70),
                        Text(
                          '이메일로 로그인',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
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
    );
  }
}

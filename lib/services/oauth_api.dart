import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../models/jwt_Token_Info.dart';
import '../provider/user_provider.dart';
import 'login_api.dart';

class OAuthApi {
  Future<bool> signInWithKakao(UserProvider userProvider) async {
    final bool isInstalled = await isKakaoTalkInstalled();
    OAuthToken? token;

    if (isInstalled) {
      token = await _loginWithTalk();
    } else {
      token = await _loginWithAccount();
    }

    if (token == null) return false;

    try {
      final JwtTokenInfo tokenInfo =
          await LoginApi().kakaoSocialLogin(token.accessToken);

      Map<String, dynamic> accessTokenInfo =
          JwtDecoder.decode(tokenInfo.accessToken!);

      final String? username = accessTokenInfo['username'];

      if (username == null) {
        return false;
      }

      userProvider.setState(
          accessTokenInfo['username'],
          accessTokenInfo['sub'],
          accessTokenInfo['auth'],
          tokenInfo.accessToken,
          tokenInfo.refreshToken,
          false);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<OAuthToken?> _loginWithTalk() async {
    try {
      final token = await UserApi.instance.loginWithKakaoTalk();
      debugPrint("카카오톡으로 로그인 성공");
      return token;
    } catch (error) {
      debugPrint("카카오톡 로그인 실패");
      return null;
    }
  }

  Future<OAuthToken?> _loginWithAccount() async {
    try {
      final token = await UserApi.instance.loginWithKakaoAccount();
      debugPrint("카카오톡 계정으로 로그인 성공");
      return token;
    } catch (error) {
      debugPrint(error.toString());
      debugPrint("카카오톡 계정으로 로그인 실패");
      return null;
    }
  }
}

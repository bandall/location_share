import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:location_share/exceptions/custom_exception.dart';
import 'package:location_share/models/api_response.dart';
import 'package:location_share/models/jwt_Token_Info.dart';
import 'package:location_share/models/login_expire_error.dart';
import 'package:location_share/screen/auth_page.dart';

import '../provider/user_provider.dart';

class LoginApi {
  static const baseUrl = "http://192.168.0.43:8080";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> getHeaders({bool authRequired = false}) async {
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    if (authRequired) {
      String? accessToken = await _storage.read(key: 'accessToken');
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Future<http.Response> _sendRequestWithRefreshWhenExpired(
      Future<http.Response> Function() requestSender,
      UserProvider userProvider) async {
    final response = await requestSender().timeout(const Duration(seconds: 2),
        onTimeout: () {
      throw TimeoutException("서버 연결에 실패했습니다.");
    });
    if (response.statusCode != 401) return response;

    debugPrint("refresh and trying again");
    await refreshTokens(userProvider);
    return await requestSender();
  }

  Future<JwtTokenInfo> kakaoSocialLogin(
      BuildContext context, String accessToken) async {
    final url = Uri.parse('$baseUrl/oauth/login/kakao?code=$accessToken');
    final response = await http
        .get(url, headers: await getHeaders())
        .timeout(const Duration(seconds: 2), onTimeout: () {
      throw TimeoutException("Request took too long.");
    });

    if (response.statusCode != 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint(json.toString());
      int errorCode = json['code'];
      if (errorCode == 410) {
        String msg = json['data']['errMsg'];
        // Assets().showPopup(context, );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AuthCodePage(msg: msg, kakaoAccessKey: accessToken)));
      }

      throw EmailNotVerified("이메일 인증을 진행해주세요.");
    }

    String responseBody = utf8.decode(response.bodyBytes);
    final list = jsonDecode(responseBody);
    final tokenInfo = JwtTokenInfo.fromJson(list);

    return tokenInfo;
  }

  Future<bool> authEmail(String code) async {
    final url = Uri.parse('$baseUrl/api/email-verification');
    final response = await http
        .post(url,
            headers: await getHeaders(),
            body: jsonEncode(<String, String>{
              'code': code,
            }))
        .timeout(const Duration(seconds: 2), onTimeout: () {
      throw TimeoutException("Request took too long.");
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> resendAuthEmail(String accessToken) async {
    final url = Uri.parse('$baseUrl/oauth/login/kakao?code=$accessToken');
    final response = await http
        .get(url, headers: await getHeaders())
        .timeout(const Duration(seconds: 2), onTimeout: () {
      throw TimeoutException("Request took too long.");
    });

    if (response.statusCode == 500) {
      throw Exception();
    }
  }

  Future<void> refreshTokens(UserProvider userProvider) async {
    final url = Uri.parse('$baseUrl/api/account/refresh');
    String? accessToken = await _storage.read(key: 'accessToken');
    String? refreshToken = await _storage.read(key: 'refreshToken');
    final response = await http.post(url,
        headers: await getHeaders(),
        body: jsonEncode(<String, String>{
          'accessToken': accessToken!,
          'refreshToken': refreshToken!,
        }));

    if (response.statusCode == 500) {
      debugPrint("서버 오류 발생");
      throw Error();
    }

    if (response.statusCode != 200) {
      debugPrint("refresh 토큰 갱신 실패로 로그아웃");
      await userProvider.deleteState(true);
      throw LoginExpiredError();
    }

    String responseBody = utf8.decode(response.bodyBytes);
    final tokenInfo = JwtTokenInfo.fromJson(jsonDecode(responseBody));
    Map<String, dynamic> accessTokenInfo =
        JwtDecoder.decode(tokenInfo.accessToken!);

    if (accessTokenInfo['username'] == null) {
      await userProvider.deleteState(true);
      throw LoginExpiredError();
    }

    await userProvider.updateState(
        accessTokenInfo['username'],
        accessTokenInfo['sub'],
        accessTokenInfo['auth'],
        tokenInfo.accessToken,
        tokenInfo.refreshToken,
        null);
  }

  Future<void> logout() async {
    final url = Uri.parse('$baseUrl/api/account/logout');
    String? refreshToken = await _storage.read(key: 'refreshToken');
    http.post(url,
        headers: await getHeaders(authRequired: true),
        body: jsonEncode(<String, String>{'refreshToken': refreshToken!}));
    return;
  }

  Future<String> getUserInfo(UserProvider userProvider) async {
    final url = Uri.parse('$baseUrl/api/whoami');
    final response = await _sendRequestWithRefreshWhenExpired(() async {
      return await http.get(url, headers: await getHeaders(authRequired: true));
    }, userProvider);
    handleStatusCodeError(response);

    final json = ApiResponse.fromJson(utf8.decode(response.bodyBytes));
    await userProvider.updateProfileImage(json.data['profileImageUrl']);
    return utf8.decode(response.bodyBytes);
  }

  Future<void> editUsername(
      UserProvider userProvider, String newUsername) async {
    final url = Uri.parse('$baseUrl/api/account/update-username');
    final response = await _sendRequestWithRefreshWhenExpired(() async {
      return await http.post(url,
          headers: await getHeaders(authRequired: true),
          body: jsonEncode(<String, String>{'username': newUsername}));
    }, userProvider);

    handleStatusCodeError(response);
    await userProvider.updateUsername(newUsername);
  }

  void handleStatusCodeError(http.Response response) {
    if (response.statusCode != 200) {
      debugPrint('Server error');
      throw Exception();
    }
  }

  // Future<void> deleteSocialAccount() {

  // }
}


// Future<void> checkLoginStatus(UserProvider userProvider) async {
//   String? accessToken = await _storage.read(key: 'accessToken');
//   String? refreshToken = await _storage.read(key: 'refreshToken');
//   if (refreshToken == null || accessToken == null) {
//     throw LoginExpiredError();
//   }

//   if (JwtDecoder.isExpired(accessToken)) {
//     if (JwtDecoder.isExpired(refreshToken)) {
//       await _storage.deleteAll();
//       throw LoginExpiredError();
//     } else {
//       await refreshTokens(userProvider);
//       return;
//     }
//   }

//   return;
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final backendUrl = "http://192.168.29.128:8080/auth";
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<Map<String, String>> _getCookieHeader() async {
      final accessToken = await secureStorage.read(key: 'access_token');
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      final userCognitoSub = await secureStorage.read(key: 'user_cognito_sub');

      final headers = {'Content-Type': 'application/json'};
      
      if (accessToken != null) {
        headers['Cookie'] = 'access_token=$accessToken';
      }

      if (refreshToken != null) {
        headers['Cookie'] = '${headers['Cookie']};refresh_token=$refreshToken';
        if (userCognitoSub != null) {
          headers['Cookie'] = '${headers['Cookie']};user_cognito_sub=$userCognitoSub';
        }
      }

      return headers;

    }

    Future<void> _storeCookies(http.Response response) async {
      String? cookies = response.headers['set-cookie'];
      
      if (cookies != null) {
        final accessTokenMatch = RegExp(r'access_token=([^;]+)')
        .firstMatch(cookies);

        if(accessTokenMatch != null) {
          await secureStorage.write(
            key: 'access_token', 
            value: accessTokenMatch.group(1)
            );
        }
        
        final refreshTokenMatch = RegExp(r'refresh_token=([^;]+)')
        .firstMatch(cookies);

        if(refreshTokenMatch != null) {
          await secureStorage.write(
            key: 'refresh_token', 
            value: refreshTokenMatch.group(1)
            );
        }

      }
    }

    Future<String> signUpUser({
      required String name,
      required String password,
      required String email,
    }) async {
      final res = await http.post(Uri.parse("$backendUrl/signup"), 
      headers: {
        'Content-Type': 'application/json',
      }, body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }));
      print("$name $email $password");


      if (res.statusCode != 200) {
        print(res.body);
        throw jsonDecode(res.body)['detail'] ?? 'Signup failed';
      }

      print(res.headers);

      return jsonDecode(res.body)['message'] ?? 'Signup successful, please verify your email';
    }

    Future<String> confirmSignUpUser({
      required String email,
      required String otp,
    }) async {
      final res = await http.post(Uri.parse("$backendUrl/confirm-signup"), 
      headers: {
        'Content-Type': 'application/json',
      }, body: jsonEncode({
        'email': email,
        'otp': otp,
      }));


      if (res.statusCode != 200) {
        print(res.body);
        throw jsonDecode(res.body)['detail'] ?? 'OTP verification failed';
      }

      return jsonDecode(res.body)['message'] ?? 'OTP verified successfully';
    }

    Future<String> loginUser({
      required String email,
      required String password,
    }) async {
      final res = await http.post(Uri.parse("$backendUrl/login"), 
      headers: {
        'Content-Type': 'application/json',
      }, body: jsonEncode({
        'email': email,
        'password': password,
      }));


      if (res.statusCode != 200) {
        print(res.body);
        throw jsonDecode(res.body)['detail'] ?? 'Login failed';
      }

      await _storeCookies(res);
      isAuthenticated();

      return jsonDecode(res.body)['message'] ?? 'Login successful';
    }

    Future<String> refreshToken() async {
      final cookieHeaders = await _getCookieHeader();
      final res = await http.post(
        Uri.parse("$backendUrl/refresh"), 
        headers: cookieHeaders,
        );

      if (res.statusCode != 200) {
        print(res.body);
        throw jsonDecode(res.body)['detail'] ?? 'Login failed';
      }

      await _storeCookies(res);

      return jsonDecode(res.body)['message'] ?? 'Login successful';
    }

    Future<bool> isAuthenticated({int count = 0}) async {
      if(count > 1) {
        return false;
      }
      
      final cookieHeaders = await _getCookieHeader();

      final res = await http.get(
        Uri.parse("$backendUrl/me"), 
        headers: cookieHeaders,
      );


      if(res.statusCode != 200) {
        await refreshToken();
        return isAuthenticated(count: count+1);
      } else {
        await secureStorage.write(
        key: 'user_cognito_sub', 
        value: jsonDecode(res.body)['sub']
        );
      }

      return res.statusCode == 200;
    }
}
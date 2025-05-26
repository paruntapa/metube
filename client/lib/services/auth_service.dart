import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final backendUrl = "http://192.168.29.128:8080/auth";
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

      return jsonDecode(res.body)['message'] ?? 'Login successful';
    }
}
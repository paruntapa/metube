import 'package:client/pages/auth/login_page.dart';
import 'package:client/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:client/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/cubits/auth/aut_cubits.dart';


class ConfirmSignupPage extends StatefulWidget {
  final String email;
  static route(String email) => MaterialPageRoute(builder: (context) => ConfirmSignupPage(
    email: email,
  ));
  const ConfirmSignupPage({super.key, required this.email});

  @override
  State<ConfirmSignupPage> createState() => _ConfirmSignupPageState();
}

class _ConfirmSignupPageState extends State<ConfirmSignupPage> {
  final otpController = TextEditingController();
  late TextEditingController emailController;
  final formKey = GlobalKey<FormState>();
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
  }
    
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void confirmSignUp() async {
    if (formKey.currentState!.validate()) {
     context.read<AuthCubit>().confirmSignUpUser(
      otp: otpController.text.trim(), 
      email: emailController.text.trim(), 
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthConfirmSignupSuccess) {
            showSnackBar(state.message, context);
            Navigator.push(context, LoginPage.route());
          } else if (state is AuthError) {
            showSnackBar(state.error, context);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return  Center(child: CircularProgressIndicator.adaptive());
          }
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: formKey,
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Confirm Signup',  style: TextStyle(
              fontSize: 50, fontWeight: FontWeight.bold
            )),
            SizedBox(height: 30),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Email',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }

                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: otpController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'OTP',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'OTP is required';
                }

                return null;
              },
            ),
            SizedBox(height: 15),
            ElevatedButton(onPressed: confirmSignUp, child: Text('Verify', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ],)
        ),
      );
      },
      ),  
    );
  }
}
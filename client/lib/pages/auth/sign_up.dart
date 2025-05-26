import 'package:client/cubits/auth/aut_cubits.dart';
import 'package:client/pages/auth/login_page.dart';
import 'package:client/pages/auth/confirm_signup_page.dart';
import 'package:client/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:client/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => SignupPage());
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final authService = AuthService();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signUp() async {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUpUser(
        name: nameController.text.trim(), 
        email: emailController.text.trim(), 
        password: passwordController.text.trim()
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSignupSuccess) {
            showSnackBar(state.message, context);
            Navigator.push(context, ConfirmSignupPage.route(emailController.text.trim()));
          } else if (state is AuthError) {
            showSnackBar(state.error, context);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          return Padding(
            padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sign Up',  style: TextStyle(
              fontSize: 50, fontWeight: FontWeight.bold
            )),
            SizedBox(height: 30),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }

                return null;
              },
            ),
            SizedBox(height: 15),
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
              controller: passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password is required';
                }

                return null;
              },
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: signUp, child: Text('Sign Up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(LoginPage.route());
              },
              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                style: TextStyle(color: Colors.grey.shade500),
                
                children: [
                  TextSpan(text: 'Sign In', style: TextStyle(color: Colors.blue))
                ]
              )
            ))
          ],)
        ),
      );
      },
      ),
    );
  }
}
import 'package:client/pages/auth/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:client/services/auth_service.dart';
import 'package:client/utils/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/cubits/auth/aut_cubits.dart';


class LoginPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => LoginPage());
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final authService = AuthService();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  
  void logIn() async {
    if (formKey.currentState!.validate()) {
      context.read<AuthCubit>().loginUser(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoginSuccess) {
            showSnackBar(state.message, context);
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
          Text('Sign In',  style: TextStyle(
            fontSize: 50, fontWeight: FontWeight.bold
          )),
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
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Password is required';
              }

              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: logIn, child: Text('Sign Up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(SignupPage.route());
            },
            child: RichText(
              text: TextSpan(
                text: 'Don\'t have an account? ',
              style: TextStyle(color: Colors.grey.shade500),
              
              children: [
                TextSpan(text: 'Sign Up', style: TextStyle(color: Colors.blue))
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
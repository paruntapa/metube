import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/services/auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final authService = AuthService();


  void signUpUser( {required String name, required String email, required String password}) 
  async {
    emit(AuthLoading());
    try {
       final res = await authService.signUpUser(
        name: name, 
        email: email, 
        password: password
        );
        emit(AuthSignupSuccess(res));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
  }

  void confirmSignUpUser( {required String otp, required String email,}) 
  async {
    emit(AuthLoading());
    try {
       final res = await authService.confirmSignUpUser(
        otp: otp, 
        email: email, 
        );
        emit(AuthConfirmSignupSuccess(res));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
  }

  void loginUser( {required String email, required String password,}) 
  async { 
    emit(AuthLoading());
    try {
       final res = await authService.loginUser(
        email: email, 
        password: password, 
        );
        emit(AuthLoginSuccess(res));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
  }

  void isAuthenticated() async {
    emit(AuthLoading());
    try {
       final res = await authService.isAuthenticated();
       if(res) {
        emit(AuthLoginSuccess('logged in'));
       } else {
        emit(AuthInitial());
       }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
  }
}


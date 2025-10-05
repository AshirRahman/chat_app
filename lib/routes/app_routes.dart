import 'package:chat_app/features/authentication/login/screen/login_screen.dart';
import 'package:chat_app/features/authentication/signup/screen/signup_screen.dart';
import 'package:get/get.dart';
import '../features/home/screen/home_screen.dart';

class AppRoute {
  static String homeScreen = "/homeScreen";
  static String loginScreen = "/login";
  static String signupScreen = "/signup";

  static String getHomeScreen() => homeScreen;
  static String getLoginScreen() => loginScreen;
  static String getSignupScreen() => signupScreen;

  static List<GetPage> routes = [
    GetPage(name: homeScreen, page: () => HomeScreen()),
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: signupScreen, page: () => SignupScreen()),
  ];
}

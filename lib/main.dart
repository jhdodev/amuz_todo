import 'package:amuz_todo/add_todo_view.dart';
import 'package:amuz_todo/detail_todo_view.dart';
import 'package:amuz_todo/home_page.dart';
import 'package:amuz_todo/login_view.dart';
import 'package:amuz_todo/sign_up_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Pretendard",
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/home': (context) => const HomePage(),
        '/add-todo': (context) => const AddTodoView(),
        '/detail-todo': (context) => const DetailTodoView(),
        '/sign-up': (context) => const SignUpView(),
      },
    );
  }
}

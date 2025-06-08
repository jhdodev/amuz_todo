import 'package:amuz_todo/src/view/todo/add_todo_view.dart';
import 'package:amuz_todo/src/view/todo/detail_todo_view.dart';
import 'package:amuz_todo/src/view/home_view.dart';
import 'package:amuz_todo/src/view/login/login_view.dart';
import 'package:amuz_todo/src/view/signup/sign_up_view.dart';
import 'package:amuz_todo/util/route_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(MyApp());
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
      initialRoute: RoutePath.login,
      routes: {
        RoutePath.login: (context) => const LoginView(),
        RoutePath.home: (context) => const HomeView(),
        RoutePath.addTodo: (context) => const AddTodoView(),
        RoutePath.detailTodo: (context) => const DetailTodoView(),
        RoutePath.signUp: (context) => const SignUpView(),
      },
    );
  }
}

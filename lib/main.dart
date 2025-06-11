import 'package:amuz_todo/src/view/todo/add/todo_add_view.dart';
import 'package:amuz_todo/src/view/home_view.dart';
import 'package:amuz_todo/src/view/auth/signin/sign_in_view.dart';
import 'package:amuz_todo/src/view/auth/signup/sign_up_view.dart';
import 'package:amuz_todo/util/route_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 세션 확인
    final session = Supabase.instance.client.auth.currentSession;
    print('!! 세션 확인 - session: ${session != null ? '있음' : '없음'}');

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
      home: session != null ? const HomeView() : const SignInView(),
      routes: {
        RoutePath.signIn: (context) => const SignInView(),
        RoutePath.home: (context) => const HomeView(),
        RoutePath.todoAdd: (context) => const TodoAddView(),
        RoutePath.signUp: (context) => const SignUpView(),
      },
    );
  }
}

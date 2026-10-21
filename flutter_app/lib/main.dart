import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/expense_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MoneyTraceApp());
}

class MoneyTraceApp extends StatelessWidget {
  const MoneyTraceApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..loadExpenses(),
      child: MaterialApp(
        title: 'MoneyTrace AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFFAF9FD),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5E43A5),
            primary: const Color(0xFF5E43A5),
          ),
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        ),
        home: Consumer<ExpenseProvider>(
          builder: (context, auth, _) {
            if (!auth.isLoggedIn) {
              return const LoginScreen();
            }
            return const MainNavigationScreen();
          },
        ),
      ),
    );
  }
}

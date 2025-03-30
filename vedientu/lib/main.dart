import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/buy_ticket_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_tickets_screen.dart';
import 'screens/ticket_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final bool loggedIn = snapshot.data ?? false;

        return MaterialApp.router(
          title: 'Vé Điện Tử',
          theme: ThemeData(primarySwatch: Colors.blue),
          routerConfig: GoRouter(
            initialLocation: loggedIn ? '/home' : '/',
            routes: [
              GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
              GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
              GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
              GoRoute(path: '/buy-ticket', builder: (context, state) => const BuyTicketScreen()),
              GoRoute(path: '/tickets', builder: (context, state) => const MyTicketsScreen()),
              GoRoute(
                path: '/tickets/:ticketId',
                builder: (context, state) {
                  final ticketId = int.tryParse(state.pathParameters['ticketId'] ?? '') ?? 0;
                  final ticketData = state.extra as Map<String, dynamic>?; // ✅ Lấy dữ liệu

                  return TicketDetailsScreen(ticketId: ticketId, ticketData: ticketData);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

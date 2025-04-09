import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/buy_ticket_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_tickets_screen.dart';
import 'screens/ticket_detail_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/driver_home_screen.dart';
import 'screens/scan_qr_screen.dart';
import 'screens/passenger_list_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/user_list_screen.dart';
import 'screens/bus_list_screen.dart';
import 'screens/bus_detail_screen.dart';
import 'screens/add_bus_screen.dart';
import 'screens/edit_bus_screen.dart';

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
              // user
              GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
              GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
              GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
              GoRoute(path: '/buy-ticket', builder: (context, state) => const BuyTicketScreen()),
              GoRoute(path: '/profile', builder: (context, state) => const UserProfilePage()),
              GoRoute(path: '/tickets', builder: (context, state) => const MyTicketsScreen()),
              GoRoute(
                path: '/tickets/:ticketId',
                builder: (context, state) {
                  final ticketId = int.tryParse(state.pathParameters['ticketId'] ?? '') ?? 0;
                  final ticketData = state.extra as Map<String, dynamic>?;

                  return TicketDetailsScreen(ticketId: ticketId, ticketData: ticketData);
                },
              ),
              // driver
              GoRoute(path: '/driver-home', builder: (context, state) => const DriverHomeScreen()),
              GoRoute(path: '/scan-qr', builder: (context, state) => const ScanQRScreen()),
              GoRoute(path: '/passenger-list', builder: (context, state) => const PassengerListScreen()),
              // admin
              GoRoute(path: '/admin-home', builder: (context, state) => const AdminHomeScreen()),
              GoRoute(path: '/users', builder: (context, state) => const UserListScreen()),
              GoRoute(path: '/buses', builder: (context, state) => BusListScreen()),
              GoRoute(
                      path: '/bus-detail/:id',
                      builder: (context, state) {
                        final busId = state.pathParameters['id']!;
                        final bus = state.extra as dynamic;  // Lấy dữ liệu bus từ extra
                        return BusDetailScreen(busId: busId, bus: bus);  // Truyền cả busId và bus
                      },
                    ),

              GoRoute(path: '/add-bus', builder: (context, state) => const AddBusScreen()),
              GoRoute(
                path: '/edit-bus/:id',
                builder: (context, state) {
                  final busId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return EditBusScreen(busId: busId); // Truyền busId
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

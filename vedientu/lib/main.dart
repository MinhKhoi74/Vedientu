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
import 'screens/admin_register_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/transaction_details_screen.dart';
import 'screens/admin_transactions_screen.dart';
import 'screens/report_screen.dart';
import 'screens/my_rides_screen.dart';
import 'screens/ride_details_screen.dart';
import 'screens/driver_trip_list_screen.dart';
import 'screens/driver_profile_screen.dart';
import 'screens/forgot_password_page.dart';
import 'screens/otp_verification_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> getInitialRoute() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');

    if (token == null) return '/';

    switch (role) {
      case 'user':
        return '/home';
      case 'driver':
        return '/driver-home';
      case 'admin':
        return '/admin-home';
      default:
        return '/';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getInitialRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final initialRoute = snapshot.data!;

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Vé Điện Tử',
          theme: ThemeData(primarySwatch: Colors.blue),
          routerConfig: GoRouter(
            initialLocation: initialRoute,
            routes: [

              /// User
              GoRoute(path: '/', builder: (context, state) => LoginScreen()),
              GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
              GoRoute(path: '/forgot-password', builder: (context, state) =>  ForgotPasswordPage()),
              GoRoute(path: '/otp-verification', builder: (context, state) =>  OTPVerificationPage(email: state.extra as String,)),
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
              GoRoute(path: '/transactions', builder: (context, state) => const MyTransactionsScreen()),
              GoRoute(
                path: '/transactions/:transactionId',
                builder: (context, state) {
                  final transactionId = int.tryParse(state.pathParameters['transactionId'] ?? '') ?? 0;
                  final transactionData = state.extra as Map<String, dynamic>?;
                  return TransactionDetailsScreen(transactionId: transactionId, transactionData: transactionData);
                },
              ),
              GoRoute(path: '/ride-history', builder: (context, state) => const MyRidesScreen()),
              GoRoute(
                path: '/rides/:id',
                builder: (context, state) {
                  final ride = state.extra as Map<String, dynamic>?;
                  final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return RideDetailsScreen(rideId: id, rideData: ride);
                },
              ),

              /// Driver
              GoRoute(path: '/driver-home', builder: (context, state) => const DriverHomeScreen()),
              GoRoute(path: '/driver-profile', builder: (context, state) => const DriverProfilePage()),
              GoRoute(path: '/scan-qr', builder: (context, state) => const ScanQRScreen()),
              GoRoute(path: '/driver-trip', builder: (context, state) => const DriverTripListScreen()),
              GoRoute(
                path: '/passenger-list',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>;
                  return PassengerListScreen(tripId: extra['tripId']);
                },
              ),

              /// Admin
              GoRoute(path: '/admin-home', builder: (context, state) => const AdminHomeScreen()),
              GoRoute(path: '/users', builder: (context, state) => const UserListScreen()),
              GoRoute(path: '/buses', builder: (context, state) => BusListScreen()),
              GoRoute(
                path: '/bus-detail/:id',
                builder: (context, state) {
                  final busId = state.pathParameters['id']!;
                  final bus = state.extra as dynamic;
                  return BusDetailScreen(busId: busId, bus: bus);
                },
              ),
              GoRoute(path: '/add-bus', builder: (context, state) => const AddBusScreen()),
              GoRoute(
                path: '/edit-bus/:id',
                builder: (context, state) {
                  final busId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return EditBusScreen(busId: busId);
                },
              ),
              GoRoute(path: '/admin-register', builder: (context, state) => const AdminRegisterScreen()),
              GoRoute(path: '/admin/transactions', builder: (context, state) => const AdminTransactionsScreen()),
              GoRoute(path: '/admin/report', builder: (context, state) => const ReportScreen()),
            ],
          ),
        );
      },
    );
  }
}

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petitparser/debug.dart';
import 'dart:convert';
class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/'));

  // Đăng ký tài khoản
  Future<bool> register(String name, String email, String password, String phone) async {
    try {
      final response = await _dio.post('auth/register', data: {
        'fullName': name, 
        'email': email,
        'password': password,
        'phone': phone,     
        'role': 'CUSTOMER'  
      });

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
// Đăng ký tài khoản với role tùy chọn (dành cho admin)
Future<bool> registerWithRole(String name, String email, String password, String phone, String role) async {
  try {
    final response = await _dio.post('auth/register', data: {
      'fullName': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role, // Cho phép chọn role CUSTOMER / DRIVER
    });

    return response.statusCode == 201;
  } catch (e) {
    return false;
  }
}

  // Đăng nhập
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.data['token']);
        await prefs.setString('role', response.data['role']); // Lưu role vào SharedPreferences
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
 // ✅ Lấy role đã lưu
  Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
  // Lấy token đã lưu
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Đăng xuất người dùng
  Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('token'); // Xóa token khỏi bộ nhớ
  if (context.mounted) {
    context.go('/'); // Quay về trang đăng nhập
  }
}




  // Lấy thông tin tài khoản
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      String? token = await getToken();
      if (token == null) return null;

      final response = await _dio.get('/user/info',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data;
    } catch (e) {
      return null;
    }
  }

  // Lấy danh sách vé
  Future<List<dynamic>> getTickets() async {
    try {
      String? token = await getToken();
      if (token == null){
        log('🚨 Không tìm thấy token!');
        return [];
      }
      final response = await _dio.get('user/tickets',
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data;
    } catch (e) {
      log('❌ Lỗi lấy danh sách vé: $e');
      return [];
    }
  }
// Mua vé mới
  Future<bool> buyTicket(String ticketType) async {
    try {
      String? token = await getToken();
      if (token == null) {
        log('🚨 Không tìm thấy token!');
        return false;
      }

      final response = await _dio.post(
        'user/buy-ticket',
        data: {'ticketType': ticketType}, 
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      log('🔍 Gửi request mua vé: ticketType=$ticketType');
      log('📢 Headers: ${response.requestOptions.headers}');
      log('🔄 Status Code: ${response.statusCode}');
      log('📥 Response: ${response.data}');

      return response.statusCode == 200;
    } catch (e) {
      log('❌ Lỗi mua vé: $e');
      return false;
    }
  }
  // Lấy thông tin chi tiết vé
 Future<Map<String, dynamic>?> getTicketDetails(int ticketId) async {
  try {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token! Hãy đăng nhập lại.');
    }

    final response = await _dio.get(
      '/user/tickets/$ticketId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 404) {
      throw Exception('404 - Không tìm thấy vé!');
    } else {
      throw Exception('Lỗi API: ${response.statusCode}');
    }
  } on DioError catch (e) {
    if (e.response?.statusCode == 401) {
      throw Exception('Token hết hạn. Vui lòng đăng nhập lại.');
    } else if (e.response?.statusCode == 404) {
      throw Exception('404 - Không tìm thấy vé!');
    }
    throw Exception('Lỗi khi gọi API: ${e.message}');
  }
}


// ✅ Hủy vé
  Future<bool> cancelTicket(int ticketId) async {
    try {
      String? token = await getToken();
      if (token == null) {
        log('🚨 Không tìm thấy token!');
        return false;
      }

      final response = await _dio.delete(
        'user/tickets/$ticketId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      log('🗑️ Hủy vé: ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      log('❌ Lỗi hủy vé: $e');
      return false;
    }
  }

// ✅ Lấy danh sách giao dịch
Future<List<dynamic>> getTransactions() async {
  try {
    String? token = await getToken();
    if (token == null) {
      log('🚨 Không tìm thấy token!');
      return [];
    }

    final response = await _dio.get(
      '/user/transactions',  // API backend trả về tất cả giao dịch của user
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  } catch (e) {
    log('❌ Lỗi lấy danh sách giao dịch: $e');
    return [];
  }
}
// lấy chi tiết giao dịch
Future<Map<String, dynamic>?> getTransactionDetails(int transactionId) async {
  try {
    String? token = await getToken();
    if (token == null) throw Exception('Không có token');

    final response = await _dio.get(
      'user/transaction/$transactionId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) return response.data;
    throw Exception('Lỗi khi lấy chi tiết giao dịch');
  } catch (e) {
    log('❌ Lỗi chi tiết giao dịch: $e');
    return null;
  }
}

// lấy lịch sử chuyến đi
Future<List<dynamic>> getRideHistory() async {
  try {
    String? token = await getToken();
    if (token == null) {
      log('🚨 Không tìm thấy token!');
      return [];
    }

    final response = await _dio.get(
      'user/ride-history', 
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  } catch (e) {
    log('❌ Lỗi lấy danh sách chuyến đi: $e');
    return [];
  }
}
// chi tiết chuyến đi
Future<Map<String, dynamic>?> getRideDetails(int rideId) async {
  try {
    String? token = await getToken(); // Hàm lấy token từ local storage hoặc SecureStorage
    if (token == null) throw Exception('Không có token');

    final response = await _dio.get(
      'user/ride-history/$rideId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Lỗi khi lấy chi tiết chuyến đi');
    }
  } catch (e) {
    log('❌ Lỗi chi tiết chuyến đi: $e');
    return null;
  }
}



  // DRIVER
  // ✅ Hàm quét mã QR
  Future<Map<String, dynamic>?> scanDriverQR(String qrCode) async {
    try {
      String? token = await getToken();
      if (token == null) {
        log('🚨 Không tìm thấy token!');
        return null;
      }

      log("🔐 Token gửi lên: $token");
      log("📌 Mã QR gửi lên: $qrCode");

      final response = await _dio.post(
        'driver/scan-qr', // Cập nhật URL đúng với backend
        data: {'qrContent': qrCode}, // Gửi mã QR dưới dạng qrContent
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        log('✅ Quét mã QR thành công: ${response.data}');
        return response.data;
      } else {
        log('⚠️ Mã QR không hợp lệ!');
        return null;
      }
    } catch (e) {
      log('❌ Lỗi khi quét mã QR: $e');
      return null;
    }
  }


Future<List<dynamic>> getPassengers() async {
  try {
    String? token = await getToken();
    if (token == null) {
      log('🚨 Không tìm thấy token!');
      return [];
    }

    log('🔄 Gửi request lấy danh sách hành khách...');
    
    final response = await _dio.get(
      'driver/passengers',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    log('📩 API Response: ${response.statusCode} - ${response.data}');

    if (response.statusCode == 200) {
      // Trả về danh sách hành khách từ trường 'passengers'
      if (response.data['passengers'] is List) {
        log('✅ Danh sách hành khách: ${response.data['passengers']}');
        return response.data['passengers'];
      } else {
        log('⚠️ Dữ liệu không phải danh sách hợp lệ: ${response.data}');
        return [];
      }
    } else {
      log('⚠️ Không có hành khách hoặc lỗi API');
      return [];
    }
  } catch (e) {
    log('❌ Lỗi khi lấy danh sách hành khách: $e');
    return [];
  }
}


// admin
// ✅ Lấy danh sách người dùng (chỉ dành cho admin)
Future<List<dynamic>> getAllUsers() async {
  try {
    String? token = await getToken();
    if (token == null) {
      debugPrint('🚨 Không tìm thấy token!');
      return [];
    }

    final response = await _dio.get(
      'admin/users',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    debugPrint('📡 Raw Response: ${response.data}');

    if (response.statusCode == 200) {
      return response.data as List<dynamic>;
    } else {
      debugPrint('⚠️ Không có người dùng nào hoặc lỗi API');
      return [];
    }
  } catch (e) {
    debugPrint('❌ Lỗi khi lấy danh sách người dùng: $e');
    return [];
  }
}
//lấy danh sách tài xế
Future<List<dynamic>> getAllDrivers() async {
  try {
    String? token = await getToken();
    if (token == null) {
      debugPrint('🚨 Không tìm thấy token!');
      return [];
    }

    final response = await _dio.get(
      'admin/users',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    debugPrint('📡 Raw Response: ${response.data}');

    if (response.statusCode == 200) {
      final List<dynamic> users = response.data;
      final drivers = users.where((user) => user['role'] == 'DRIVER').toList();
      return drivers;
    } else {
      debugPrint('⚠️ Không có người dùng nào hoặc lỗi API');
      return [];
    }
  } catch (e) {
    debugPrint('❌ Lỗi khi lấy danh sách tài xế: $e');
    return [];
  }
}

// ✅ Xóa người dùng theo ID (chỉ dành cho admin)
Future<bool> deleteUserById(int userId) async {
  try {
    String? token = await getToken();
    if (token == null) {
      debugPrint('🚨 Không tìm thấy token!');
      return false;
    }

    final response = await _dio.delete(
      'admin/users/$userId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    debugPrint('🗑️ Xóa người dùng ID $userId: ${response.statusCode}');
    return response.statusCode == 200 || response.statusCode == 204;
  } catch (e) {
    debugPrint('❌ Lỗi khi xóa người dùng: $e');
    return false;
  }
}
// thêm xe buýt
Future<bool> addBusWithDriver(String licensePlate, String model, int capacity, String route, int driverId) async {
  try {
    String? token = await getToken();
    if (token == null) {
      debugPrint('🚨 Không tìm thấy token!');
      return false;
    }

    final response = await _dio.post(
      'admin/buses',
      data: {
        'licensePlate': licensePlate,
        'model': model,
        'capacity': capacity,
        'route': route,
        'driverId': driverId,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    debugPrint('🚌 Thêm xe buýt kèm tài xế: ${response.statusCode}');
    debugPrint('📦 Response body: ${response.data}');

    // Chấp nhận cả 200 hoặc 201 là thành công
    return response.statusCode == 201 || response.statusCode == 200;
  } catch (e) {
    debugPrint('❌ Lỗi khi thêm xe buýt: $e');
    return false;
  }
}


// lấy danh sách xe buýt
Future<List<dynamic>> getBuses() async {
  try {
    String? token = await getToken();
    if (token == null) {
      debugPrint('🚨 Không tìm thấy token!');
      return [];
    }

    final response = await _dio.get(
      'admin/buses',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    debugPrint('🚍 Lấy danh sách xe buýt: ${response.statusCode}');
    if (response.statusCode == 200) {
      return response.data; // Trả về danh sách xe buýt
    } else {
      return [];
    }
  } catch (e) {
    debugPrint('❌ Lỗi khi lấy danh sách xe buýt: $e');
    return [];
  }
}
// lấy thông tin chi tiết xe buýt
Future<Map<String, dynamic>?> getBusById(int busId) async {
  try {
    String? token = await getToken();
    if (token == null) {
      debugPrint('🚨 Không tìm thấy token!');
      return null;
    }

    final response = await _dio.get(
      'admin/buses/$busId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    debugPrint('🚍 Lấy thông tin xe buýt ID $busId: ${response.statusCode}');
    if (response.statusCode == 200) {
      return response.data; // Trả về thông tin chi tiết xe buýt
    } else {
      return null;
    }
  } catch (e) {
    debugPrint('❌ Lỗi khi lấy thông tin xe buýt: $e');
    return null;
  }
}
// cập nhật thông tin xe buýt
Future<bool> updateBus(int busId, String licensePlate, String model, int capacity, String route, int driverId) async {
  try {
    String? token = await getToken();
    if (token == null) {
      debugPrint('🚨 Không tìm thấy token!');
      return false;
    }

    final response = await _dio.put(
      'admin/buses/$busId',
      data: {
        'licensePlate': licensePlate,
        'model': model,
        'capacity': capacity,
        'route': route,
        'driverId': driverId,  
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    debugPrint('🚍 Cập nhật xe buýt ID $busId: ${response.statusCode}');
    return response.statusCode == 200; // Kiểm tra xem có cập nhật thành công không
  } catch (e) {
    debugPrint('❌ Lỗi khi cập nhật xe buýt: $e');
    return false;
  }
}

// xóa xe buýt
Future<bool> deleteBusById(int busId) async {
  try {
    String? token = await getToken();
    if (token == null) {
      debugPrint('🚨 Không tìm thấy token!');
      return false;
    }

    final response = await _dio.delete(
      'admin/buses/$busId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    debugPrint('🗑️ Xóa xe buýt ID $busId: ${response.statusCode}');
    return response.statusCode == 200 || response.statusCode == 204; // Kiểm tra kết quả xóa
  } catch (e) {
    debugPrint('❌ Lỗi khi xóa xe buýt: $e');
    return false;
  }
}
// lấy danh sách giao dịch cho admin
Future<List<dynamic>> getAllTransactionsForAdmin() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) throw Exception("Token not found");

    final response = await _dio.get(
      '/transactions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data;
  } catch (e) {
    log('Lỗi khi lấy giao dịch admin: $e');
    rethrow;
  }
}
//report
 Future<Map<String, dynamic>?> fetchReportSummary() async {
  try {
    // Lấy token từ SharedPreferences (nếu bạn lưu ở đó sau khi đăng nhập)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("Không có token");
      return null;
    }

    final response = await _dio.get(
      '/reports/summary',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      print("Lỗi: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Lỗi khi gọi API: $e");
    return null;
  }
}

}
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
}
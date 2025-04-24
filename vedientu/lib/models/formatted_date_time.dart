import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormattedDateTime extends StatelessWidget {
  final String expirationTime;

  const FormattedDateTime({Key? key, required this.expirationTime}) : super(key: key);

  // Hàm định dạng thời gian
  String formatExpirationTime(String expirationTime) {
    try {
      DateTime dateTime = DateTime.parse(expirationTime);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);  // Định dạng thời gian
    } catch (e) {
      return "Không hợp lệ";  // Trường hợp không thể parse thời gian
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng hàm để định dạng thời gian
    String formattedTime = formatExpirationTime(expirationTime);

    return Text(
      formattedTime,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }
}

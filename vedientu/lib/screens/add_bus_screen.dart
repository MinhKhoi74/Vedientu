import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddBusScreen extends StatefulWidget {
  const AddBusScreen({Key? key}) : super(key: key);

  @override
  State<AddBusScreen> createState() => _AddBusScreenState();
}

class _AddBusScreenState extends State<AddBusScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  String licensePlate = '';
  String model = '';
  int capacity = 0;
  String route = '';
  int? selectedDriverId;

  List<dynamic> drivers = [];

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  void fetchDrivers() async {
    final data = await apiService.getAllDrivers();
    setState(() {
      drivers = data;
    });
  }

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDriverId == null) {
        Fluttertoast.showToast(msg: 'Vui lòng chọn tài xế');
        return;
      }

      bool success = await apiService.addBusWithDriver(
        licensePlate,
        model,
        capacity,
        route,
        selectedDriverId!,
      );

      if (success) {
        Fluttertoast.showToast(msg: '✅ Thêm xe buýt thành công!');
        Navigator.pop(context, true); // ← Trả về thành công
      } else {
        Fluttertoast.showToast(msg: '❌ Thêm xe buýt thất bại!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thêm xe buýt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Biển số'),
                validator: (value) => value!.isEmpty ? 'Không để trống' : null,
                onChanged: (value) => licensePlate = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Model'),
                validator: (value) => value!.isEmpty ? 'Không để trống' : null,
                onChanged: (value) => model = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Sức chứa'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Không để trống' : null,
                onChanged: (value) => capacity = int.tryParse(value) ?? 0,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Tuyến xe'),
                validator: (value) => value!.isEmpty ? 'Không để trống' : null,
                onChanged: (value) => route = value,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Chọn tài xế'),
                value: selectedDriverId,
                items: drivers.map((driver) {
                  return DropdownMenuItem<int>(
                    value: driver['id'],
                    child: Text(driver['fullName']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDriverId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Vui lòng chọn tài xế' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: Text('Thêm xe buýt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

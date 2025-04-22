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
      drivers = data.where((driver) => driver['bus'] == null).toList();
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
        Navigator.pop(context, true);
      } else {
        Fluttertoast.showToast(msg: '❌ Thêm xe buýt thất bại!');
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm xe buýt'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: _inputDecoration('Biển số', Icons.directions_bus),
                      validator: (value) => value!.isEmpty ? 'Không để trống' : null,
                      onChanged: (value) => licensePlate = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputDecoration('Model', Icons.build),
                      validator: (value) => value!.isEmpty ? 'Không để trống' : null,
                      onChanged: (value) => model = value,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputDecoration('Sức chứa', Icons.event_seat),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Không để trống' : null,
                      onChanged: (value) => capacity = int.tryParse(value) ?? 0,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: _inputDecoration('Tuyến xe', Icons.route),
                      validator: (value) => value!.isEmpty ? 'Không để trống' : null,
                      onChanged: (value) => route = value,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<int>(
                      decoration: _inputDecoration('Chọn tài xế', Icons.person),
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
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color:Colors.white,),
                        label: const Text('Thêm xe buýt', style: TextStyle(fontSize: 16, color: Colors.white)),
                        onPressed: submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

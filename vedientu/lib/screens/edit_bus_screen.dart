import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditBusScreen extends StatefulWidget {
  final int busId;

  const EditBusScreen({Key? key, required this.busId}) : super(key: key);

  @override
  _EditBusScreenState createState() => _EditBusScreenState();
}

class _EditBusScreenState extends State<EditBusScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  String _licensePlate = '';
  String _model = '';
  int _capacity = 0;
  String _route = '';
  int? _selectedDriverId;

  List<dynamic> _drivers = [];

  @override
  void initState() {
    super.initState();
    _loadBusDetails();
    _fetchDrivers();
  }

  Future<void> _loadBusDetails() async {
    final bus = await _apiService.getBusById(widget.busId);
    if (bus != null) {
      setState(() {
        _licensePlate = bus['licensePlate'] ?? '';
        _model = bus['model'] ?? '';
        _capacity = bus['capacity'] ?? 0;
        _route = bus['route'] ?? '';
        _selectedDriverId = bus['driverId'];
      });
    }
  }

  Future<void> _fetchDrivers() async {
    final data = await _apiService.getAllDrivers();
    setState(() {
      _drivers = data;
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDriverId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Vui lòng chọn tài xế')),
        );
        return;
      }

      final success = await _apiService.updateBus(
        widget.busId,
        _licensePlate,
        _model,
        _capacity,
        _route,
        _selectedDriverId!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cập nhật thành công')),
        );
        Navigator.of(context).pop(true); // ✅ Trả kết quả thành công
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Cập nhật thất bại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa Xe Buýt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _licensePlate,
                decoration: const InputDecoration(labelText: 'Biển số'),
                onChanged: (value) => _licensePlate = value,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Vui lòng nhập biển số' : null,
              ),
              TextFormField(
                initialValue: _model,
                decoration: const InputDecoration(labelText: 'Mẫu xe'),
                onChanged: (value) => _model = value,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Vui lòng nhập mẫu xe' : null,
              ),
              TextFormField(
                initialValue: _capacity.toString(),
                decoration: const InputDecoration(labelText: 'Sức chứa'),
                keyboardType: TextInputType.number,
                onChanged: (value) => _capacity = int.tryParse(value) ?? 0,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Vui lòng nhập sức chứa' : null,
              ),
              TextFormField(
                initialValue: _route,
                decoration: const InputDecoration(labelText: 'Tuyến đường'),
                onChanged: (value) => _route = value,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Vui lòng nhập tuyến đường' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Tài xế'),
                value: _selectedDriverId,
                items: _drivers.map((driver) {
                  return DropdownMenuItem<int>(
                    value: driver['id'],
                    child: Text(driver['fullName']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedDriverId = value),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn tài xế' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Lưu thay đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

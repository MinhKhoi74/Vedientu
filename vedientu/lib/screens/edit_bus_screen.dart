import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditBusScreen extends StatefulWidget {
  final int busId;

  const EditBusScreen({Key? key, required this.busId}) : super(key: key);

  @override
  _EditBusScreenState createState() => _EditBusScreenState();
}
late TextEditingController _licensePlateController;
late TextEditingController _modelController;
late TextEditingController _capacityController;
late TextEditingController _routeController;

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
    _licensePlateController = TextEditingController();
    _modelController = TextEditingController();
    _capacityController = TextEditingController();
    _routeController = TextEditingController();

    _loadBusDetails();
    _fetchDrivers();
  }


  Future<void> _loadBusDetails() async {
    final bus = await _apiService.getBusById(widget.busId);
    if (bus != null) {
      setState(() {
        _licensePlateController.text = bus['licensePlate'] ?? '';
        _modelController.text = bus['model'] ?? '';
        _capacityController.text = (bus['capacity'] ?? 0).toString();
        _routeController.text = bus['route'] ?? '';
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
        _licensePlateController.text,
        _modelController.text,
        int.tryParse(_capacityController.text) ?? 0,
        _routeController.text,
        _selectedDriverId!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Cập nhật thành công')),
        );
        Navigator.of(context).pop(true);
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
      appBar: AppBar(title: const Text('Cập Nhật Thông Tin Xe Buýt')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Thông Tin Xe Buýt',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Biển số',
                      controller: _licensePlateController,
                      validatorText: 'Vui lòng nhập biển số',
                      icon: Icons.confirmation_number,
                    ),
                    _buildTextField(
                      label: 'Mẫu xe',
                      controller: _modelController,
                      validatorText: 'Vui lòng nhập mẫu xe',
                      icon: Icons.directions_bus,
                    ),
                    _buildTextField(
                      label: 'Sức chứa',
                      controller: _capacityController,
                      validatorText: 'Vui lòng nhập sức chứa',
                      keyboardType: TextInputType.number,
                      icon: Icons.event_seat,
                    ),
                    _buildTextField(
                      label: 'Tuyến đường',
                      controller: _routeController,
                      validatorText: 'Vui lòng nhập tuyến đường',
                      icon: Icons.alt_route,
                    ),

                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Tài xế',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedDriverId,
                      items: _drivers.map((driver) {
                        return DropdownMenuItem<int>(
                          value: driver['id'],
                          child: Text(driver['fullName']),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedDriverId = value),
                      validator: (value) =>
                      value == null ? 'Vui lòng chọn tài xế' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveChanges,
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu thay đổi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String validatorText,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) =>
        (value == null || value.isEmpty) ? validatorText : null,
      ),
    );
  }
}

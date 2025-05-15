import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import 'package:realway_manage/constants/app_colors.dart';

class AddRailwayGatePage extends StatefulWidget {
  const AddRailwayGatePage({super.key});

  @override
  State<AddRailwayGatePage> createState() => _AddRailwayGatePageState();
}

class _AddRailwayGatePageState extends State<AddRailwayGatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _gateNameController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  List<Map<String, String>> timings = [];

  bool _isVerified = false;
  LatLng? selectedLatLng;

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    'railway_gates',
  );

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && selectedLatLng != null) {
      final gateName = _gateNameController.text.trim();
      final lat = selectedLatLng!.latitude;
      final lng = selectedLatLng!.longitude;

      try {
        await _dbRef.child(gateName).set({
          'gate_name': gateName,
          'lat': lat,
          'lng': lng,
          'is_verified': _isVerified,
          'timing': timings,
        });

        await showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("✅ Railway Gate Added"),
                content: Text("$gateName was successfully added."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _gateNameController.clear();
                      _latController.clear();
                      _lngController.clear();
                      setState(() {
                        selectedLatLng = null;
                        _isVerified = false;
                        timings.clear();
                      });
                    },
                    child: const Text("Add Another"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Go to Home"),
                  ),
                ],
              ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong. Try again.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete all fields and tap on the map."),
        ),
      );
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() {
      selectedLatLng = latLng;
      _latController.text = latLng.latitude.toStringAsFixed(6);
      _lngController.text = latLng.longitude.toStringAsFixed(6);
    });
  }

  Widget _buildTimingFields() {
    return Column(
      children: List.generate(timings.length, (index) {
        final item = timings[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.lock),
                  label: Text(
                    item['close_time']?.isNotEmpty == true
                        ? item['close_time']!
                        : "Set Close Time",
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        timings[index]['close_time'] = picked.format(context);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.lock_open),
                  label: Text(
                    item['open_time']?.isNotEmpty == true
                        ? item['open_time']!
                        : "Set Open Time",
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        timings[index]['open_time'] = picked.format(context);
                      });
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => timings.removeAt(index)),
              ),
            ],
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = selectedLatLng ?? LatLng(18.5204, 73.8567);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Railway Gate'),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _gateNameController,
                    decoration: InputDecoration(
                      labelText: 'Gate Name',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter gate name'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _latController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Latitude (Tap on map)',
                      prefixIcon: const Icon(Icons.map),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Tap map to select'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lngController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Longitude (Tap on map)',
                      prefixIcon: const Icon(Icons.map_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Tap map to select'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTimingFields(),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed:
                        () => setState(
                          () =>
                              timings.add({'close_time': '', 'open_time': ''}),
                        ),
                    icon: const Icon(Icons.add, color: AppColors.white),
                    label: const Text("Add Gate Timing"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 13,
                  onTap: (_, latLng) => _onMapTap(latLng),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  if (selectedLatLng != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedLatLng!,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 45,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check, color: AppColors.white),
              label: const Text("Add Railway Gate"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

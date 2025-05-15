import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:realway_manage/constants/app_colors.dart';
import 'package:realway_manage/constants/app_text_styles.dart';

class EditGatePage extends StatefulWidget {
  final Map gateData;

  const EditGatePage({super.key, required this.gateData});

  @override
  State<EditGatePage> createState() => _EditGatePageState();
}

class _EditGatePageState extends State<EditGatePage> {
  final _formKey = GlobalKey<FormState>();
  final _gateNameController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  List<Map<String, String>> timings = [];

  bool isVerified = false;
  LatLng? selectedPoint;

  @override
  void initState() {
    super.initState();
    final data = widget.gateData;

    _gateNameController.text = data['gate_name'] ?? '';
    _latController.text = (data['lat'] ?? '').toString();
    _lngController.text = (data['lng'] ?? '').toString();
    isVerified = data['is_verified'] ?? false;

    final lat = double.tryParse(_latController.text) ?? 18.5204;
    final lng = double.tryParse(_lngController.text) ?? 73.8567;
    selectedPoint = LatLng(lat, lng);

    final t = data['timing'];
    if (t != null && t is List) {
      timings =
          t.map<Map<String, String>>((item) {
            return {
              "open_time": item["open_time"]?.toString() ?? "",
              "close_time": item["close_time"]?.toString() ?? "",
            };
          }).toList();
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        "gate_name": _gateNameController.text.trim(),
        "lat": selectedPoint?.latitude ?? 0.0,
        "lng": selectedPoint?.longitude ?? 0.0,
        "timing": timings,
        "is_verified": isVerified,
      };

      final id = widget.gateData['id'];
      await FirebaseDatabase.instance
          .ref('railway_gates/$id')
          .update(updatedData);
      Navigator.pop(context);
    }
  }

  void _addTiming() {
    setState(() {
      timings.add({"open_time": "", "close_time": ""});
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = selectedPoint ?? LatLng(18.5204, 73.8567);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Edit Railway Gate"),
        backgroundColor: AppColors.background,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _gateNameController,

                decoration: InputDecoration(
                  labelText: "Gate Name",

                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator:
                    (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // 🗺️ Map
              Container(
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: mapCenter,
                    initialZoom: 13,
                    onTap: (_, latLng) {
                      setState(() {
                        selectedPoint = latLng;
                        _latController.text = latLng.latitude.toStringAsFixed(
                          6,
                        );
                        _lngController.text = latLng.longitude.toStringAsFixed(
                          6,
                        );
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    if (selectedPoint != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: selectedPoint!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Latitude",
                        prefixIcon: const Icon(Icons.my_location),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Longitude",
                        prefixIcon: const Icon(Icons.my_location_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              Text("Gate Timings", style: AppTextStyles.title),
              const SizedBox(height: 10),

              ...timings.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.lock),
                          label: Text(
                            item['close_time']?.isNotEmpty == true
                                ? "Closes at ${item['close_time']!}"
                                : "Set Close Time",
                            style: const TextStyle(fontSize: 14),
                          ),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                timings[index]['close_time'] = picked.format(
                                  context,
                                );
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade100,
                            foregroundColor: Colors.red.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.lock_open),
                          label: Text(
                            item['open_time']?.isNotEmpty == true
                                ? "Opens at ${item['open_time']!}"
                                : "Set Open Time",
                            style: const TextStyle(fontSize: 14),
                          ),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                timings[index]['open_time'] = picked.format(
                                  context,
                                );
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade100,
                            foregroundColor: Colors.green.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => setState(() => timings.removeAt(index)),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: OutlinedButton.icon(
                  onPressed: _addTiming,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Timing"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurple,
                    side: const BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text("Gate Verification", style: AppTextStyles.linkText),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: [isVerified, !isVerified],
                onPressed: (index) => setState(() => isVerified = index == 0),
                selectedColor: Colors.white,
                fillColor: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Verified"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Unverified"),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: AppColors.white),
                  label: const Text(
                    "Save Changes",
                    style: TextStyle(color: AppColors.white),
                  ),
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: AppTextStyles.buttonText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

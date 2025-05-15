import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';
import 'package:realway_manage/constants/app_colors.dart'; // optional if using color constants

class AddDestinationPage extends StatefulWidget {
  const AddDestinationPage({super.key});

  @override
  State<AddDestinationPage> createState() => _AddDestinationPageState();
}

class _AddDestinationPageState extends State<AddDestinationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  bool _isVerified = false;

  LatLng? selectedLatLng;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(
    'destinations',
  );

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && selectedLatLng != null) {
      final String name = _nameController.text.trim();
      final double lat = selectedLatLng!.latitude;
      final double lng = selectedLatLng!.longitude;

      try {
        await _dbRef.child(name).set({
          'name': name,
          'lat': lat,
          'lng': lng,
          'is_verified': _isVerified,
        });

        await showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text("✅ Destination Added"),
                content: Text("$name was successfully added."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _nameController.clear();
                      _latController.clear();
                      _lngController.clear();
                      setState(() {
                        _isVerified = false;
                        selectedLatLng = null;
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
        print("❌ Firebase write failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong. Try again.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please complete the form and select a map point."),
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

  @override
  Widget build(BuildContext context) {
    final mapCenter =
        selectedLatLng ?? LatLng(18.5204, 73.8567); // Default to Pune

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Destination'),
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
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Location Name',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter a location name'
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
                                ? 'Select location on map'
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
                                ? 'Select location on map'
                                : null,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check_circle),
              label: const Text("Add Destination"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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

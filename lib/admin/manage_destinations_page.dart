import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:realway_manage/constants/app_colors.dart';

class ManageDestinationsPage extends StatefulWidget {
  const ManageDestinationsPage({super.key});

  @override
  State<ManageDestinationsPage> createState() => _ManageDestinationsPageState();
}

class _ManageDestinationsPageState extends State<ManageDestinationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map> verifiedDestinations = [];
  List<Map> unverifiedDestinations = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchDestinations();
  }

  void fetchDestinations() async {
    final ref = FirebaseDatabase.instance.ref('destinations');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final List<Map> verified = [];
      final List<Map> unverified = [];
      final data = snapshot.value as Map;
      data.forEach((key, value) {
        final destination = Map.of(value);
        destination['id'] = key;
        destination['name'] = key; // Show key as name
        if (destination['is_verified'] == true) {
          verified.add(destination);
        } else {
          unverified.add(destination);
        }
      });
      setState(() {
        verifiedDestinations = verified;
        unverifiedDestinations = unverified;
      });
    }
  }

  void _toggleVerification(Map destination) async {
    final ref = FirebaseDatabase.instance.ref(
      'destinations/${destination['id']}',
    );
    await ref.update({'is_verified': !(destination['is_verified'] ?? false)});
    fetchDestinations();
  }

  void _deleteDestination(Map destination) async {
    final ref = FirebaseDatabase.instance.ref(
      'destinations/${destination['id']}',
    );
    await ref.remove();
    Navigator.pop(context);
    fetchDestinations();
  }

  void _showDetails(Map destination) {
    LatLng selectedPoint = LatLng(destination['lat'], destination['lng']);
    TextEditingController nameController = TextEditingController(
      text: destination['name'] ?? '',
    );

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Edit Destination",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Location Name",
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🗺️ Map View
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 250,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: selectedPoint,
                            initialZoom: 13,
                            onTap: (_, latLng) {
                              setStateDialog(() {
                                selectedPoint = latLng;
                              });
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: selectedPoint,
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
                    ),

                    const SizedBox(height: 12),
                    Text(
                      "Latitude: ${selectedPoint.latitude.toStringAsFixed(6)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "Longitude: ${selectedPoint.longitude.toStringAsFixed(6)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _toggleVerification(destination);
                      },
                      child: Text(
                        destination['is_verified'] ? "Unverify" : "Verify",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final ref = FirebaseDatabase.instance.ref(
                          'destinations/${destination['id']}',
                        );
                        await ref.update({
                          'lat': selectedPoint.latitude,
                          'lng': selectedPoint.longitude,
                        });
                        Navigator.pop(context);
                        fetchDestinations();
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _deleteDestination(destination),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildList(List<Map> destinations) {
    final filtered =
        destinations
            .where(
              (d) => d['name'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
            .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No destinations found"));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final dest = filtered[index];
        final name = dest['name']?.toString().trim();
        return ListTile(
          leading: const Icon(Icons.place),
          title: Text(name != null && name.isNotEmpty ? name : 'Unnamed'),
          subtitle: Text(
            "Lat: ${dest['lat']}, Lng: ${dest['lng']}\nStatus: ${dest['is_verified'] ? 'Verified' : 'Unverified'}",
          ),
          onTap: () => _showDetails(dest),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search destination by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.black54,
            tabs: const [Tab(text: 'Verified'), Tab(text: 'Unverified')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(verifiedDestinations),
                _buildList(unverifiedDestinations),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-destination'),
        label: const Text(
          "Add Destination",
          style: TextStyle(color: AppColors.white),
        ),
        icon: const Icon(
          Icons.add_location_alt_rounded,
          color: AppColors.white,
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

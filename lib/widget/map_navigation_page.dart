import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

class MapNavigationWidget extends StatefulWidget {
  const MapNavigationWidget({super.key});

  @override
  State<MapNavigationWidget> createState() => _MapNavigationWidgetState();
}

class _MapNavigationWidgetState extends State<MapNavigationWidget> {
  final MapController mapController = MapController();
  LatLng? currentLocation;
  LatLng? destination;
  List<LatLng> routePoints = [];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  Map<String, LatLng> destinations = {};
  List<String> matchingDestinations = [];
  String? selectedDestinationName;

  final Distance distance = const Distance();
  List<Marker> gateMarkers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchVerifiedDestinations();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _fetchVerifiedDestinations() async {
    final dbRef = FirebaseDatabase.instance.ref('destinations');
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      final Map data = snapshot.value as Map;
      setState(() {
        destinations = Map.fromEntries(
          data.entries
              .where((e) => e.value['is_verified'] == true)
              .map(
                (e) => MapEntry(
                  e.key.toString(),
                  LatLng(e.value['lat'], e.value['lng']),
                ),
              ),
        );
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      matchingDestinations =
          query.isEmpty
              ? []
              : destinations.keys
                  .where((name) => name.toLowerCase().contains(query))
                  .toList();
    });
  }

  Future<void> _searchAndRoute(String placeName) async {
    final LatLng? target = destinations[placeName];
    if (target == null || currentLocation == null) return;

    destination = target;
    selectedDestinationName = placeName;

    final url =
        'https://router.project-osrm.org/route/v1/driving/${currentLocation!.longitude},${currentLocation!.latitude};${destination!.longitude},${destination!.latitude}?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'];

      setState(() {
        routePoints = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
        matchingDestinations = [];
        _searchFocus.unfocus();
      });

      await _loadNearbyVerifiedGates();
    }
  }

  Future<void> _loadNearbyVerifiedGates() async {
    final gateRef = FirebaseDatabase.instance.ref('railway_gates');
    final snapshot = await gateRef.get();

    if (!snapshot.exists || routePoints.isEmpty) return;

    final Map data = snapshot.value as Map;
    final markers = <Marker>[];

    for (var entry in data.entries) {
      final value = entry.value;
      if (value['is_verified'] == true) {
        final lat = value['lat'];
        final lng = value['lng'];
        final name = value['gate_name'] ?? entry.key;
        final timings = value['timing'] ?? [];

        final gatePoint = LatLng(lat, lng);

        final isNear = routePoints.any(
          (routePoint) => distance(gatePoint, routePoint) <= 100,
        );

        if (isNear) {
          markers.add(
            Marker(
              point: gatePoint,
              width: 80,
              height: 80,
              child: GestureDetector(
                onTap: () {
                  _showGateDetails(context, name, timings, gatePoint);
                },
                child: Column(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    Text(name, style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    setState(() {
      gateMarkers = markers;
    });
  }

  void _showGateDetails(
    BuildContext context,
    String name,
    List timings,
    LatLng gatePoint,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                Text(
                  "🚧 $name",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "🕒 Timings:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                if (timings.isEmpty)
                  const Text("No timings available.")
                else
                  Column(
                    children:
                        timings.map<Widget>((t) {
                          return ListTile(
                            leading: const Icon(Icons.schedule),
                            title: Text(
                              "Close: ${t['close_time']} → Open: ${t['open_time']}",
                            ),
                          );
                        }).toList(),
                  ),
                const Divider(height: 30),
                const Text(
                  "🏥 Nearby Services (within 2km):",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                FutureBuilder<List<String>>(
                  future: _fetchNearbyPlaces(gatePoint),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final places = snapshot.data!;
                    return Column(
                      children:
                          places
                              .map(
                                (place) => ListTile(
                                  leading: const Icon(Icons.place),
                                  title: Text(place),
                                ),
                              )
                              .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<List<String>> _fetchNearbyPlaces(LatLng point) async {
    // For demo purposes, you could fetch from Google Places or return mock data
    // TODO: Replace with actual Places API or your custom backend if needed
    await Future.delayed(const Duration(seconds: 1)); // simulate delay
    return ["Petrol Pump", "City Hospital", "Green Leaf Restaurant"];
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(initialCenter: currentLocation!, initialZoom: 14),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: currentLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.my_location, color: Colors.blue),
                ),
                if (destination != null)
                  Marker(
                    point: destination!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.flag, color: Colors.green),
                  ),
                ...gateMarkers,
              ],
            ),
            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 5,
                    color: Colors.deepPurple,
                  ),
                ],
              ),
          ],
        ),
        Positioned(
          top: 10,
          left: 20,
          right: 20,
          child: Card(
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    decoration: const InputDecoration(
                      labelText: "Search Destination",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  if (matchingDestinations.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: matchingDestinations.length,
                      itemBuilder: (context, index) {
                        final name = matchingDestinations[index];
                        return ListTile(
                          dense: true,
                          title: Text(name),
                          onTap: () => _searchAndRoute(name),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

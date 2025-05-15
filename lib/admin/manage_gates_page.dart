import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:realway_manage/admin/edit_gate_page.dart';
import 'package:get/get.dart';
import 'package:realway_manage/constants/app_colors.dart';

class ManageGatesPage extends StatefulWidget {
  const ManageGatesPage({super.key});

  @override
  State<ManageGatesPage> createState() => _ManageGatesPageState();
}

class _ManageGatesPageState extends State<ManageGatesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map> verifiedGates = [];
  List<Map> unverifiedGates = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchGates();
  }

  void fetchGates() async {
    final ref = FirebaseDatabase.instance.ref('railway_gates');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final List<Map> verified = [];
      final List<Map> unverified = [];
      final data = snapshot.value as Map;
      data.forEach((key, value) {
        final gate = Map.of(value);
        gate['id'] = key;
        if (gate['is_verified'] == true) {
          verified.add(gate);
        } else {
          unverified.add(gate);
        }
      });
      setState(() {
        verifiedGates = verified;
        unverifiedGates = unverified;
      });
    }
  }

  void _toggleVerification(Map gate) async {
    final ref = FirebaseDatabase.instance.ref('railway_gates/${gate['id']}');
    await ref.update({'is_verified': !(gate['is_verified'] ?? false)});
    fetchGates();
  }

  void _deleteGate(Map gate) async {
    final ref = FirebaseDatabase.instance.ref('railway_gates/${gate['id']}');
    await ref.remove();
    fetchGates();
  }

  Widget _buildList(List<Map> gates) {
    final filtered =
        gates
            .where(
              (g) => g['gate_name'].toLowerCase().contains(
                searchQuery.toLowerCase(),
              ),
            )
            .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No gates found'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final gate = filtered[index];
        return ListTile(
          leading: const Icon(Icons.railway_alert),
          title: Text(gate['gate_name'] ?? 'Unnamed'),
          subtitle: Text(
            'Lat: ${gate['lat']}, Lng: ${gate['lng']}\nStatus: ${gate['is_verified'] ? "Verified" : "Unverified"}',
          ),

          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditGatePage(gateData: gate)),
            );
            fetchGates();
          },
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
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search gate by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs: const [Tab(text: 'Verified'), Tab(text: 'Unverified')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(verifiedGates),
                _buildList(unverifiedGates),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add-railway-gate'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text(
          "Add New Gate",
          style: TextStyle(color: AppColors.white),
        ),
      ),
    );
  }
}

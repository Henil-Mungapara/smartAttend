import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartattend/app_size/app_size.dart';

class ViewDivisionScreen extends StatefulWidget {
  const ViewDivisionScreen({super.key});

  @override
  State<ViewDivisionScreen> createState() => _ViewDivisionScreenState();
}

class _ViewDivisionScreenState extends State<ViewDivisionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = "";

  // Cache Class names by ID
  final Map<String, String> _classNames = {};

  @override
  void initState() {
    super.initState();
    _fetchClassNames();
  }

  Future<void> _fetchClassNames() async {
    final snapshot = await _firestore.collection('classes').get();
    setState(() {
      _classNames.clear();
      for (var doc in snapshot.docs) {
        _classNames[doc.id] = doc['name'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB6BFCA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        title: const Text(
          "View Divisions",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 Search Bar
          Padding(
            padding: EdgeInsets.all(AppSize.width(context) * 0.04),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by Division Name or Code",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0047AB)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),

          // 🔹 Division List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('divisions')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0047AB)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Divisions Found"));
                }

                final divisions = snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  final code = doc.id.toLowerCase();
                  return name.contains(_searchQuery) ||
                      code.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.width(context) * 0.04,
                    vertical: AppSize.height(context) * 0.01,
                  ),
                  itemCount: divisions.length,
                  itemBuilder: (context, index) {
                    final doc = divisions[index];
                    final code = doc.id;
                    final name = doc['name'];
                    final classId = doc['classId'];
                    final className = _classNames[classId] ?? "Unknown Class";

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 3,
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0047AB),
                          child: Text(
                            code.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.class_,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(className),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Code: $code",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.edit,
                              color: Color(0xFF0047AB),
                              size: 30,
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.delete,
                              color: Color(0xFF0047AB),
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

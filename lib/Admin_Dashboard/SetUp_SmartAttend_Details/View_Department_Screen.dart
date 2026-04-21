import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartattend/app_size/app_size.dart';

class ViewDepartmentScreen extends StatefulWidget {
  const ViewDepartmentScreen({super.key});

  @override
  State<ViewDepartmentScreen> createState() => _ViewDepartmentScreenState();
}

class _ViewDepartmentScreenState extends State<ViewDepartmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = "";

  Map<String, String> _collegeNames = {};

  @override
  void initState() {
    super.initState();
    _fetchCollegeNames();
  }

  Future<void> _fetchCollegeNames() async {
    final snapshot = await _firestore.collection('colleges').get();
    setState(() {
      _collegeNames = {for (var doc in snapshot.docs) doc.id: doc['name']};
    });
  }

  Future<void> _deleteDepartment(String id) async {
    await _firestore.collection('departments').doc(id).delete();
    if(mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Department Deleted Successfully")));
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Department"),
        content: const Text("Are you sure you want to delete this department?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteDepartment(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  void _showEditDialog(DocumentSnapshot doc) {
    final nameController = TextEditingController(text: doc['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Edit Department"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Department Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0047AB)),
            onPressed: () async {
              await _firestore.collection('departments').doc(doc.id).update({
                'name': nameController.text.trim(),
              });
              if(mounted) Navigator.pop(context);
              if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Department Updated Successfully")));
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB6BFCA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (mounted) Navigator.pop(context); 
          },
        ),
        title: const Text(
          "View Departments",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSize.width(context) * 0.04),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Search by Department Name or Code",
                  prefixIcon: Icon(Icons.search, color: Color(0xFF0047AB)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('departments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0047AB)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Departments Found"));
                }

                final departments = snapshot.data!.docs.where((doc) {
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
                  itemCount: departments.length,
                  itemBuilder: (context, index) {
                    final doc = departments[index];
                    final code = doc.id;
                    final name = doc['name'];
                    final collegeId = doc['collegeId'];
                    final collegeName =
                        _collegeNames[collegeId] ?? "Unknown College";

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
                                  Icons.school,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(collegeName),
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
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF0047AB), size: 28),
                              onPressed: () => _showEditDialog(doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color(0xFF0047AB), size: 28),
                              onPressed: () => _confirmDelete(doc.id),
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

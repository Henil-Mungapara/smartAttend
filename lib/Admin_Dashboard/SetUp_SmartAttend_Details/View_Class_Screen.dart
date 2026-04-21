import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartattend/app_size/app_size.dart';
import '../../utils/UiHelper.dart';

class ViewClassScreen extends StatefulWidget {
  const ViewClassScreen({super.key});

  @override
  State<ViewClassScreen> createState() => _ViewClassScreenState();
}

class _ViewClassScreenState extends State<ViewClassScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";

  late Map<String, String> _departmentNames = {};

  Future<void> _fetchDepartmentNames() async {
    final snapshot = await _firestore.collection('departments').get();
    setState(() {
      _departmentNames = {for (var doc in snapshot.docs) doc.id: doc['name']};
    });
  }

  Future<void> _deleteClass(String id) async {
    await _firestore.collection('classes').doc(id).delete();
    if(mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Class Deleted Successfully")));
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Class"),
        content: const Text("Are you sure you want to delete this class?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteClass(id);
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
        title: const Text("Edit Class"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Class Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0047AB)),
            onPressed: () async {
              await _firestore.collection('classes').doc(doc.id).update({
                'name': nameController.text.trim(),
              });
              if(mounted) Navigator.pop(context);
              if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Class Updated Successfully")));
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchDepartmentNames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSize.width(context);
    double height = AppSize.height(context);

    return Scaffold(
      backgroundColor: const Color(0xFFB6BFCA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "View Classes",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          
          Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Search by Class Name or Code",
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
                  .collection('classes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0047AB)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Classes Found"));
                }

                final classes = snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  final code = doc.id.toLowerCase();

                  return name.contains(_searchQuery) ||
                      code.contains(_searchQuery);
                }).toList();

                if (classes.isEmpty) {
                  return const Center(child: Text("No Matching Classes"));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.01,
                  ),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final doc = classes[index];
                    final code = doc.id;
                    final name = doc['name'];
                    final departmentId = doc['departmentId'];

                    final departmentName =
                        _departmentNames[departmentId] ?? "Unknown Department";

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.symmetric(vertical: height * 0.008),
                      elevation: 4,
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.015),
                        leading: CircleAvatar(
                          radius: width * 0.06,
                          backgroundColor: const Color(0xFF0047AB),
                          child: Text(
                            code.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: width * 0.05),
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: width * 0.04),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height * 0.005),
                            Row(
                              children: [
                                const Icon(Icons.business, size: 16, color: Colors.grey),
                                SizedBox(width: width * 0.01),
                                Expanded(
                                  child: Text(departmentName, style: TextStyle(fontSize: width * 0.035)),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.004),
                            Text("Code: $code", style: TextStyle(fontSize: width * 0.032, color: Colors.black54)),
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
                              onPressed: () => _confirmDelete(code),
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

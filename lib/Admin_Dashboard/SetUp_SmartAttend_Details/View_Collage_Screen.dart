import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartattend/app_size/app_size.dart';

class ViewCollegeScreen extends StatefulWidget {
  const ViewCollegeScreen({super.key});

  @override
  State<ViewCollegeScreen> createState() => _ViewCollegeScreenState();
}

class _ViewCollegeScreenState extends State<ViewCollegeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = "";

  Future<void> deleteCollege(String id) async {
    await _firestore.collection('colleges').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("College Deleted Successfully")),
    );
  }

  void showEditDialog(DocumentSnapshot doc) {
    final nameController = TextEditingController(text: doc['name']);
    final cityController = TextEditingController(text: doc['city']);
    final emailController = TextEditingController(text: doc['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Edit College"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "College Name"),
                ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: "City"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0047AB),
              ),
              onPressed: () async {
                await _firestore.collection('colleges').doc(doc.id).update({
                  'name': nameController.text.trim(),
                  'city': cityController.text.trim(),
                  'email': emailController.text.trim(),
                });
                if (mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("College Updated Successfully")),
                );
              },
              child: const Text("Update",style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete College"),
          content: const Text("Are you sure you want to delete this college?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                deleteCollege(id);
                if (mounted) Navigator.pop(context);
              },
              child: const Text("Delete"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = AppSize.width(context);
    double h = AppSize.height(context);
    return Scaffold(
      backgroundColor: const Color(0xFFB6BFCA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        title: const Text("View Colleges",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          
          Padding(
            padding: EdgeInsets.all(w * 0.04),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Search by College Name or Code",
                  prefixIcon:
                  Icon(Icons.search, color: Color(0xFF0047AB)),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 15),
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
                  .collection('colleges')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF0047AB)),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No Colleges Found"));
                }

                final colleges =
                snapshot.data!.docs.where((doc) {
                  final name =
                  doc['name'].toString().toLowerCase();
                  final code = doc.id.toLowerCase();
                  return name.contains(_searchQuery) ||
                      code.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.04,
                      vertical: h * 0.01),
                  itemCount: colleges.length,
                  itemBuilder: (context, index) {
                    final doc = colleges[index];
                    final id = doc.id;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                      margin:
                      EdgeInsets.symmetric(vertical: h * 0.008),
                      elevation: 4,
                      child: ListTile(
                        contentPadding:
                        EdgeInsets.symmetric(
                            horizontal: w * 0.04,
                            vertical: h * 0.015),
                        leading: CircleAvatar(
                          radius: w * 0.06,
                          backgroundColor:
                          const Color(0xFF0047AB),
                          child: Text(
                            id.substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          doc['name'],
                          style: TextStyle(
                              fontWeight:
                              FontWeight.bold,
                              fontSize: w * 0.04),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: h * 0.005),
                            Text("City: ${doc['city']}"),
                            Text("Email: ${doc['email']}"),
                            Text(
                              "ID: $id",
                              style: TextStyle(
                                  fontSize: w * 0.03,
                                  color:
                                  Colors.black54),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 28, color: Color(0xFF0047AB)),
                              onPressed: () => showEditDialog(doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 28, color: Color(0xFF0047AB)),
                              onPressed: () => confirmDelete(id),
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
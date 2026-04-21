import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartattend/app_size/app_size.dart';

class ViewSubjectScreen extends StatefulWidget {
  const ViewSubjectScreen({super.key});

  @override
  State<ViewSubjectScreen> createState() => _ViewSubjectScreenState();
}

class _ViewSubjectScreenState extends State<ViewSubjectScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = "";

  Future<void> _deleteSubject(String id) async {
    await _firestore.collection('subjects').doc(id).delete();
    if(mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subject Deleted Successfully")));
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Subject"),
        content: const Text("Are you sure you want to delete this subject?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteSubject(id);
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
        title: const Text("Edit Subject"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Subject Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0047AB)),
            onPressed: () async {
              await _firestore.collection('subjects').doc(doc.id).update({
                'name': nameController.text.trim(),
              });
              if(mounted) Navigator.pop(context);
              if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subject Updated Successfully")));
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
          "View Subjects",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  hintText: "Search by Subject Name or Code",
                  prefixIcon: Icon(Icons.search, color: Color(0xFF0047AB)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('subjects').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0047AB)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No Subjects Found", style: TextStyle(color: Colors.black54)),
                  );
                }

                final subjects = snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  final code = doc.id.toLowerCase();
                  return name.contains(_searchQuery) || code.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.width(context) * 0.04,
                    vertical: AppSize.height(context) * 0.01,
                  ),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final doc = subjects[index];
                    final code = doc.id;
                    final name = doc['name'];
                    final classId = doc['classId'] ?? "Unknown Class";

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 3,
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0047AB),
                          child: Text(
                            code.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.class_, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("Class: $classId"),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Code: $code",
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
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
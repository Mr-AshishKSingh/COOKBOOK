import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart'; // Import the ProfileScreen

class AllCooksScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const AllCooksScreen({
    super.key, 
    required this.userId,
    required this.userName,
  });

  @override
  State<AllCooksScreen> createState() => _AllCooksScreenState();
}

class _AllCooksScreenState extends State<AllCooksScreen> {
  String? selectedLocation;
  String? selectedFoodType;
  final List<String> locations = ['Alpha', 'Beta', 'Gamma', 'Delta'];
  final List<String> foodTypes = ['Veg', 'Non-Veg'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Available Cooks',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.brown[800],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F6F0),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedLocation,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Locations'),
                      ),
                      ...locations.map((loc) => DropdownMenuItem(
                        value: loc,
                        child: Text(loc),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedLocation = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Food Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedFoodType,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Types'),
                      ),
                      ...foodTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedFoodType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Cooks List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No cooks found!',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.brown[400],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final cook = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final cookId = snapshot.data!.docs[index].id;

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                              collection: 'cooks',
                              docId: cookId, // cookId from Firestore doc
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    cook['name'] ?? 'Unknown Cook',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    cook['foodType'] == 'Veg' 
                                      ? Icons.eco 
                                      : Icons.set_meal,
                                    color: cook['foodType'] == 'Veg' 
                                      ? Colors.green 
                                      : Colors.red,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Speciality: ${cook['speciality']}'),
                              Text('Wage: ₹${cook['wagePerHour']}/hour'),
                              Text('Working Hours: ${cook['workingHours']}'),
                              Text('Locations: ${(cook['location'] as List).join(", ")}'),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown[700],
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => _sendHireRequest(cookId, cook['name']),
                                  child: Text(
                                    'Send Hire Request',
                                    style: GoogleFonts.poppins(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Stream<QuerySnapshot> _buildQuery() {
    Query query = FirebaseFirestore.instance.collection('cooks');
    
    if (selectedLocation != null) {
      query = query.where('location', arrayContains: selectedLocation);
    }
    
    if (selectedFoodType != null) {
      query = query.where('foodType', isEqualTo: selectedFoodType);
    }
    
    return query.snapshots();
  }

  Future<void> _sendHireRequest(String cookId, String cookName) async {
    try {
      // Create the hire request
      final requestRef = await FirebaseFirestore.instance.collection('work_requests').add({
        'userId': widget.userId,
        'userName': widget.userName,
        'cookId': cookId,
        'cookName': cookName,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Create a notification for the cook
      await FirebaseFirestore.instance.collection('notifications').add({
        'recipientId': cookId, // cook ka UID
        'senderId': widget.userId,
        'senderName': widget.userName,
        'type': 'hire_request',
        'status': 'unread',
        'message': '${widget.userName} wants to hire you!',
        'timestamp': FieldValue.serverTimestamp(),
        'requestId': requestRef.id,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hire request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send hire request. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
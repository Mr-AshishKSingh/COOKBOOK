import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'post_cook_need_screen.dart';
import 'all_cooks_screen.dart';
import 'profile_screen.dart'; // <-- Import ProfileScreen

class UserHomeScreen extends StatefulWidget {
  final String userLocation; // Pass user's location for filtering

  const UserHomeScreen({super.key, required this.userLocation});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String? currentUserId;
  String? currentUserName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  Future<void> fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      // Fetch user name from Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      setState(() {
        currentUserName = doc.data()?['name'] ?? '';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Cooks Near You',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.brown[800],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.brown[800]),
        automaticallyImplyLeading: false, // <-- Add this line
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllCooksScreen(
                    userId: currentUserId!,
                    userName: currentUserName!,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F6F0),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.brown[700],
        icon: const Icon(Icons.add),
        label: Text(
          'Post Cook Need',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostCookNeedScreen()),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cooks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No cooks available!',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.brown[400]),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                        collection: 'cooks',
                        docId: snapshot.data!.docs[index].id, // Pass the cook's Firestore doc ID
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 6,
                  margin: const EdgeInsets.only(bottom: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.brown[100],
                      child: Icon(Icons.restaurant, color: Colors.brown[700]),
                    ),
                    title: Text(
                      data['name'] ?? 'Cook',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.brown[800],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on, color: Colors.brown[400], size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                (data['location'] as List<dynamic>?)?.join(', ') ?? '',
                                style: GoogleFonts.poppins(
                                  color: Colors.brown[600],
                                  fontSize: 14,
                                ),
                                maxLines: 2, // or null for unlimited lines
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Wage: ₹${data['wagePerHour'] ?? 'N/A'}/hr',
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                        Text(
                          'Working Hours: ${data['workingHours'] ?? 'N/A'}',
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                        if (data['speciality'] != null)
                          Text(
                            'Speciality: ${data['speciality']}',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.brown[400]),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: () async {
                        try {
                          // Create the hiring request
                          final requestRef = await FirebaseFirestore.instance.collection('hiring_requests').add({
                            'cookId': snapshot.data!.docs[index].id, // Use the cook's document ID
                            'cookName': data['name'],
                            'userId': currentUserId,
                            'userName': currentUserName,
                            'status': 'pending',
                            'timestamp': FieldValue.serverTimestamp(),
                            'userLocation': widget.userLocation,
                          });

                          // Create notification for the cook
                          await FirebaseFirestore.instance.collection('notifications').add({
                            'recipientId': snapshot.data!.docs[index].id, // Cook's ID
                            'senderId': currentUserId,
                            'senderName': currentUserName,
                            'type': 'hire_request',
                            'status': 'unread',
                            'message': '$currentUserName wants to hire you',
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
                      },
                      child: Text('Hire'),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
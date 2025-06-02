import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CookRequestsScreen extends StatelessWidget {
  const CookRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cook Requests',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.brown[800],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.brown[800]),
      ),
      backgroundColor: const Color(0xFFF8F6F0),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cook_requests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No requests yet!',
                style: GoogleFonts.poppins(
                    fontSize: 18, color: Colors.brown[400]),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data()
                  as Map<String, dynamic>;
              final location = data['location'];
              String locationString = '';
              if (location is List && location.isNotEmpty) {
                locationString = location.join(', ');
              } else if (location is String) {
                locationString = location;
              }

              return Card(
                elevation: 6,
                margin: const EdgeInsets.only(bottom: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.brown[100],
                            child: Icon(Icons.person, color: Colors.brown[700]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              data['userName'] ?? 'User',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                color: Colors.brown[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.brown[400], size: 18),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationString,
                              style: GoogleFonts.poppins(
                                color: Colors.brown[600],
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Request: ${data['requestDetail'] ?? ''}',
                        style: GoogleFonts.poppins(
                            fontSize: 15, color: Colors.brown[700]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Time: ${data['timestamp'] ?? ''}',
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.brown[400]),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final cookId = FirebaseAuth.instance.currentUser!.uid;
                            // Fetch cookName from Firestore
                            final cookDoc = await FirebaseFirestore.instance.collection('cooks').doc(cookId).get();
                            final cookName = cookDoc.data()?['name'] ?? '';

                            await FirebaseFirestore.instance
                                .collection('work_requests')
                                .add({
                              'userId': data['userID'], // This should be present in the user's request data
                              'userName': data['userName'],
                              'cookId': cookId,
                              'cookName': cookName,
                              'requestDetail': "I'm interested in your request",
                              'status': 'pending',
                              'timestamp': DateTime.now().toIso8601String(),
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Work request sent to user!')),
                            );
                          },
                          child: Text(
                            'Send Work Request',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
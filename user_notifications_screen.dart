import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class UserNotificationsScreen extends StatelessWidget {
  final String userId; // Pass the current user's ID

  const UserNotificationsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Work Requests',
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
        automaticallyImplyLeading: false, // <-- Add this line
      ),
      backgroundColor: const Color(0xFFF8F6F0),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('work_requests')
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet!',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.brown[400]),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 6,
                margin: const EdgeInsets.only(bottom: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: ListTile(
                  leading: const Icon(Icons.work),
                  title: Text(data['cookName'] ?? 'Cook'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Message: ${data['requestDetail'] ?? ''}'),
                      Text('Status: ${data['status'] ?? ''}'),
                      Text('Time: ${data['timestamp'] ?? ''}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          // Accept the request in Firestore
                          await FirebaseFirestore.instance
                              .collection('work_requests')
                              .doc(snapshot.data!.docs[index].id)
                              .update({'status': 'accepted'});

                          // Notify the cook
                          await FirebaseFirestore.instance.collection('notifications').add({
                            'recipientId': data['cookId'], // cook's UID
                            'senderId': userId,
                            'senderName': data['userName'],
                            'type': 'request_accepted',
                            'status': 'unread',
                            'message': 'Your work request has been accepted!',
                            'timestamp': FieldValue.serverTimestamp(),
                            'requestId': snapshot.data!.docs[index].id,
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Request accepted!')),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('work_requests')
                              .doc(snapshot.data!.docs[index].id)
                              .update({'status': 'rejected'});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Request rejected!')),
                          );
                        },
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
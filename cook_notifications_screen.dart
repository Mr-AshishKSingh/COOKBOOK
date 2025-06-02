import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CookNotificationsScreen extends StatelessWidget {
  final String cookId;

  const CookNotificationsScreen({super.key, required this.cookId});

  @override
  Widget build(BuildContext context) {
    print('CookNotificationsScreen cookId: $cookId');

    if (cookId.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.brown[800],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientId', isEqualTo: cookId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.brown[400],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final notification = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final notificationId = snapshot.data!.docs[index].id;
              final bool isUnread = notification['status'] == 'unread';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isUnread ? Colors.brown[700] : Colors.brown[200],
                    child: const Icon(Icons.person_add, color: Colors.white),
                  ),
                  title: Text(
                    notification['message'],
                    style: GoogleFonts.poppins(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    _formatTimestamp(notification['timestamp']),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => _acceptRequest(context, notification['requestId']),
                        child: Text(
                          'Accept',
                          style: GoogleFonts.poppins(color: Colors.green),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _declineRequest(context, notification['requestId']),
                        child: Text(
                          'Decline',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  onTap: () { 
                    // Mark as read when tapped
                    if (isUnread) {
                      FirebaseFirestore.instance
                          .collection('notifications')
                          .doc(notificationId)
                          .update({'status': 'read'});
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _acceptRequest(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('hiring_requests')
          .doc(requestId)
          .update({'status': 'accepted'});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to accept request. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _declineRequest(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('hiring_requests')
          .doc(requestId)
          .update({'status': 'declined'});
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request declined')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to decline request. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
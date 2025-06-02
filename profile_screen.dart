import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  final String collection; // 'users' or 'cooks'
  final String docId;      // userId or cookId

  const ProfileScreen({super.key, required this.collection, required this.docId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection(collection).doc(docId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Profile not found!',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (collection == 'cooks') {
            return CookProfileSection(data: data);
          } else {
            return UserProfileSection(data: data, userId: docId); // docId is user's UID
          }
        },
      ),
    );
  }
}

class CookProfileSection extends StatelessWidget {
  final Map<String, dynamic> data;
  const CookProfileSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<String> locations = (data['location'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final String cookId = data['uid'] ?? ''; // Make sure 'uid' is present in cook's data

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    data['name'] ?? 'Name',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['email'] ?? 'Email',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['phone'] ?? 'Phone',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['address'] ?? 'Address',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber[400], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Speciality: ',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.brown[700]),
                      ),
                      Text(
                        data['speciality'] ?? '',
                        style: GoogleFonts.poppins(color: Colors.brown[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.currency_rupee, color: Colors.green[400], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Wage/hr: ',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.brown[700]),
                      ),
                      Text(
                        '₹${data['wagePerHour'] ?? ''}',
                        style: GoogleFonts.poppins(color: Colors.brown[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, color: Colors.blue[300], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Working Hours: ',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.brown[700]),
                      ),
                      Text(
                        data['workingHours'] ?? '',
                        style: GoogleFonts.poppins(color: Colors.brown[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[300], size: 20),
                const SizedBox(width: 6),
                Text(
                  'Available Locations',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.brown[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          locations.isEmpty
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No locations specified',
                    style: GoogleFonts.poppins(color: Colors.brown[400]),
                  ),
                )
              : Wrap(
                  spacing: 10,
                  children: locations
                      .map((loc) => Chip(
                            label: Text(loc, style: GoogleFonts.poppins(color: Colors.white)),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          ))
                      .toList(),
                ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Working At',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.brown[800],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('work_requests')
                .where('cookId', isEqualTo: cookId)
                .where('status', isEqualTo: 'accepted')
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No current work allotted', style: GoogleFonts.poppins());
              }
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final userData = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: Icon(Icons.home, color: Colors.blue),
                      title: Text('User: ${userData['userName'] ?? ''}'),
                      subtitle: Text('Contact: ${userData['userId'] ?? ''}'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class UserProfileSection extends StatelessWidget {
  final Map<String, dynamic> data;
  final String userId; // Pass the user's UID

  const UserProfileSection({super.key, required this.data, required this.userId});

  @override
  Widget build(BuildContext context) {
    final List<String> locations = (data['location'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    data['name'] ?? 'Name',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['email'] ?? 'Email',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['phone'] ?? 'Phone',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['address'] ?? 'Address',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.green[400], size: 20),
                const SizedBox(width: 6),
                Text(
                  'Preferred Locations',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.brown[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          locations.isEmpty
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No locations specified',
                    style: GoogleFonts.poppins(color: Colors.brown[400]),
                  ),
                )
              : Wrap(
                  spacing: 10,
                  children: locations
                      .map((loc) => Chip(
                            label: Text(loc, style: GoogleFonts.poppins(color: Colors.white)),
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                          ))
                      .toList(),
                ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Alloted Cook',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.brown[800],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('work_requests')
                .where('userId', isEqualTo: userId) // pass userId to this widget
                .where('status', isEqualTo: 'accepted')
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No cook accepted yet', style: GoogleFonts.poppins());
              }
              // Show all accepted cooks (if multiple)
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final cookData = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: Icon(Icons.person, color: Colors.green),
                      title: Text('Accepted Cook: ${cookData['cookName']}'),
                      subtitle: Text('Contact: ${cookData['cookId']}'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
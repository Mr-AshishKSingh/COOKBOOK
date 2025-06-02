import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostCookNeedScreen extends StatefulWidget {
  const PostCookNeedScreen({super.key});

  @override
  State<PostCookNeedScreen> createState() => _PostCookNeedScreenState();
}

class _PostCookNeedScreenState extends State<PostCookNeedScreen> {
  final _formKey = GlobalKey<FormState>();
  final locationController = TextEditingController();
  final requestDetailController = TextEditingController();
  bool isLoading = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Post Cook Need',
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
      ),
      backgroundColor: const Color(0xFFF8F6F0),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Post Your Cook Need',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[800],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: requestDetailController,
                        decoration: InputDecoration(
                          labelText: 'Request Details',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter details';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      if (error.isNotEmpty)
                        Text(error, style: const TextStyle(color: Colors.red)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                      error = '';
                                    });
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('cook_requests')
                                          .add({
                                        'location': [locationController.text],
                                        'requestDetail': requestDetailController.text,
                                        'timestamp': DateTime.now().toIso8601String(),
                                        'userID': FirebaseAuth.instance.currentUser!.uid,
                                        'userName': '', // fetch from user profile
                                      });
                                      Navigator.pop(context);
                                    } catch (e) {
                                      setState(() {
                                        error = 'Failed to post request';
                                      });
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Post Request',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
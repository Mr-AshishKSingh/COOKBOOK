import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class CookSignupScreen extends StatefulWidget {
  const CookSignupScreen({super.key});

  @override
  State<CookSignupScreen> createState() => _CookSignupScreenState();
}

class _CookSignupScreenState extends State<CookSignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String error = '';
  String successMessage = '';
  String? foodType;
  String? wagePerHour;
  String? workingHours;

  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final List<String> allLocations = ['Alpha', 'Beta', 'Gamma', 'Delta'];
  List<String> selectedLocations = [];

  final List<String> wageOptions = [
    '₹1000 / person',
    '₹1500 / person',
    '₹2000 / person',
    '₹3000 / person',
  ];

  final List<String> workingHoursOptions = [
    '6:00 AM - 10:00 AM',
    '8:00 AM - 12:00 PM',
    '10:00 AM - 2:00 PM',
    '12:00 PM - 4:00 PM',
    '2:00 PM - 6:00 PM',
    '4:00 PM - 8:00 PM',
    '6:00 PM - 10:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cook Signup'),
        backgroundColor: colorScheme.surface,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      backgroundColor: colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'lib/assets/images/cook.png',
                        height: 80,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Create Cook Account',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter your email' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Enter your phone number' : null,
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        value: wagePerHour,
                        decoration: InputDecoration(
                          labelText: 'Wage per Hour',
                          prefixIcon: const Icon(Icons.currency_rupee),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: wageOptions
                            .map((option) => DropdownMenuItem(
                                  value: option,
                                  child: Text(option),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            wagePerHour = value;
                          });
                        },
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Select wage per hour' : null,
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<String>(
                        value: workingHours,
                        decoration: InputDecoration(
                          labelText: 'Working Hours',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: workingHoursOptions
                            .map((option) => DropdownMenuItem(
                                  value: option,
                                  child: Text(option),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            workingHours = value;
                          });
                        },
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Select working hours' : null,
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Select Locations',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: allLocations.map((loc) {
                          final isSelected = selectedLocations.contains(loc);
                          return FilterChip(
                            label: Text(loc),
                            selected: isSelected,
                            selectedColor: colorScheme.primary.withOpacity(0.2),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedLocations.add(loc);
                                } else {
                                  selectedLocations.remove(loc);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      Card(
                        color: colorScheme.secondary.withOpacity(0.1),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.restaurant_menu, color: colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Food Type',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  ChoiceChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.eco, color: Colors.green, size: 20),
                                        SizedBox(width: 6),
                                        Text('Veg'),
                                      ],
                                    ),
                                    selected: foodType == 'Veg',
                                    selectedColor: Colors.green[100],
                                    onSelected: (selected) {
                                      setState(() {
                                        foodType = 'Veg';
                                      });
                                    },
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color: foodType == 'Veg' ? Colors.green[900] : colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  ChoiceChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.set_meal, color: Colors.redAccent, size: 20),
                                        SizedBox(width: 6),
                                        Text('Non-Veg'),
                                      ],
                                    ),
                                    selected: foodType == 'Non-Veg',
                                    selectedColor: Colors.red[100],
                                    onSelected: (selected) {
                                      setState(() {
                                        foodType = 'Non-Veg';
                                      });
                                    },
                                    backgroundColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color: foodType == 'Non-Veg' ? Colors.red[900] : colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (error.isNotEmpty)
                        Text(error, style: const TextStyle(color: Colors.red)),
                      if (successMessage.isNotEmpty)
                        Text(successMessage, style: const TextStyle(color: Colors.green)),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (selectedLocations.isEmpty) {
                                setState(() => error = 'Please select at least one location');
                                return;
                              }
                              if (foodType == null) {
                                setState(() => error = 'Please select food type');
                                return;
                              }
                              if (wagePerHour == null) {
                                setState(() => error = 'Please select wage per hour');
                                return;
                              }
                              if (workingHours == null) {
                                setState(() => error = 'Please select working hours');
                                return;
                              }
                              final result = await AuthService().signUp(
                                emailController.text,
                                passwordController.text,
                                'cook',
                              );
                              if (result == null) {
                                final cookId = FirebaseAuth.instance.currentUser!.uid;
                                await FirebaseFirestore.instance.collection('cooks').doc(cookId).set({
                                  'name': nameController.text,
                                  'email': emailController.text,
                                  'phone': phoneController.text,
                                  'location': selectedLocations,
                                  'speciality': 'All type of food',
                                  'wagePerHour': wagePerHour,
                                  'workingHours': workingHours,
                                  'foodType': foodType,
                                });
                                setState(() {
                                  successMessage = 'Signup successful!';
                                  error = '';
                                });
                              } else {
                                setState(() {
                                  error = result;
                                  successMessage = '';
                                });
                              }
                            }
                          },
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
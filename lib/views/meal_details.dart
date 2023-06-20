import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Meal {
  final String mealId;
  final String name;
  final String description;
  final String location;
  final String photo;
  final String status;
  final String date;

  Meal({
    required this.mealId,
    required this.name,
    required this.description,
    required this.location,
    required this.photo,
    required this.status,
    required this.date,
  });
}



class MealDetailsScreen extends StatefulWidget {
  final Meal meal;

  const MealDetailsScreen({required this.meal});

  @override
  _MealDetailsScreenState createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  void _launchGoogleMaps(String coordinates) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$coordinates';
    try {
      await launch(
        url,
        forceWebView: true,
        enableJavaScript: true, // Enable JavaScript support
      );
    } catch (e) {
      print('Error launching Google Maps website: $e');
      // Handle the error gracefully or show an error message to the user
    }
  }

  void _uploadData(String mealId) async {
  try {
    final DocumentSnapshot<Map<String, dynamic>> mealDoc =
        await FirebaseFirestore.instance.collection('meals').doc(mealId).get();

    final String mealStatus = mealDoc.data()?['status'] ?? '';

    if (mealStatus == 'booked') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meal is already booked!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      await FirebaseFirestore.instance.collection('meals').doc(mealId).update({
        'status': 'booked',
        'receiverID': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meal booked successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    print('Error updating meal status: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to book the meal. Please try again.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              widget.meal.photo,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.meal.name,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Description:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.meal.description,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Location:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.meal.location,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Status:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.meal.status,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement chat functionality
                      },
                      child: Text('Chat'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _launchGoogleMaps(widget.meal.location);
                      },
                      child: Text('Google Map'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _uploadData(widget.meal.mealId);
                      },
                      child: Text('Book'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

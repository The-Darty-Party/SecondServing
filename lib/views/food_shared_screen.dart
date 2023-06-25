import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secondserving/views/share_meal_screen.dart';
import 'profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'meal_details.dart';

class FoodReceiverScreen extends StatefulWidget {
  const FoodReceiverScreen({Key? key}) : super(key: key);

  @override
  _FoodReceiverScreenState createState() => _FoodReceiverScreenState();
}

class _FoodReceiverScreenState extends State<FoodReceiverScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = '';
  List<Meal> _meals = [];
  bool _sortMealsByNewest = false;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchMeals();
  }

  Future<void> _fetchUserName() async {
    User? currentUser = _firebaseAuth.currentUser;

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (snapshot.exists) {
        setState(() {
          _userName = snapshot['name'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> _fetchMeals() async {
    try {
      final String userId = _firebaseAuth.currentUser?.uid ?? '';
      Query<Map<String, dynamic>> mealsQuery =
          FirebaseFirestore.instance.collection('meals');

      if (_sortMealsByNewest) {
        mealsQuery = mealsQuery.orderBy('date', descending: true);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await mealsQuery.get();
      final List<Meal> meals = snapshot.docs.map((doc) {
        final data = doc.data();
        final String mealStatus = data['status'] ?? '';
        final String mealDonorID = data['donorID'] ?? '';
        final String mealReceiverID = data['receiverID'] ?? '';

        if (mealStatus == 'booked' &&
            mealDonorID != userId &&
            mealReceiverID != userId) {
          return null; // Skip this meal if it's booked and not assigned to the user
        }

        final Timestamp timestamp = data['date'] ?? Timestamp.now(); // Get the timestamp

        return Meal(
          mealId: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          location: data['location'] ?? '',
          photo: data['photo'] ?? '',
          status: mealStatus,
          date: timestamp.toDate().toString(), // Convert timestamp to string
        );
      }).whereType<Meal>().toList();

      setState(() {
        _meals = meals;
      });
    } catch (e) {
      print('Error fetching meals: $e');
    }
  }

  void _navigateToMealDetails(Meal meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealDetailsScreen(meal: meal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Food Nearby'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // TODO: Implement history button functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              setState(() {
                _sortMealsByNewest = !_sortMealsByNewest;
                _fetchMeals();
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_circle,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _userName,
                    style: TextStyle(
                      color: Colors.white,
                       fontSize: 20, 
                       fontWeight: FontWeight.bold, 
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await _firebaseAuth.signOut();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _meals.length,
        itemBuilder: (context, index) {
          final meal = _meals[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: SizedBox(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    meal.photo,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                meal.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Location: ${meal.location}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Description: ${meal.description}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Status: ${meal.status}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              onTap: () {
                _navigateToMealDetails(meal);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DishForm()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

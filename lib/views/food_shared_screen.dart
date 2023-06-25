import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secondserving/views/share_meal_screen.dart';
import '../models/meal_model.dart';
import 'chat_history_screen.dart';
import 'profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'messages_screen.dart';

class FoodReceiverScreen extends StatefulWidget {
  const FoodReceiverScreen({Key? key}) : super(key: key);

  @override
  _FoodReceiverScreenState createState() => _FoodReceiverScreenState();
}

class _FoodReceiverScreenState extends State<FoodReceiverScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  List<Meal> _meals = [];

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  Future<void> _fetchMeals() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('meals').get();
      final List<Meal> meals = snapshot.docs.map((doc) {
        final data = doc.data();
        return Meal(
          mealId: doc.id,
          donorId: data['donorID'] ?? '',
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          location: data['location'] ?? '',
          photo: data['photo'] ?? '',
          status: data['status'] ?? '',
        );
      }).toList();

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
                    'Username: ${user?.displayName ?? "N/A"}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Email: ${user?.email ?? "N/A"}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Profile'),
              leading: Icon(Icons.person),
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
              title: Text('Chat'),
              leading: Icon(Icons.chat),
              onTap: () {
                // TODO: Implement the chat functionality
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatHistoryScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              leading: Icon(Icons.logout),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
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
                    'description: ${meal.description}',
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

//* Details screen
class MealDetailsScreen extends StatefulWidget {
  final Meal meal;
  final User? user = FirebaseAuth.instance.currentUser;
  final chatsCollection = FirebaseFirestore.instance.collection('chats');
  final usersCollection = FirebaseFirestore.instance.collection('users');
  late DocumentReference? _currentChatRef;
  MealDetailsScreen({required this.meal});

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
          await FirebaseFirestore.instance
              .collection('meals')
              .doc(mealId)
              .get();

      final String mealStatus = mealDoc.data()?['status'] ?? '';

      if (mealStatus == 'booked') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal is already booked!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('meals')
            .doc(mealId)
            .update({'status': 'booked'});

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

  Future<void> _getCurrentChat() async {
    final querySnapshot =
        await widget.chatsCollection.where('chatId', arrayContainsAny: [
      '${widget.user!.uid}${widget.meal.donorId}',
      '${widget.meal.donorId}${widget.user!.uid}'
    ]).get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        widget._currentChatRef = querySnapshot.docs.first.reference;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MessagesScreen(receiverUID: widget.meal.donorId)),
      );
    } else {
      final newChatDoc = await widget.chatsCollection.add({
        'currentUserId': widget.user!.uid,
        'peerId': widget.meal.donorId,
        'participants': [widget.user!.uid, widget.meal.donorId],
        'chatId': [
          '${widget.meal.donorId}${widget.user!.uid}',
          '${widget.meal.donorId}${widget.user!.uid}'
        ],
        'lastMessage': '',
      });

      setState(() {
        widget._currentChatRef = newChatDoc;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MessagesScreen(receiverUID: widget.meal.donorId)),
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
                    if (widget.meal.donorId != widget.user!.uid)
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implement chat functionality

                          _getCurrentChat();
                        },
                        child: Text('Chat'),
                      ),
                    ElevatedButton(
                      onPressed: () {
                        _launchGoogleMaps(widget.meal.location);
                      },
                      child: Text('Google Map'),
                    ),
                    if (widget.meal.donorId != widget.user!.uid)
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

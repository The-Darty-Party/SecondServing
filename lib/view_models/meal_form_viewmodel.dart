import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MealFormViewModel {
  final CollectionReference _mealsCollection =
      FirebaseFirestore.instance.collection('meals');

  Future<void> uploadData({
    required String mealName,
    required String description,
    required String location,
    required GeoPoint coordinates,
    required File? pickedImage,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? donorId = user?.uid;
    final String? receiverId = '';

    // Generate a unique filename for the uploaded image
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final FirebaseStorage storage =
        FirebaseStorage.instanceFor(bucket: 'secondserving-ef1f1.appspot.com');
    final Reference storageRef = storage.ref().child(fileName);
    final UploadTask uploadTask = storageRef.putFile(pickedImage!);

    // Get the download URL of the uploaded image
    String? photoUrl;
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
    photoUrl = await taskSnapshot.ref.getDownloadURL();

    final Map<String, dynamic> data = {
      'description': description,
      'location': location,
      'coordinates': coordinates,
      'name': mealName,
      'photo': photoUrl,
      'status': 'not booked',
      'donorID': donorId,
      'receiverID': receiverId,
      'date': DateTime.now(),
    };

    await _mealsCollection.add(data);
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '/widgets/image_picker_button.dart';
import '../widgets/coordinate_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DishForm extends StatefulWidget {
  @override
  _DishFormState createState() => _DishFormState();
}

class _DishFormState extends State<DishForm> {
  TextEditingController _dishNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  GeoPoint? _currentCoordinates;
  File? _pickedImage;
  UploadTask? uploadTask;
  Reference? storageRef;

  @override
  void initState() {
    super.initState();
  }

  void _updateCoordinates(Future<GeoPoint> data) {
    setState(() {
      data.then((value) {
        _currentCoordinates = value;
      });
    });
  }

  void _updateImage(File image) {
    setState(() {
      _pickedImage = image;
    });
  }

  Future<void> _uploadData() async {
    final FirebaseStorage storage =
        FirebaseStorage.instanceFor(bucket: 'secondserving-ef1f1.appspot.com');
    storageRef = storage.ref().child('$_pickedImage');
    storageRef = storage.ref().child('$_pickedImage');
    if (_pickedImage != null && storageRef != null) {
      uploadTask = storageRef!.putFile(_pickedImage!);
    }

    final data = {
      'description': '${_descriptionController.text}',
      'location': '${_addressController.text}',
      'coordinates': _currentCoordinates,
      'name': '${_dishNameController.text}',
      'photo': '$_pickedImage',
    };
    await FirebaseFirestore.instance.collection('meals').add(data);
    _dishNameController.clear();
    _descriptionController.clear();
    _addressController.clear();
    _currentCoordinates = GeoPoint(0, 0);
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _addressController.dispose();
    _descriptionController.dispose();
    _dishNameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share your meal'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ImagePickerButton(onImageChanged: _updateImage),
              const SizedBox(height: 16.0),
              TextField(
                controller: _dishNameController,
                decoration: const InputDecoration(
                  labelText: 'Dish Name',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address/Location',
                ),
              ),
              const SizedBox(height: 16.0),
              Text('Image: ${_pickedImage?.path ?? 'No image selected'}'),
              const SizedBox(height: 16.0),
              const SizedBox(height: 16.0),
              CoordinateButton(onCoordinatesChanged: _updateCoordinates),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement form submission logic
                  // String dishName = _dishNameController.text;
                  // String description = _descriptionController.text;
                  // String address = _addressController.text;

                  // Perform form submission actions here
                  _uploadData();
                  // Clear the form fields

                  // Show a snackbar or navigate to a new screen to indicate successful submission
                },
                child: const Text('Share'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '/widgets/image_picker_button.dart';
import '../widgets/coordinate_button.dart';
import 'package:flutter/material.dart';
import 'package:secondserving/models/meal_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class DishForm extends StatefulWidget {
  @override
  _DishFormState createState() => _DishFormState();
}

class _DishFormState extends State<DishForm> {
  TextEditingController _dishNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  String _currentCoordinates = '';
  File? _pickedImage;
  @override
  void initState() {
    super.initState();
  }

  void _updateCoordinates(Future<String> data) {
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
    final bytes = await _pickedImage!.readAsBytes();
    final base64Image = base64Encode(bytes);
    final data = {
      'description': '${_descriptionController.text}',
      'location': '${_addressController.text}',
      'name': '${_dishNameController.text}',
      'photo': '$_pickedImage',
    };
    await FirebaseFirestore.instance.collection('meals').add(data);
    _dishNameController.clear();
    _descriptionController.clear();
    _addressController.clear();
    _currentCoordinates = '';
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
              Text(_currentCoordinates,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 41, 147, 46))),
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

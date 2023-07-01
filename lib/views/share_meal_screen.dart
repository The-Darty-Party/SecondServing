import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view_models/meal_form_viewmodel.dart';
import '../widgets/image_picker_button.dart';
import '../widgets/coordinate_button.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MealForm extends StatefulWidget {
  @override
  _mealFormState createState() => _mealFormState();
}

class _mealFormState extends State<MealForm> {
  TextEditingController _mealNameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  GeoPoint? _currentCoordinates;
  File? _pickedImage;
  final MealFormViewModel _viewModel = MealFormViewModel();

  @override
  void dispose() {
    _mealNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
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
    final String mealName = _mealNameController.text;
    final String description = _descriptionController.text;
    final String location = _addressController.text;
    EasyLoading.show(status: 'Uploading...');
    if (mealName.isNotEmpty &&
        description.isNotEmpty &&
        location.isNotEmpty &&
        _currentCoordinates != null &&
        _pickedImage != null) {
      await _viewModel.uploadData(
        mealName: mealName,
        description: description,
        location: location,
        coordinates: _currentCoordinates!,
        pickedImage: _pickedImage,
      );

      _mealNameController.clear();
      _descriptionController.clear();
      _addressController.clear();
      _currentCoordinates = null;

      EasyLoading.dismiss();
      EasyLoading.showSuccess('Meal shared!');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                controller: _mealNameController,
                decoration: const InputDecoration(
                  labelText: 'meal Name',
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
                  labelText: 'Location',
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Your current coordinates: ${_currentCoordinates?.latitude ?? 0}, ${_currentCoordinates?.longitude ?? 0}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16.0),
              CoordinateButton(onCoordinatesChanged: _updateCoordinates),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _uploadData,
                child: const Text('Share'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

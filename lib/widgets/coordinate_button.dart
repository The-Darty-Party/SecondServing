import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CoordinateButton extends StatelessWidget {
  final Function(Future<String>) onCoordinatesChanged;
  CoordinateButton({required this.onCoordinatesChanged});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onCoordinatesChanged(_getCurrentLocation());
      },
      child: Text('Get Current Location'),
    );
  }

  Future<String> _getCurrentLocation() async {
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
    } catch (e) {
      print('Error: $e');
    }

    return 'Could not get location';
  }
}

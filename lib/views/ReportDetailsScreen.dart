import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDetailsScreen extends StatefulWidget {
  final String donorId;

  const ReportDetailsScreen({Key? key, required this.donorId})
      : super(key: key);

  @override
  _ReportDetailsScreenState createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  String _issue = '';
  String _description = '';
  String _reporter = '';

  @override
  void initState() {
    super.initState();
    _fetchReportDetails();
  }

  Future<void> _fetchReportDetails() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('reports')
              .where('donorID', isEqualTo: widget.donorId)
              .get();

      final List<Map<String, dynamic>> reports =
          snapshot.docs.map((doc) => doc.data()).toList();

      if (reports.isNotEmpty) {
        final report = reports[0];
        setState(() {
          _issue = report['issue'] ?? '';
          _description = report['description'] ?? '';
        });
        FirebaseFirestore.instance
            .collection('users')
            .doc(report['reporterID'])
            .get()
            .then((doc) {
          setState(() {
            _reporter = doc.data()!['name'];
          });
        });
      }
    } catch (e) {
      print('Error fetching report details: $e');
    }
  }

  // Function to block the donor
  Future<void> _blockDonor() async {
    try {
      // Create a new document in the 'blocked' collection
      await FirebaseFirestore.instance.collection('blocked').add({
        'donorId': widget.donorId,
        'blocked': true,
      });

      // Show a success message or perform any other necessary actions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User blocked successfully')),
      );

      // Nevigate back to previous screen
      Navigator.of(context).pop();
    } catch (e) {
      print('Error blocking donor: $e');
      // Show an error message or perform error handling
    }
  }

  // Function to delete the report
  Future<void> _deleteReport() async {
    try {
      // Delete the report document
      await FirebaseFirestore.instance
          .collection('reports')
          .where('donorID', isEqualTo: widget.donorId)
          .get()
          .then((snapshot) {
        snapshot.docs.forEach((doc) {
          doc.reference.delete();
        });
      });

      // Show a success message or perform any other necessary actions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report deleted successfully')),
      );

      // Nevigate back to previous screen
      Navigator.of(context).pop();

      // Refresh the reported users list
    } catch (e) {
      print('Error deleting report: $e');
      // Show an error message or perform error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text(
          'Report Details',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Issue:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_issue),
            SizedBox(height: 16.0),
            Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_description),
            SizedBox(height: 16.0),
            Text(
              'Reporter:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_reporter),
            SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _blockDonor,
                  child: Text("Block", style: TextStyle(color: Colors.red)),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _deleteReport,
                  child: Text("Delete Report"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

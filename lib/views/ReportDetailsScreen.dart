import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDetailsScreen extends StatefulWidget {
  final String donorId;

  const ReportDetailsScreen({Key? key, required this.donorId}) : super(key: key);

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
          await FirebaseFirestore.instance.collection('reports').where('donorID', isEqualTo: widget.donorId).get();

      final List<Map<String, dynamic>> reports = snapshot.docs.map((doc) => doc.data()).toList();

      if (reports.isNotEmpty) {
        final report = reports[0];
        setState(() {
          _issue = report['issue'] ?? '';
          _description = report['description'] ?? '';
          _reporter = report['reporterID'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching report details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Details'),
        backgroundColor: Colors.green,
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
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GrievanceForm extends StatefulWidget {
  @override
  _GrievanceFormState createState() => _GrievanceFormState();
}

class _GrievanceFormState extends State<GrievanceForm> {
  final _formKey = GlobalKey<FormState>();

  String selectedCategory;
  List<String> categories = [
    "Academic",
    "Hostel",
    "Faculty",
    "Infrastructure",
    "Other",
  ];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController otherCategoryController = TextEditingController();

  bool showOtherCategoryField = false;
  bool showLoading = false;

  DatabaseReference _reference =
      FirebaseDatabase.instance.reference().child('Grievances');

  final user = FirebaseAuth.instance.currentUser;

  void registerUser() async {
    if (_formKey.currentState.validate()) {
      String title = titleController.text;
      String description = descriptionController.text;
      String otherCategory = otherCategoryController.text;

      DateTime currentDate = DateTime.now();
      String formattedDate =
          "${currentDate.day}-${currentDate.month}-${currentDate.year}";

      DatabaseReference userReference = _reference.child(user.uid).push();

      Map<String, dynamic> data = {
        'title': title,
        'description': description,
        'category': selectedCategory,
        'date': formattedDate,
      };

      if (showOtherCategoryField) {
        data['other_category'] = otherCategory;
      }

      userReference.set(data);

      setState(() {
        showLoading = true;
      });

      await Future.delayed(Duration(seconds: 2));

      setState(() {
        showLoading = false;
      });

      _formKey.currentState.reset();

      titleController.clear();
      descriptionController.clear();
      otherCategoryController.clear();
      selectedCategory = null;
      showOtherCategoryField = false;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Your grievance has been submitted successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grievance Form'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter Grievance Title';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Grievance Title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: descriptionController,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter Grievance Description';
                  }
                  return null;
                },
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Grievance Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    showOtherCategoryField = value == 'Other';
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a Category';
                  }
                  return null;
                },
              ),
              if (showOtherCategoryField) ...[
                SizedBox(height: 20),
                TextFormField(
                  controller: otherCategoryController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter Other Category';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Other Category',
                    prefixIcon: Icon(Icons.apps),
                    border: OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ],
              SizedBox(height: 30),
              showLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: registerUser,
                        style: ElevatedButton.styleFrom(
                          primary: Colors.lightBlueAccent[700],
                          textStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        child: Text('SUBMIT GRIEVANCE'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

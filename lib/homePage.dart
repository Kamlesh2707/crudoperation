import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final rollNoController = TextEditingController();
  final mobileController = TextEditingController();
  final students = FirebaseFirestore.instance.collection('students');
  final formKey = GlobalKey<FormState>();
  String? selectedStream;
  String? updateId;

  List<String> streams = ['BCA', 'MCA', 'Msc.IT','Bsc.IT'];

  void saveStudent() async {
    if (formKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        'name': nameController.text,
        'email': emailController.text,
        'rollno': rollNoController.text,
        'stream': selectedStream,
        'mobile': mobileController.text,
      };
      if (updateId == null) {
        await students.add(data);
      } else {
        await students.doc(updateId).update(data);
      }
      clearForm();
    }
  }
  void clearForm() {
    nameController.clear();
    emailController.clear();
    rollNoController.clear();
    mobileController.clear();

    setState(() {
      selectedStream = null;
      updateId = null;
    });
  }
  void editStudent(DocumentSnapshot doc) {
    nameController.text = doc['name'];
    emailController.text = doc['email'];
    rollNoController.text = doc['rollno'];
    mobileController.text = doc['mobile'];

    setState(() {
      selectedStream = doc['stream'];
      updateId = doc.id;
    });
  }
  void deleteStudent(String id) async {
    await students.doc(id).delete();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade200,
      appBar: AppBar(title: Text('CRUD operation'), backgroundColor: Colors.amber.shade300),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Enter Name';
                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
                        return 'Name must contain letters only (no numbers or symbols)';
                      }
                    }
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                    ),
                    validator: (value) {
                      if(value == null || value.trim().isEmpty) return 'Enter Email';
                      if(!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{3,4}$').hasMatch(value.trim())) return 'Enter valid email';
                      return null;
                     },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: rollNoController,
                    decoration: InputDecoration(
                      labelText: 'Roll No',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter Roll No' : null,
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedStream,
                    decoration: InputDecoration(
                      labelText: 'Stream',
                      fillColor: Colors.green,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                    ),
                    items: streams.map((stream) {
                      return DropdownMenuItem(
                        value: stream,
                        child: Text(stream),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedStream = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Select Stream' : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'Mobile',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        value!.length != 10 ? 'Enter 10 digit mobile' : null,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: saveStudent,
                          child: Text(updateId == null ? 'Submit' : 'Update'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: clearForm,
                          child: Text('Clear'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Student List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            // Display Students
            StreamBuilder(
              stream: students.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Text('No Students Found');
                }
                var studentList = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: studentList.length,

                  itemBuilder: (context, index) {
                    var doc = studentList[index];

                    return Card(
                      child: ListTile(
                        title: Text(doc['name']),

                        subtitle: Text(
                          'Roll: ${doc['rollno']}\n'
                          'Email: ${doc['email']}\n'
                          'Stream: ${doc['stream']}\n'
                          'Mobile: ${doc['mobile']}',
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => editStudent(doc),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteStudent(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:client/pages/Home/upload_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Streamify'),),
        actions: [IconButton(onPressed: () {
          Navigator.push(context, UploadPage.route());
        }, icon: Icon(Icons.add))],
      ),
      body: Center(child: Text('Home Page', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),),
    );
  }
}

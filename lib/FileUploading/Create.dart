
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class MyFile extends StatefulWidget {
  const MyFile({super.key});

  @override
  State<MyFile> createState() => _MyFileState();
}

class _MyFileState extends State<MyFile> {
  String?filename;
  Uint8List? filebyte;
  TextEditingController Pname=TextEditingController();
   TextEditingController Pprice=TextEditingController();

   //file select
   Future<void> addimage()async{
      FilePickerResult?res=await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if(res!=null){
        setState(() {
          filename=res.files.first.name;
          filebyte=res.files.first.bytes;
        });
      }
   }

   // Add Product

   Future<void> addProduct() async{
      FirebaseFirestore.instance.collection("Product").add({
        'P_name':Pname.text,
        'P_Price':Pprice.text,
        'Image':filename,
        'filebyte':filebyte?.toList()
      }
      );
       Navigator.pushNamed(context, '/myread');
   }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(controller: Pname,),
          SizedBox(height: 10,),
          TextField(controller: Pprice,),
          SizedBox(height: 10,),
          ElevatedButton(
            onPressed: () async {
              await addimage();
            }, 
            child: Text("Image Uplaod")
            ),
          
           SizedBox(height: 10,),
          ElevatedButton(
            onPressed: () async {
            await   addProduct();
             
            }, 
            child: Text("Save Data")
                        )
        ],
      ),
    );
  }
}
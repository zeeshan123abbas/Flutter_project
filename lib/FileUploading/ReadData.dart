import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReadData extends StatefulWidget {
  const ReadData({super.key});

  @override
  State<ReadData> createState() => _ReadDataState();
}

class _ReadDataState extends State<ReadData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
       stream:  FirebaseFirestore.instance.collection("Product").snapshots(),
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(),);
          } 
          if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                return const Center(child: Text("Data Not Found"),);
          }

          final data=snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index){
              // Convert documnet to Map
              final mydata=data[index].data() as Map<String, dynamic>;

              // check file byte exist
              final fileByte=mydata.containsKey('filebyte') && mydata['filebyte'] !=null 
              ? Uint8List.fromList(List<int>.from(mydata['filebyte'])): null;    
                // check FileName exist
                final myimage=mydata.containsKey('Image') ? mydata['Image']:null;

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Text("P_Name: ${mydata['P_name']??'N/A'} "),
                        SizedBox(height: 10,),
                        Text("P_Price: ${mydata['P_Price']??'N/A'} "),
                         SizedBox(height: 10,),
                         myimage !=null 
                         ? Text("Image $myimage") : const Text("No file uploaded"),
                         fileByte !=null
                         ? Image.memory(
                          fileByte,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                         ): const SizedBox(),
                      ],
                    ),
                    ),

                );

              }
            );
        } 
      ,),
    );
  }
}
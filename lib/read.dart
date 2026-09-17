import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebse_auth/myregister.dart';
import 'package:flutter/material.dart';

class MyRead extends StatefulWidget {
  const MyRead({super.key});

  @override
  State<MyRead> createState() => _MyReadState();
}

class _MyReadState extends State<MyRead> {
  //============== Firebase Collection ====================
  final CollectionReference students= FirebaseFirestore.instance.collection("students");

 //========================= Controllers For Edit =====================

   TextEditingController name=TextEditingController();
   TextEditingController age=TextEditingController();
   TextEditingController email=TextEditingController();
   TextEditingController password=TextEditingController();

   //=============== Delete Student ====================
    Future<void> deletestudent(String id)async{
        await students.doc(id).delete();
    }

    //=============== Update Student ====================
    Future<void> updatestudent(String id) async{
        await students.doc(id).update({
          'name':name.text.trim(),
          'age':int.parse(age.text.trim()),
          'email':email.text.trim(),
          'password':password.text.trim(),
        });
    }

    //=============== Delete Confirmation Popup =========================
    void showDeleteDialog(String id){
      showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text("Student Data Delete "),
          content: const Text("Are you sure you want to delete this student"),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: (){
                Navigator.pop(context);
            }, 
            child: const Text("Cancel")
            ),
            
            // Delete Button
              TextButton(
                onPressed: () async{
                await deletestudent(id);
                Navigator.pop(context);
              },
               child: const Text("delete",style: TextStyle(color: Colors.red),)
               ),
          ],
        );
      }
      );
    }

//=============== Update and Edit Popup =========================
 void showEditDialog(DocumentSnapshot doc){
    name.text=doc["name"];
    age.text=doc["age"].toString();
    email.text=doc["email"];
    password.text=doc["password"];
     showDialog(
      context: context, 
     builder: (context){
      return  AlertDialog(
            title: const Text("Edit Data"),
            content: SingleChildScrollView(
                child: Column(
                  children: [
                    //User Name
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    SizedBox(height: 5,),

                     //User Age
                    TextField(
                      controller: age,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Age"),
                    ),
                    SizedBox(height: 5,),
                     //User email
                    TextField(
                      controller: email,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    SizedBox(height: 5,),
                     //User Password
                    TextField(
                      controller: password,
                      decoration: const InputDecoration(labelText: "Password"),
                    ),
                    SizedBox(height: 5,),
                  ],
                ),
            ),

            actions: [
              // Cancel Button
              ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
                }, 
                child: Text("Cancel")
                ),

                //Update Button

                ElevatedButton(
                  onPressed: ()async{
                    await updatestudent(doc.id);
                    Navigator.pop(context);
                  }, 
                  child: Text("Update"))
            ],

      );
     }
     );
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: (){
          Navigator.push(context, 
          MaterialPageRoute(builder: (context)=>Register())
          );
        }
        ),
      body: StreamBuilder(
        stream: students.snapshots(), 
        builder: (context, snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
              return  const Center(child: CircularProgressIndicator());
          }
          if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
            return const Center(child: Text(
              "Data Not Found"
            ),) ; 
          }

         return ListView.builder(
          padding: const EdgeInsets.all(10) ,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context,index){
            var doc=snapshot.data!.docs[index];
            return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      children: [
                        //Student name
                        Text(
                          doc["name"],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const Divider(height: 18,),
                        Text("Age: ${doc["age"]}"),
                        Text("Email: ${doc["email"]}"),
                        Text("Password: ${doc["password"]}"),

                      // Edit and Delete Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: ()async{
                              showEditDialog(doc); // Open Edit POP_UP
                            }, 
                            icon: const Icon(Icons.edit,color: Colors.blue,)
                            ),

                             IconButton(
                            onPressed: (){
                              showDeleteDialog(doc.id); // Open Delete POP_UP
                            }, 
                            icon: const Icon(Icons.delete,color: Colors.red,)
                            )
                        ],
                      )
                      ],
                  ),
                ),
            );
          },
         );
        }
        
        ),
    );
  }
}



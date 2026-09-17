import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  //================ Firestore Collections =================

  final CollectionReference students =
      FirebaseFirestore.instance.collection("students");

  final CollectionReference products =
      FirebaseFirestore.instance.collection("products");

  //================ Dashboard Menu =================

  int selectedIndex = 0;

  //================ Logout =================

  void logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/mylogin',
      (route) => false,
    );
  }

  //==========================================================
  // Add Product Dialog
  //==========================================================

  void showAddProductDialog() {
    final TextEditingController nameController =
        TextEditingController();

    final TextEditingController priceController =
        TextEditingController();

    final TextEditingController descriptionController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Add Product"),

          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Product Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                String name = nameController.text.trim();
                String priceText = priceController.text.trim();
                String description =
                    descriptionController.text.trim();

                double? price = double.tryParse(priceText);

                if (name.isEmpty || price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please enter a valid product name and price",
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await products.add({
                    'name': name,
                    'price': price,
                    'description': description,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Product Added Successfully"),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Error adding product: $e"),
                      ),
                    );
                  }
                }
              },
              child: const Text("Add Product"),
            ),
          ],
        );
      },
    );
  }

  //==========================================================
  // Edit Product
  //==========================================================

  void editProduct(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final TextEditingController nameController =
        TextEditingController(
      text: data['name'] ?? '',
    );

    final TextEditingController priceController =
        TextEditingController(
      text: data['price']?.toString() ?? '',
    );

    final TextEditingController descriptionController =
        TextEditingController(
      text: data['description'] ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit Product"),

          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Product Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Price",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                String name = nameController.text.trim();
                String priceText = priceController.text.trim();
                String description =
                    descriptionController.text.trim();

                double? price = double.tryParse(priceText);

                if (name.isEmpty || price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please enter a valid product name and price",
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await products.doc(documentId).update({
                    'name': name,
                    'price': price,
                    'description': description,
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Product Updated"),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Error updating product: $e"),
                      ),
                    );
                  }
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  //==========================================================
  // Delete Product
  //==========================================================

  Future<void> deleteProduct(String documentId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Product"),
          content: const Text(
            "Are you sure you want to delete this product?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await products.doc(documentId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Product Deleted"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting product: $e"),
          ),
        );
      }
    }
  }

  //==========================================================
  // Approve User
  //==========================================================

  Future<void> approveUser(String documentId) async {
    try {
      await students.doc(documentId).update({
        'status': 'approved',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User Approved"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error approving user: $e"),
          ),
        );
      }
    }
  }

  //==========================================================
  // Reject User
  //==========================================================

  Future<void> rejectUser(String documentId) async {
    try {
      await students.doc(documentId).update({
        'status': 'rejected',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User Rejected"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error rejecting user: $e"),
          ),
        );
      }
    }
  }

  //==========================================================
  // Delete User
  //==========================================================

  Future<void> deleteUser(String documentId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete User"),
          content: const Text(
            "Are you sure you want to delete this user?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await students.doc(documentId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User Deleted"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting user: $e"),
          ),
        );
      }
    }
  }

  //==========================================================
  // Edit User
  //==========================================================

  void editUser(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final TextEditingController nameController =
        TextEditingController(
      text: data['name'] ?? '',
    );

    final TextEditingController ageController =
        TextEditingController(
      text: data['age']?.toString() ?? '',
    );

    final TextEditingController emailController =
        TextEditingController(
      text: data['email'] ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit User"),

          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Age",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                String name = nameController.text.trim();
                String ageText = ageController.text.trim();
                String email = emailController.text.trim();

                int? age = int.tryParse(ageText);

                if (name.isEmpty ||
                    email.isEmpty ||
                    age == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please enter valid user information",
                      ),
                    ),
                  );
                  return;
                }

                try {
                  await students.doc(documentId).update({
                    'name': name,
                    'age': age,
                    'email': email,
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("User Updated"),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Error updating user: $e"),
                      ),
                    );
                  }
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  //==========================================================
  // Dashboard Home
  //==========================================================

  Widget dashboardHome() {
    return StreamBuilder<QuerySnapshot>(
      stream: students.snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
            ),
          );
        }

        int totalUsers =
            snapshot.data?.docs.length ?? 0;

        int approvedUsers = 0;
        int pendingUsers = 0;
        int rejectedUsers = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            var data =
                doc.data() as Map<String, dynamic>;

            String status =
                data['status'] ?? 'pending';

            if (status == 'approved') {
              approvedUsers++;
            } else if (status == 'rejected') {
              rejectedUsers++;
            } else {
              pendingUsers++;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  dashboardCard(
                    "Total Users",
                    totalUsers.toString(),
                    Icons.people,
                  ),

                  const SizedBox(width: 15),

                  dashboardCard(
                    "Approved",
                    approvedUsers.toString(),
                    Icons.check_circle,
                  ),

                  const SizedBox(width: 15),

                  dashboardCard(
                    "Pending",
                    pendingUsers.toString(),
                    Icons.pending,
                  ),

                  const SizedBox(width: 15),

                  dashboardCard(
                    "Rejected",
                    rejectedUsers.toString(),
                    Icons.cancel,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  //==========================================================
  // Dashboard Card
  //==========================================================

  Widget dashboardCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
              ),

              const SizedBox(height: 10),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  //==========================================================
  // Products
  //==========================================================

  Widget productsPage() {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                "Products",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              ElevatedButton.icon(
                onPressed: showAddProductDialog,
                icon: const Icon(Icons.add),
                label: const Text("Add Product"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: products.snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Products Found",
                    ),
                  );
                }

                return ListView.builder(
                  itemCount:
                      snapshot.data!.docs.length,

                  itemBuilder: (context, index) {
                    var doc =
                        snapshot.data!.docs[index];

                    var data =
                        doc.data()
                            as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(
                            Icons.shopping_bag,
                          ),
                        ),

                        title: Text(
                          data['name'] ?? '',
                        ),

                        subtitle: Text(
                          "Price: ${data['price'] ?? 0}\n"
                          "${data['description'] ?? ''}",
                        ),

                        isThreeLine: true,

                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [
                            IconButton(
                              onPressed: () {
                                editProduct(
                                  doc.id,
                                  data,
                                );
                              },
                              icon: const Icon(
                                Icons.edit,
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                deleteProduct(
                                  doc.id,
                                );
                              },
                              icon: const Icon(
                                Icons.delete,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //==========================================================
  // Users
  //==========================================================

  Widget usersPage() {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            "Manage Users",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: students.snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Users Found",
                    ),
                  );
                }

                return ListView.builder(
                  itemCount:
                      snapshot.data!.docs.length,

                  itemBuilder: (context, index) {
                    var doc =
                        snapshot.data!.docs[index];

                    var data =
                        doc.data()
                            as Map<String, dynamic>;

                    String role =
                        data['role'] ?? 'user';

                    String status =
                        data['status'] ?? 'pending';

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            role == 'admin'
                                ? Icons
                                    .admin_panel_settings
                                : Icons.person,
                          ),
                        ),

                        title: Text(
                          data['name'] ?? '',
                        ),

                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Email: ${data['email'] ?? ''}",
                            ),

                            Text(
                              "Age: ${data['age'] ?? ''}",
                            ),

                            Text(
                              "Role: $role",
                            ),

                            Text(
                              "Status: $status",
                            ),
                          ],
                        ),

                        isThreeLine: true,

                        trailing: Wrap(
                          children: [
                            // Approve
                            if (role != 'admin' &&
                                status != 'approved')
                              IconButton(
                                onPressed: () {
                                  approveUser(
                                    doc.id,
                                  );
                                },
                                icon: const Icon(
                                  Icons.check,
                                ),
                              ),

                            // Reject
                            if (role != 'admin' &&
                                status != 'rejected')
                              IconButton(
                                onPressed: () {
                                  rejectUser(
                                    doc.id,
                                  );
                                },
                                icon: const Icon(
                                  Icons.close,
                                ),
                              ),

                            // Edit
                            IconButton(
                              onPressed: () {
                                editUser(
                                  doc.id,
                                  data,
                                );
                              },
                              icon: const Icon(
                                Icons.edit,
                              ),
                            ),

                            // Delete
                            IconButton(
                              onPressed: () {
                                deleteUser(
                                  doc.id,
                                );
                              },
                              icon: const Icon(
                                Icons.delete,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //==========================================================
  // Main Build
  //==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
        ),

        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: Row(
        children: [
          //================ Sidebar =================

          NavigationRail(
            selectedIndex: selectedIndex,

            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },

            labelType:
                NavigationRailLabelType.all,

            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text("Dashboard"),
              ),

              NavigationRailDestination(
                icon: Icon(Icons.shopping_bag),
                label: Text("Products"),
              ),

              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text("Users"),
              ),
            ],
          ),

          const VerticalDivider(
            width: 1,
          ),

          //================ Main Content =================

          Expanded(
            child: IndexedStack(
              index: selectedIndex,

              children: [
                dashboardHome(),
                productsPage(),
                usersPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
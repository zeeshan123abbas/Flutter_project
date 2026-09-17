import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  // Bottom Navigation Index
  int selectedIndex = 0;

  //================ Firestore Collection =================
  // Same "products" collection jisme Admin Dashboard se
  // products add/edit/delete hote hain.

  final CollectionReference products =
      FirebaseFirestore.instance.collection("products");

  //================ Logged-in User Info =================
  // Email FirebaseAuth se seedha milta hai.
  // Name Firestore "students" collection se (email match kar ke) fetch hota hai.

  String userName = "Loading...";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    userEmail = FirebaseAuth.instance.currentUser?.email ?? "";
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (mounted) {
        setState(() {
          userName = "User";
        });
      }
      return;
    }

    try {
      // 1) Pehle UID se document try karo
      // (agar signup ke waqt .doc(uid) se save hua ho)
      final docByUid = await FirebaseFirestore.instance
          .collection("students")
          .doc(currentUser.uid)
          .get();

      if (docByUid.exists) {
        final data = docByUid.data() as Map<String, dynamic>;

        if (mounted) {
          setState(() {
            userName = data['name'] ?? currentUser.displayName ?? "User";
            if ((data['email'] ?? '').toString().isNotEmpty) {
              userEmail = data['email'];
            }
          });
        }
        return;
      }

      // 2) Agar UID se na mile, to email field se query karo
      final query = await FirebaseFirestore.instance
          .collection("students")
          .where('email', isEqualTo: currentUser.email)
          .limit(1)
          .get();

      if (!mounted) return;

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();

        setState(() {
          userName = data['name'] ?? currentUser.displayName ?? "User";
        });
      } else {
        // Debug ke liye print — console mein dikhega
        // ke Firestore mein is user ka koi doc mila hi nahi
        debugPrint(
          "No student doc found for uid=${currentUser.uid} "
          "or email=${currentUser.email}",
        );

        setState(() {
          userName = currentUser.displayName ?? "User";
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");

      if (mounted) {
        setState(() {
          userName = currentUser.displayName ?? "User";
        });
      }
    }
  }

  //================ Cart (local, in-memory) =================
  // Abhi ke liye simple local cart hai.
  // Agar Firestore mein per-user cart save karna ho
  // (taake app band karne ke baad bhi cart yaad rahe),
  // to bata dena — us collection ke saath wire kar dunga.

  final List<Map<String, dynamic>> cartItems = [];

  void addToCart(String productId, String name, String price) {
    setState(() {
      cartItems.add({
        'id': productId,
        'name': name,
        'price': price,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$name added to cart"),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  //==================================================
  // SIGN OUT
  //==================================================

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  //==================================================
  // BOTTOM NAVIGATION
  //==================================================

  void onItemTapped(int index) {
    if (index < 0 || index > 3) {
      return;
    }

    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    // Safety check
    int safeIndex = selectedIndex;

    if (safeIndex < 0 || safeIndex >= 4) {
      safeIndex = 0;
    }

    return Scaffold(

      backgroundColor: const Color(0xffF5F6FA),

      //==================================================
      // APP BAR
      //==================================================

      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,

        title: const Text(
          "My Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,

        actions: [

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 5),
        ],
      ),

      //==================================================
      // DRAWER
      //==================================================

      drawer: Drawer(

        child: Column(
          children: [

            // Drawer Header
            UserAccountsDrawerHeader(

              decoration: const BoxDecoration(
                color: Colors.indigo,
              ),

              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,

                child: Icon(
                  Icons.person,
                  size: 35,
                  color: Colors.indigo,
                ),
              ),

              accountName: Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              accountEmail: Text(
                userEmail,
              ),
            ),

            // Home
            ListTile(
              leading: const Icon(
                Icons.home_outlined,
                color: Colors.indigo,
              ),

              title: const Text("Home"),

              onTap: () {
                Navigator.pop(context);

                setState(() {
                  selectedIndex = 0;
                });
              },
            ),

            // Profile
            ListTile(
              leading: const Icon(
                Icons.person_outline,
                color: Colors.indigo,
              ),

              title: const Text("Profile"),

              onTap: () {
                Navigator.pop(context);

                setState(() {
                  selectedIndex = 3;
                });
              },
            ),

            // Orders
            ListTile(
              leading: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.indigo,
              ),

              title: const Text("Orders"),

              onTap: () {
                Navigator.pop(context);

                setState(() {
                  selectedIndex = 1;
                });
              },
            ),

            // Settings
            ListTile(
              leading: const Icon(
                Icons.settings_outlined,
                color: Colors.indigo,
              ),

              title: const Text("Settings"),

              onTap: () {
                Navigator.pop(context);
              },
            ),

            const Divider(),

            // Sign Out
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),

              title: const Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),

              onTap: () async {
                await signOut();
              },
            ),
          ],
        ),
      ),

      //==================================================
      // BODY
      //==================================================

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // Heading
            const Text(
              "Welcome Back!",
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Here is your dashboard overview",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            //==================================================
            // MAIN CARD
            //==================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    "Dashboard",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "Everything is under control",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Manage your account and activities from here.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            //==================================================
            // AVAILABLE PRODUCTS (Live from Firestore)
            // Admin jo bhi product Dashboard se add/edit/delete
            // karega, wo yahan real-time update ho jayega.
            //==================================================

            const Text(
              "Available Products",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream: products
                  .orderBy('createdAt', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Error loading products: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No products available right now.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),

                  itemBuilder: (context, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;

                    final String name = data['name'] ?? '';
                    final dynamic priceRaw = data['price'];
                    final String price = priceRaw == null
                        ? '0'
                        : priceRaw.toString();
                    final String description =
                        data['description'] ?? '';

                    return productCard(
                      productId: docs[index].id,
                      name: name,
                      price: price,
                      description: description,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            //==================================================
            // RECENT ACTIVITY
            //==================================================

            const Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            activityCard(
              icon: Icons.shopping_bag_outlined,
              title: "New Order",
              subtitle: "Your order has been placed successfully",
            ),

            const SizedBox(height: 12),

            activityCard(
              icon: Icons.check_circle_outline,
              title: "Payment Completed",
              subtitle: "Your payment was successfully received",
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      //==================================================
      // BOTTOM NAVIGATION BAR
      //==================================================

      bottomNavigationBar: BottomNavigationBar(

        // IMPORTANT:
        // safeIndex is always between 0 and 3
        currentIndex: safeIndex,

        onTap: onItemTapped,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.indigo,

        unselectedItemColor: Colors.grey,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: "Orders",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: "Favorites",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  //==================================================
  // PRODUCT CARD (from Firestore)
  //==================================================

  Widget productCard({
    required String productId,
    required String name,
    required String price,
    required String description,
  }) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Container(
                height: 48,
                width: 48,

                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.indigo,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 4),

                    if (description.isNotEmpty)
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Text(
                "Rs. $price",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          //================ Add to Cart Button =================

          Align(
            alignment: Alignment.centerRight,

            child: ElevatedButton.icon(
              onPressed: () {
                addToCart(productId, name, price);
              },

              icon: const Icon(
                Icons.add_shopping_cart,
                size: 18,
              ),

              label: const Text("Add to Cart"),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // ACTIVITY CARD
  //==================================================

  Widget activityCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [

          Container(
            height: 48,
            width: 48,

            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: Colors.indigo,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
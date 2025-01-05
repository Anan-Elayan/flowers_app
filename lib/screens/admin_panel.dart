import 'dart:convert';
import 'dart:io';

import 'package:flowers_app/constants/constants.dart';
import 'package:flowers_app/screens/add_new_item.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  late Future<List<dynamic>> myItemsFuture;

  @override
  void initState() {
    super.initState();
    myItemsFuture = _loadMyItems();
  }

  Future<List<dynamic>> _loadMyItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedItems = prefs.getString('flower_items');
    String? loggedInUser = prefs.getString('logged_in_user');
    String? adminIdentifier = loggedInUser != null
        ? jsonDecode(loggedInUser)['username'] // Or use 'email' if preferred
        : null;

    if (savedItems != null && adminIdentifier != null) {
      List<dynamic> allItems = jsonDecode(savedItems);
      return allItems
          .where((item) => item['admin'] == adminIdentifier)
          .toList();
    }
    return [];
  }

  Future<String?> _loadLoginCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_username');
  }

  Future<List<Map<String, dynamic>>> _loadOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? ordersJson = prefs.getString('flutter.orders');
    if (ordersJson != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(ordersJson));
    }
    return [];
  }

  void refreshItems() {
    setState(() {
      myItemsFuture = _loadMyItems();
    });
  }

  void _deleteItem(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedItems = prefs.getString('flower_items');
    if (savedItems != null) {
      List<dynamic> allItems = jsonDecode(savedItems);

      // Remove the item with the matching id
      allItems.removeWhere((item) => item['id'] == id);

      // Save the updated list back to SharedPreferences
      await prefs.setString('flower_items', jsonEncode(allItems));
      refreshItems(); // Refresh the UI for the logged-in admin
    }
  }

  void _updateItem(String id, Map<String, dynamic> updatedItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedItems = prefs.getString('flower_items');
    if (savedItems != null) {
      List<dynamic> allItems = jsonDecode(savedItems);

      // Find the index of the item with the given id
      int itemIndex = allItems.indexWhere((item) => item['id'] == id);

      if (itemIndex != -1) {
        allItems[itemIndex] = updatedItem;
        await prefs.setString('flower_items', jsonEncode(allItems));
        refreshItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async {
                final confirmLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // Rounded corners
                      ),
                      title: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                            size: 28, // Logout icon
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Confirm Logout",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      content: const Text(
                        "Are you sure you want to log out?",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      actionsPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false); // Do not log out
                          },
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true); // Confirm logout
                          },
                          child: const Text("Logout"),
                        ),
                      ],
                    );
                  },
                );

                if (confirmLogout == true) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                }
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: thirdColor,
          title: FutureBuilder<String?>(
            future: _loadLoginCredentials(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Welcome ...");
              } else if (snapshot.hasError) {
                return const Text("Welcome Admin");
              } else if (snapshot.hasData && snapshot.data != null) {
                return Text("Welcome ${snapshot.data}");
              } else {
                return const Text("Welcome Admin");
              }
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "My Items"),
              Tab(text: "All Orders"),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewItem(
                  onItemAdded: refreshItems,
                ),
              ),
            );
          },
          backgroundColor: thirdColor,
          child: const Icon(
            Icons.add,
            size: 40,
          ),
        ),
        body: TabBarView(
          children: [
            // My Items Tab
            FutureBuilder<List<dynamic>>(
              future: myItemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData) {
                  List<dynamic> items = snapshot.data!;

                  if (items.isEmpty) {
                    return const Center(child: Text("No items found."));
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          bool? shouldDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20), // Rounded corners
                                ),
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.redAccent,
                                      size: 28, // Warning icon
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "Confirm Deletion",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                content: const Text(
                                  "Are you sure you want to delete this item? This action cannot be undone.",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                                actionsPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black87,
                                      backgroundColor: Colors.grey[300],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop(
                                          false); // Close the dialog without deleting
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(true); // Confirm deletion
                                      Fluttertoast.showToast(
                                        msg: "Deleted successfully.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                      );
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (shouldDelete == true) {
                            _deleteItem(item['id']); // Proceed with deletion
                            return true; // Allow dismiss
                          }

                          return false; // Prevent dismiss
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final TextEditingController nameController =
                                    TextEditingController(text: item['name']);
                                final TextEditingController quantityController =
                                    TextEditingController(
                                  text: item['quantity'].toString(),
                                );
                                final TextEditingController
                                    availableQuantityController =
                                    TextEditingController(
                                  text: item['available_quantity'].toString(),
                                );
                                final TextEditingController priceController =
                                    TextEditingController(
                                  text: item['price'].toString(),
                                );
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20), // Rounded corners
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "Update Item",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          controller: nameController,
                                          decoration: InputDecoration(
                                            labelText: "Name",
                                            hintText: "Enter item name",
                                            prefixIcon: const Icon(Icons.label),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: priceController,
                                          decoration: InputDecoration(
                                            labelText: "Price",
                                            hintText: "Enter item price",
                                            prefixIcon:
                                                const Icon(Icons.attach_money),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: quantityController,
                                          decoration: InputDecoration(
                                            labelText: "Initial Quantity",
                                            hintText: "Enter initial quantity",
                                            prefixIcon:
                                                const Icon(Icons.inventory),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller:
                                              availableQuantityController,
                                          decoration: InputDecoration(
                                            labelText: "Available Quantity",
                                            hintText:
                                                "Enter available quantity",
                                            prefixIcon:
                                                const Icon(Icons.inventory_2),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.grey[400],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: thirdColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _updateItem(item['id'], {
                                          'id': item['id'],
                                          'name': nameController.text,
                                          'quantity': quantityController.text,
                                          'price': double.tryParse(
                                                priceController.text,
                                              ) ??
                                              0.0,
                                          'photo': item['photo'],
                                          'admin': item['admin'],
                                        });
                                      },
                                      child: const Text("Update"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: secondaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  item['photo'] != null && item['photo'] != ""
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.file(
                                            File(item['photo']),
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.local_florist,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item['name'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              "${item['quantity']} ",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Price: \$${item['price']}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: fourthColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("No items found."));
                }
              },
            ),

            // All Orders Tab
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  List<Map<String, dynamic>> orders = snapshot.data!;

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final List<dynamic> items = order['items'];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15), // Rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header section
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "User: ${order['username']}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      // Remove the order from the list
                                      setState(() {
                                        orders.removeAt(
                                            index); // Directly remove the order
                                      });

                                      // Save the updated orders to SharedPreferences
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'flutter.orders', jsonEncode(orders));

                                      // Show a toast message indicating the order was marked as served
                                      Fluttertoast.showToast(
                                        msg: "Order served successfully.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size:
                                          28, // Larger icon for better visibility
                                    ),
                                    tooltip: "Mark as served",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Total price section
                              Text(
                                "Total Price: \$${order['totalPrice'].toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Colors.grey[800], // Subtle accent color
                                ),
                              ),
                              const Divider(
                                height: 20,
                                thickness: 1,
                                color: Colors.grey,
                              ),

                              // Items list section
                              const Text(
                                "Items:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...items.map((item) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${item['name']} x ${item['quantity']}",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      Text(
                                        "\$${(double.parse(item['price'].toString()) * item['quantity']).toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[
                                              600], // Subtle accent color for totals
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("No orders found."));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

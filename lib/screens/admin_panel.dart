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
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            )
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
                                title: const Text("Confirm Deletion"),
                                content: const Text(
                                    "Are you sure you want to delete this item?"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(
                                          false); // Close the dialog and do not delete
                                    },
                                    child: const Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      Fluttertoast.showToast(
                                        msg: "Deleted successfully.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                      );
                                    },
                                    child: const Text("Yes"),
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
                                  title: const Text("Update Item"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: nameController,
                                        decoration: const InputDecoration(
                                          labelText: "Name",
                                        ),
                                      ),
                                      TextField(
                                        controller: priceController,
                                        decoration: const InputDecoration(
                                          labelText: "Price",
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                      TextField(
                                        controller: quantityController,
                                        decoration: const InputDecoration(
                                          labelText: "Quantity",
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                      TextField(
                                        controller: availableQuantityController,
                                        decoration: const InputDecoration(
                                          labelText: "Available Quantity",
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _updateItem(item['id'], {
                                          'id': item['id'],
                                          'name': nameController.text,
                                          'quantity': quantityController.text,
                                          'price': double.tryParse(
                                                  priceController.text) ??
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
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "User: ${order['username']}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Total Price: \$${order['totalPrice'].toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "${item['name']} x ${item['quantity']}",
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                            Text(
                                              "\$${(double.parse(item['price'].toString()) * item['quantity']).toStringAsFixed(2)}",
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                              // Add the green tick icon
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
                                ),
                                tooltip: "Mark as served",
                              ),
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

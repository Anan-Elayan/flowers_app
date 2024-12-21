import 'dart:convert';
import 'dart:io';

import 'package:flowers_app/components/custom_button.dart';
import 'package:flowers_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../components/custom_text_fields.dart';

class AddNewItem extends StatefulWidget {
  final VoidCallback onItemAdded;
  const AddNewItem({Key? key, required this.onItemAdded}) : super(key: key);

  @override
  State<AddNewItem> createState() => _AddNewItemState();
}

class _AddNewItemState extends State<AddNewItem> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  File? _imageFile;

  Future<void> saveItem(
      String name, String price, String? photoPath, String quantity) async {
    // Validate that quantity and price are valid numbers
    final parsedQuantity = int.tryParse(quantity);
    final parsedPrice = double.tryParse(price);

    if (parsedQuantity == null || parsedPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid numeric values.")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? existingData = prefs.getString('flower_items');
    List<dynamic> flowerList =
        existingData != null ? jsonDecode(existingData) : [];

    // Generate a unique id for the item
    String itemId = const Uuid().v4();

    // Get the logged-in admin's username or email
    String? loggedInUser = prefs.getString('logged_in_user');
    String? adminIdentifier = loggedInUser != null
        ? jsonDecode(loggedInUser)['username'] // Or use 'email' if preferred
        : "Unknown Admin";

    Map<String, dynamic> newItem = {
      "id": itemId, // Unique ID
      "name": name,
      "price": parsedPrice.toStringAsFixed(2), // Ensure consistent price format
      "photo": photoPath ?? "",
      "quantity": parsedQuantity, // Store as an integer
      "admin": adminIdentifier,
      "available_quantity":
          parsedQuantity, // Available quantity matches initial
    };

    flowerList.add(newItem);

    await prefs.setString('flower_items', jsonEncode(flowerList));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item added successfully!")),
    );
    widget.onItemAdded();
    Navigator.pop(context);
  }

  // Function to pick an image from the gallery
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: thirdColor,
        title: const Text("Add New Item"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFields(
                txtLabel: "Flower Name",
                txtPrefixIcon: Icons.local_florist,
                controller: _nameController,
                isVisibleContent: false,
                validate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the flower name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              CustomTextFields(
                txtLabel: "Price",
                txtPrefixIcon: Icons.attach_money,
                controller: _priceController,
                isVisibleContent: false,
                keyBordType: TextInputType.number,
                validate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              CustomTextFields(
                txtLabel: "Quantity",
                txtPrefixIcon: Icons.production_quantity_limits_outlined,
                controller: _quantityController,
                isVisibleContent: false,
                keyBordType: TextInputType.number,
                validate: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _imageFile == null
                  ? CustomButton(
                      buttonText: "Add Photo",
                      bgButtonColor: thirdColor,
                      onPress: pickImage,
                      iconButton: Icons.add_photo_alternate,
                      colorIconButton: Colors.white,
                    )
                  : Column(
                      children: [
                        Image.file(
                          _imageFile!,
                          height: 130,
                          width: 130,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomButton(
                          buttonText:
                              _imageFile == null ? "Add Photo" : "Change Photo",
                          bgButtonColor: thirdColor,
                          onPress: pickImage,
                          iconButton: Icons.add_photo_alternate,
                          colorIconButton: Colors.white,
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
              CustomButton(
                buttonText: 'Save Item',
                bgButtonColor: thirdColor,
                onPress: () {
                  String name = _nameController.text.trim();
                  String price = _priceController.text.trim();
                  String quantity = _quantityController.text.trim();

                  if (name.isEmpty || price.isEmpty || quantity.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Please fill in all fields.")),
                    );
                    return;
                  }

                  saveItem(name, price, _imageFile?.path, quantity);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

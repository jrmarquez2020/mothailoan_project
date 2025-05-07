import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ManageMotorsScreen extends StatefulWidget {
  const ManageMotorsScreen({super.key});

  @override
  State<ManageMotorsScreen> createState() => _ManageMotorsScreenState();
}

class _ManageMotorsScreenState extends State<ManageMotorsScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<String> _uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'djcgw8jo8';
    const uploadPreset = 'asdcdwdr';

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final data = json.decode(res.body);
      return data['secure_url'];
    } else {
      throw Exception('Image upload failed');
    }
  }

  Future<void> _addMotor(BuildContext context) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController detailsController = TextEditingController();
    String motorType = 'Drag Bikes';

    _selectedImage = null;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  backgroundColor: Colors.black,
                  title: const Text(
                    'Add New Motor',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInput(nameController, 'Motor Name'),
                        const SizedBox(height: 20),
                        _buildInput(
                          priceController,
                          'Price',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: detailsController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 6, // Increased maxLines to make it taller
                          decoration: const InputDecoration(
                            labelText: 'Details',
                            labelStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width:
                              double
                                  .infinity, // Match the width of other fields
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: DropdownButton<String>(
                            value: motorType,
                            dropdownColor: Colors.black,
                            style: const TextStyle(color: Colors.white),
                            isExpanded:
                                true, // Ensure the dropdown stretches to fill the container width
                            onChanged: (String? newValue) {
                              setState(() {
                                motorType = newValue!;
                              });
                            },
                            items:
                                ['Drag Bikes', 'Motor Shows'].map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () async {
                            await _pickImage();
                            setState(() {});
                          },
                          child: Text(
                            _selectedImage == null
                                ? 'Upload Image'
                                : 'Change Image',
                            style: const TextStyle(color: Colors.greenAccent),
                          ),
                        ),
                        if (_selectedImage != null)
                          Image.file(
                            _selectedImage!,
                            height:
                                150, // Increased height for better visibility
                            fit: BoxFit.cover,
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty &&
                            priceController.text.isNotEmpty &&
                            detailsController.text.isNotEmpty &&
                            _selectedImage != null) {
                          // Upload to Cloudinary
                          String imageUrl = await _uploadImageToCloudinary(
                            _selectedImage!,
                          );

                          // Save to Firestore
                          await FirebaseFirestore.instance
                              .collection('motors')
                              .add({
                                'name': nameController.text,
                                'price': priceController.text,
                                'details': detailsController.text,
                                'type': motorType,
                                'imageUrl': imageUrl,
                              });

                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Add',
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  // Add a confirmation dialog before deleting a motor
  Future<void> _confirmDeleteMotor(BuildContext context, String motorId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this motor?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _deleteMotor(motorId);
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editMotor(BuildContext context, DocumentSnapshot motor) async {
    TextEditingController nameController = TextEditingController(
      text: motor['name'],
    );
    TextEditingController priceController = TextEditingController(
      text: motor['price'],
    );
    TextEditingController detailsController = TextEditingController(
      text: motor['details'],
    );
    String motorType = motor['type'];
    File? updatedImageFile;
    String existingImageUrl = motor['imageUrl'];

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  backgroundColor: Colors.black,
                  title: const Text(
                    'Edit Motor',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildInput(nameController, 'Motor Name'),
                        const SizedBox(height: 10),
                        _buildInput(
                          priceController,
                          'Price',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: detailsController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Details',
                            labelStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: DropdownButton<String>(
                            value: motorType,
                            dropdownColor: Colors.black,
                            style: const TextStyle(color: Colors.white),
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                motorType = newValue!;
                              });
                            },
                            items:
                                ['Drag Bikes', 'Motor Shows'].map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () async {
                            final XFile? picked = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (picked != null) {
                              setState(() {
                                updatedImageFile = File(picked.path);
                              });
                            }
                          },
                          child: Text(
                            updatedImageFile == null
                                ? 'Change Image'
                                : 'Image Selected',
                            style: const TextStyle(color: Colors.greenAccent),
                          ),
                        ),
                        if (updatedImageFile != null)
                          Image.file(
                            updatedImageFile!,
                            height: 150,
                            fit: BoxFit.cover,
                          )
                        else
                          Image.network(
                            existingImageUrl,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        String finalImageUrl = existingImageUrl;

                        if (updatedImageFile != null) {
                          finalImageUrl = await _uploadImageToCloudinary(
                            updatedImageFile!,
                          );
                        }

                        await FirebaseFirestore.instance
                            .collection('motors')
                            .doc(motor.id)
                            .update({
                              'name': nameController.text,
                              'price': priceController.text,
                              'details': detailsController.text,
                              'type': motorType,
                              'imageUrl': finalImageUrl,
                            });

                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _deleteMotor(String id) async {
    await FirebaseFirestore.instance.collection('motors').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Manage Motors',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _addMotor(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('motors').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          var motors = snapshot.data!.docs;
          return ListView.builder(
            itemCount: motors.length,
            itemBuilder: (context, index) {
              var motor = motors[index];
              return Card(
                color: Colors.white10,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading:
                      motor['imageUrl'] != null
                          ? Image.network(
                            motor['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                ),
                          )
                          : const Icon(Icons.motorcycle, color: Colors.white),
                  title: Text(
                    motor['name'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₱${motor['price']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Type: ${motor['type']}',
                        style: const TextStyle(color: Colors.greenAccent),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        motor['details'],
                        style: const TextStyle(color: Colors.white54),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _editMotor(context, motor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDeleteMotor(context, motor.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

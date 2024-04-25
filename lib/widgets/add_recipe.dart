import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as imageLib; // Correct import statement

class Ingredient {
  String name;
  String measurement;
  String quantity;

  Ingredient(
      {required this.name, required this.measurement, required this.quantity});
}

class AddRecipe extends StatefulWidget {
  final bool clickedCentreFAB;
  final VoidCallback updateClickedCentreFAB;

  AddRecipe(
      {required this.clickedCentreFAB, required this.updateClickedCentreFAB});

  @override
  State<AddRecipe> createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  int _currentStep = 0;
  int servings = 1;
  String title = '';
  String description = '';
  List<Ingredient> ingredients = [];
  Duration prepTime = const Duration();
  Duration cookingTime = const Duration();
  List<String> instructions = [];
  bool _showTags = false;
  List<int> _selectedCategoryIndices = [];
  List<String> categories = [
    "Breakfast",
    "Lunch",
    "Dinner",
    "Snack",
    "Dessert",
    "Indian",
    "Chinese",
    "American",
    "Pasta",
    "Pizza"
  ];

  CollectionReference recipes =
      FirebaseFirestore.instance.collection('recipes');

  File? _imageFile;

// Function to handle image picking
  // Function to handle image picking
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final File file = File(image.path);

      // Ensuring the correct file extension for JPEGs
      String targetPath = file.path.replaceAll(RegExp(r'\.jpeg$|\.jpg$'), '');
      targetPath +=
          '_compressed.jpg'; // Append a valid .jpg extension for the compressed file

      // Compress the image and get a new XFile object
      final XFile? img = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 90, // Adjust the quality as needed
      );

      if (img != null) {
        final File compressedFile = File(img.path);

        // Decode the image to check its dimensions
        final imageLib.Image? decodedImage =
            imageLib.decodeImage(await compressedFile.readAsBytes());
        if (decodedImage != null) {
          // Calculate the center crop dimensions
          final int size = min(decodedImage.width, decodedImage.height);
          final imageLib.Image croppedImage = imageLib.copyCrop(decodedImage,
              x: (decodedImage.width - size) ~/
                  2, // Calculate x offset for centering the crop
              y: (decodedImage.height - size) ~/
                  2, // Calculate y offset for centering the crop
              width: size,
              height: size);

          // Convert the cropped image back to a File object
          final List<int> croppedImageBytes =
              imageLib.encodeJpg(croppedImage, quality: 90);
          await compressedFile.writeAsBytes(croppedImageBytes);

          setState(() {
            _imageFile =
                compressedFile; // Update the state with the File object
          });
        }
      }
    }
  }

// Widget to display image and upload button
  Widget _buildImageUploadSection() {
    return Column(
      children: [
        if (_imageFile != null)
          Container(
            width: 140,
            child: Stack(
              children: [
                Image.file(_imageFile!,
                    width: 100, height: 100), // Display the selected image
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _imageFile = null; // Remove the image
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: ElevatedButton(
            onPressed: _pickImage,
            child: Text('Upload Image'),
          ),
        ),
      ],
    );
  }

  void addIngredientField() {
    setState(() {
      ingredients.add(Ingredient(name: "", measurement: "Grams", quantity: ""));
    });
  }

  void removeIngredientField(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  void addInstructionField() {
    setState(() {
      instructions.add('');
    });
  }

  void removeInstructionField(int index) {
    setState(() {
      instructions.removeAt(index);
    });
  }

  Widget ingredientField(int index) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            onChanged: (val) => setState(() {
              ingredients[index].name = val;
            }),
            decoration: InputDecoration(
              labelText: 'Ingredient ${index + 1}',
            ),
          ),
        ),
        Expanded(
          child: TextField(
            onChanged: (val) => setState(() {
              ingredients[index].quantity = val;
            }),
            decoration: InputDecoration(
              labelText: 'Quantity ${index + 1}',
            ),
          ),
        ),
        Expanded(
          child: TextField(
            onChanged: (val) => setState(() {
              ingredients[index].measurement = val;
            }),
            decoration: InputDecoration(
              labelText: 'Measurement ${index + 1}',
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () => removeIngredientField(index),
        ),
      ],
    );
  }

  Widget instructionField(int index) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            onChanged: (val) => setState(() {
              instructions[index] = val;
            }),
            decoration: InputDecoration(
              labelText: 'Step ${index + 1}',
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () => removeInstructionField(index),
        ),
      ],
    );
  }

  Widget categoryChipsWithLabel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tags',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        Container(
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    Theme.of(context).primaryColorDark, // Subtle blue outline
                width: 1.0, // Thin line for subtlety
              ),
              borderRadius: BorderRadius.circular(10.0), // Rounded corners
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Wrap(
                    spacing: 6.0, // Reduce horizontal spacing
                    runSpacing: 4.0, // Reduce vertical spacing
                    children:
                        List<Widget>.generate(categories.length, (int index) {
                      return SizedBox(
                        height: 30,
                        child: ChoiceChip(
                          label: Text(
                            categories[index],
                            style: TextStyle(
                              color: _selectedCategoryIndices.contains(index)
                                  ? Colors.white
                                  : Theme.of(context).primaryColorDark,
                              fontSize: 10.0, // Smaller text size for the chips
                            ),
                          ),
                          selected: _selectedCategoryIndices.contains(index),
                          selectedColor: Colors.blue.shade600,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategoryIndices.add(index);
                              } else {
                                _selectedCategoryIndices.remove(index);
                              }
                            });
                          },
                          backgroundColor: Colors.white,
                          elevation: _selectedCategoryIndices.contains(index)
                              ? 2.0
                              : 0.0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(
                              color: _selectedCategoryIndices.contains(index)
                                  ? Colors.blue.shade600
                                  : Colors.blue.shade200,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showTags = false;
                        _selectedCategoryIndices.clear();
                      });
                    },
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildTimePicker({
    required BuildContext context,
    required String label,
    required Duration time,
    required Function(int) setTime,
  }) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext builder) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              height: MediaQuery.of(context).size.height / 3,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 30,
                onSelectedItemChanged: setTime,
                children: List<Widget>.generate(60, (int index) {
                  return Text('$index minutes',
                      style: const TextStyle(color: Colors.black87));
                }),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        height: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer,
                color: Theme.of(context).primaryColorDark, size: 24),
            const SizedBox(height: 8),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${time.inMinutes} minutes',
                style: const TextStyle(fontSize: 14, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget horizontalStepIndicator(int stepNumber, String title) {
    bool isSelected = _currentStep == stepNumber;
    return InkWell(
      onTap: () => setState(() => _currentStep = stepNumber),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: isSelected ? Colors.blue : Colors.grey,
            child: Text('${stepNumber + 1}',
                style: const TextStyle(color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(title,
                style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.blue : Colors.grey)),
          ),
        ],
      ),
    );
  }

  List<Widget> getStepContent() {
    return [
      // Step 1: Basic Info
      Column(
        children: [
          SizedBox(
            height: 50, // Set this to the height you want.
            child: TextField(
              onChanged: (value) => setState(() => title = value),
              decoration: InputDecoration(
                labelText: 'Title',
                alignLabelWithHint: true,
                floatingLabelBehavior: FloatingLabelBehavior
                    .always, // Keeps the label always in the border.
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50, // Set this to the height you want.
            child: TextField(
              onChanged: (value) => setState(() => description = value),
              decoration: InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                floatingLabelBehavior: FloatingLabelBehavior
                    .always, // Keeps the label always in the border.
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              textAlign: TextAlign.left, // Aligns the text to the left.
              textAlignVertical:
                  TextAlignVertical.top, // Aligns the text to the top.
              maxLines: 2,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            child: SpinBox(
              min: 1,
              max: 12,
              value: 1,
              decoration: const InputDecoration(labelText: 'Servings'),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              iconColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).primaryColorDark),
              onChanged: (value) {
                setState(() {
                  servings = value.toInt();
                });
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          _buildImageUploadSection(),
          const SizedBox(height: 20),
          SizedBox(
            height: 100, // Set this to the height you want.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimePicker(
                  context: context,
                  label: 'Prep Time',
                  time: prepTime,
                  setTime: (newTime) =>
                      setState(() => prepTime = Duration(minutes: newTime)),
                ),
                _buildTimePicker(
                  context: context,
                  label: 'Cook Time',
                  time: cookingTime,
                  setTime: (newTime) =>
                      setState(() => cookingTime = Duration(minutes: newTime)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!_showTags)
            TextButton(
              onPressed: () => setState(() => _showTags = true),
              child: const Text('Add Tags'),
            ),
          if (_showTags) categoryChipsWithLabel(),
        ],
      ),
      // Step 2: Ingredients
      Column(
        children: [
          ...ingredients
              .map((ingredient) =>
                  ingredientField(ingredients.indexOf(ingredient)))
              .toList(),
          ElevatedButton(
            onPressed: addIngredientField,
            child: const Text('Add Ingredient'),
          )
        ],
      ),
      // Step 3: Instructions
      Column(
        children: [
          ...instructions
              .map((instruction) =>
                  instructionField(instructions.indexOf(instruction)))
              .toList(),
          ElevatedButton(
            onPressed: addInstructionField,
            child: const Text('Add Instruction'),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ElevatedButton(
              onPressed: addRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[
                    400], // Set the button color to the theme's primary color.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      24), // Set the border radius to the value you want.
                ),
              ),
              child: const Text(
                'Post Recipe',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 30.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  horizontalStepIndicator(0, 'Basic Info'),
                  horizontalStepIndicator(1, 'Ingredients'),
                  horizontalStepIndicator(2, 'Instructions'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: getStepContent()[_currentStep],
              ),
              if (_currentStep <
                  2) // Only show next button for the first two steps
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Set the width to 80% of the screen width.
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .primaryColor, // Set the button color to the theme's primary color.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            24), // Set the border radius to the value you want.
                      ),
                    ),
                    onPressed: () {
                      if (_currentStep < 2) {
                        setState(() {
                          _currentStep++;
                        });
                      }
                    },
                    child: const Text('Next',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addRecipe() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var uuid = const Uuid();
    String randomId = uuid.v4();
    List<String> selectedCategories =
        _selectedCategoryIndices.map((index) => categories[index]).toList();

    String? imageUrl = await _uploadImage(); // Upload image and retrieve URL

    final docIngredients = ingredients
        .map((ingredient) => {
              'name': ingredient.name,
              'quantity': ingredient.quantity,
              'measurement': ingredient.measurement
            })
        .toList();

    final document = {
      "recipeId": randomId,
      "title": title,
      "imageURL": imageUrl,
      "description": description,
      "ingredients": docIngredients,
      "instructions": instructions,
      "tags": selectedCategories,
      "prepTime": prepTime.toString(),
      "author": {
        "email": userProvider.email,
        "username": userProvider.username
      },
      "datePosted": DateTime.now().toIso8601String(),
    };

    await recipes.add(document).then((value) {
      print("Recipe Added");
      widget.updateClickedCentreFAB();
    }).catchError((error) => print("Failed to add recipe: $error"));
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    String fileName =
        'recipes/${DateTime.now().millisecondsSinceEpoch}_${_imageFile!.path.split('/').last}';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(fileName);

    UploadTask uploadTask = ref.putFile(_imageFile!);

    try {
      final TaskSnapshot snapshot = await uploadTask;
      final String imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}

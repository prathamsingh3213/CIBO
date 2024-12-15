import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:recipe_generator/themes/provider.dart';
import 'new.dart';

class IngredientSelectionPage extends StatefulWidget {
  const IngredientSelectionPage({super.key});

  @override
  IngredientSelectionPageState createState() => IngredientSelectionPageState();
}

class IngredientSelectionPageState extends State<IngredientSelectionPage> {
  List<String> selectedIngredients = [];
  List<String> essentials = [];

  bool isLoading = false;
  bool showInputField = false;
  final TextEditingController _manualIngredientController =
      TextEditingController();

  Map<String, List<String>> ingredientSections = {
    'Vegetables': [
      'Tomatoes',
      'Onions',
      'Garlic',
      'Potato',
      'Cabbage',
      'Cauliflower',
      'Eggplant',
    ],
    'Non-Veg': ['Chicken', 'Beef', 'Fish', 'Eggs', 'Mutton'],
    'Grains': ['Rice', 'Wheat', 'Barley', 'Corn', 'Millets'],
    'Fruits': ['Apples', 'Bananas', 'Grapes', 'Oranges'],
    'Dairy': ['Milk', 'Cheese', 'Yogurt', 'Butter', 'Cottage Cheese'],
  };

  String appBarTitle = 'Pick Your Ingredients';
  static const String makeDishButtonLabel = 'Make the Dish';

  Future<void> recommendDish() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Convert the list of selected ingredients and essentials to comma-separated strings
      final String ingredientsString = selectedIngredients.join(',');
      // final String essentialsString = essentials.join(',');

      final response = await http.post(
        Uri.parse(
            'http://192.168.0.197:5000/recommend'), // Update with your actual API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ingredients': ingredientsString,
          "essentials": essentials,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;

        // Navigate to the new page with the recommendation data
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) =>
                NewPage(recommendationData: data, itemlist: ingredientsString),
          ),
        );
      } else {
        debugPrint(
            'Failed to load recommendations. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Show an error message to the user
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(// Use Consumer for theme awareness
        builder: (context, themeProvider, child) {
      Color buttonColor = selectedIngredients.isEmpty
          ? Colors.grey
          : Colors.black; // Use theme's primary color

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          forceMaterialTransparency: true,
          automaticallyImplyLeading: false,
          title: Text(
            appBarTitle,
            style: TextStyle(
              fontFamily: "head", // Assuming you have this font
              color: Theme.of(context).appBarTheme.foregroundColor,
              fontSize: 25,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.delete,
                  color: Theme.of(context).appBarTheme.foregroundColor),
              onPressed: () {
                setState(() {
                  selectedIngredients.clear();
                  essentials.clear();
                });
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10, bottom: 0),
                  child: Row(
                    children: [
                      Text(
                        'Enter Ingredients',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color, // Use theme's text color
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(showInputField
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                        onPressed: () {
                          setState(() {
                            showInputField = !showInputField;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (showInputField)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0),
                        child: TextField(
                          controller: _manualIngredientController,
                          decoration: const InputDecoration(
                            hintText:
                                'Enter ingredient(s) seperated by a comma',
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              if (value.trim().isNotEmpty) {
                                selectedIngredients.add(value.trim());
                                _manualIngredientController.clear();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: ingredientSections.length,
                    itemBuilder: (context, index) {
                      String sectionTitle =
                          ingredientSections.keys.elementAt(index);
                      List<String> sectionIngredients =
                          ingredientSections[sectionTitle]!;

                      return Container(
                        margin: const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  ),
                                ),
                                child: Text(
                                  sectionTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color, // Use theme's text color
                                  ),
                                ),
                              ),
                              Column(
                                children: sectionIngredients.map((ingredient) {
                                  return ListTile(
                                    title: Row(
                                      children: [
                                        Transform.scale(
                                          scale: 1.2,
                                          child: Checkbox(
                                            tristate: true,
                                            activeColor: Colors.white,
                                            checkColor: Colors.black,
                                            fillColor: WidgetStateProperty
                                                .resolveWith<Color>(
                                                    (Set<WidgetState>
                                                        states) {
                                              if (states.contains(
                                                  WidgetState.selected)) {
                                                return (essentials
                                                        .contains(ingredient))
                                                    ? Colors.orange // Essential
                                                    : Colors.black; // Selected
                                              }
                                              return const Color.fromRGBO(
                                                  219, 219, 219, 1); // Default
                                            }),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                            value: selectedIngredients
                                                    .contains(ingredient)
                                                ? (essentials
                                                        .contains(ingredient)
                                                    ? null
                                                    : true)
                                                : false,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value == true) {
                                                  selectedIngredients
                                                      .add(ingredient);
                                                } else if (value == false) {
                                                  selectedIngredients
                                                      .remove(ingredient);
                                                  essentials.remove(ingredient);
                                                } else {
                                                  // value == null
                                                  essentials.add(ingredient);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        Text(ingredient),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            ]),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: selectedIngredients.isEmpty
                        ? null
                        : () {
                            // Set up a delay to show the loading screen for a brief moment
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              recommendDish();
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 25.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                    ),
                    child: const Text(
                      makeDishButtonLabel,
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ),
              ],
            ),
            // Loading Screen
            if (isLoading)
              Container(
                color: Colors.transparent,
                child: const Center(
                  child: Card(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16.0),
                          Text(
                            'Making the dish...',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

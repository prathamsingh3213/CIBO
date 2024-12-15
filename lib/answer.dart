import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:recipe_generator/favourite/FavoriteRecipesPage.dart';
import 'package:recipe_generator/themes/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnswerPage extends StatefulWidget {
  final Map<String, dynamic> dishDetails;
  final String itemlist;
  final Map<String, dynamic>? recipeDetails; 
  final dynamic recipeData; 

  // Constructor for NewPage
  const AnswerPage({
    super.key,
    required this.dishDetails,
    required this.itemlist,
    required this.recipeData,
    this.recipeDetails,
  });

  // Constructor for SearchPage
  const AnswerPage.fromSearch({
    super.key,
    required this.dishDetails, 
    this.itemlist = '',
    this.recipeData, 
    this.recipeDetails, 
  });

  @override
  AnswerPageState createState() => AnswerPageState();
}

class AnswerPageState extends State<AnswerPage> {
  int selectedTabIndex = 0;
  Map<String, dynamic> recipeDetails = {};
  String? recipeImage;
  final ScrollController _scrollController = ScrollController();
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipeData();
    _loadFavoriteStatus(); 
  }

  Future<void> _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = prefs
          .containsKey(widget.dishDetails['name']); 
    });
  }

  // Save/Remove favorite to/from SharedPreferences
  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = !isFavorite;
      if (isFavorite) {
        Map<String, dynamic> dataToSave =
            Map.from(widget.dishDetails); // Create a copy
        dataToSave['image'] = recipeImage; // Add the image URL to the copy
        prefs.setString(widget.dishDetails['name'], jsonEncode(dataToSave));
      } else {
        prefs.remove(widget.dishDetails['name']);
      }
    });
  }

  Future<void> _fetchRecipeData() async {
    try {
      final recipeName = widget.dishDetails['name'];
      Map<String, dynamic> details = await fetchRecipeDetails(recipeName);
      String? image = await fetchRecipeImage(recipeName);

      // Update state after fetching data
      if (mounted) {
        setState(() {
          recipeDetails = details;
          recipeImage = image;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching recipe data: $e');
      }
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails(String recipeName) async {
    final apiUrl =
        'https://api.edamam.com/search?q=$recipeName&app_id=b78772ec&app_key=97b09424dba99226112c19ce11d39189';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hits = data['hits'];
      if (hits.isNotEmpty) {
        return hits[0]['recipe'];
      }
    }

    return {
      'image':
          'https://www.msi-viking.com/sca-dev-2023-1-0/img/no_image_available.jpeg',
      'totalNutrients': {},
    };
  }

  String trimTitle(String fullName) {
    // Capitalize the first letter of the recipe name
    String capitalizedRecipeName = fullName.isNotEmpty
        ? fullName[0].toUpperCase() + fullName.substring(1)
        : '';

    // Split the words and take the first 5 to create a trimmed title
    List<String> words = capitalizedRecipeName.split(' ');
    return words.take(5).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    Color textColor = Theme.of(context).textTheme.bodyLarge!.color!;
    Color highlightColor = Colors.orange;
    Color iconColor = Theme.of(context).iconTheme.color!;

    return Scaffold(
        floatingActionButton: recipeDetails.isNotEmpty &&
                recipeImage != null 
            ? GestureDetector(
                onLongPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesPage(),
                    ),
                  );
                },
                child: FloatingActionButton(
                  onPressed: _toggleFavorite,
                  backgroundColor: Colors.orange,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
        body: recipeDetails.isEmpty || recipeImage == null
            ? _buildLoadingScreen()
            : Stack(children: [
                Image.network(
                  recipeImage!,
                  height: MediaQuery.of(context).size.height * 0.50,
                  fit: BoxFit.cover,
                ),
                NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        floating: true,
                        pinned: true,
                        expandedHeight: 350.0,
                        flexibleSpace: const FlexibleSpaceBar(
                          
                            ),
                        leading: Center(
                          child: IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 40,
                              weight: 10,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ];
                  },

                  body: LayoutBuilder(builder: (context, constraints) {
                    double availableHeight = constraints.maxHeight;
                    double minContentHeight =
                        MediaQuery.of(context).size.height *
                            0.55; // Image height
                    bool contentFits = availableHeight >= minContentHeight;
                    return ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                      child: SingleChildScrollView(
                        // Conditionally set physics to allow/disallow scrolling
                        physics: contentFits
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        child: Container(
                          constraints:
                              BoxConstraints(minHeight: minContentHeight),
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height *
                                  0.04), // Add padding to the top
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                            color: backgroundColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Recipe Title
                                Text(
                                  trimTitle(widget.dishDetails['name']),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "bold",
                                  ),
                                ),

                                // Time to Cook
                                const SizedBox(height: 12.0),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, color: iconColor),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      '${widget.dishDetails['minutes']} minutes',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(
                                        width: 20.0), // Add some spacing
                                    Icon(Icons.person, color: iconColor),
                                    const SizedBox(width: 8.0),
                                    Text('${recipeDetails['yield']} servings',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                            color: textColor)),
                                  ],
                                ),

                                // Tabs
                                const SizedBox(height: 12.0),
                                _buildTabs(), // Use the theme-aware _buildTabs method
                                const SizedBox(height: 12.0),

                                // Display selected tab content
                                selectedTabIndex == 0
                                    ? _buildIngredients(textColor,
                                        highlightColor) // Use the theme-aware _buildIngredients method
                                    : selectedTabIndex == 1
                                        ? _buildSteps(
                                            textColor) // Use the theme-aware _buildSteps method
                                        : _buildNutrients(textColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                )
              ]));
  }

  Widget _buildLoadingScreen() {
    Color backgroundColor = Theme.of(context)
        .scaffoldBackgroundColor; // Get background color from the theme

    return Container(
      color: backgroundColor, // Use backgroundColor here
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              strokeWidth: 4.0,
            ),
            const SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color, // Use text color from the theme
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTab('Ingredients'),
          //  SizedBox(width: 40.0),
          _buildTab(' Steps '),
          //SizedBox(width: 2.0),
          _buildTab('Nutrients'), // Add tab for nutrients
        ],
      ),
    );
  }

  Widget _buildTab(String label) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 5),
      margin: const EdgeInsets.symmetric(horizontal: 3.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        border: Border.all(color: Colors.black),
        color: selectedTabIndex ==
                (label == 'Ingredients'
                    ? 0
                    : label == ' Steps '
                        ? 1
                        : 2)
            ? Colors.orange
            : Colors.white,
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedTabIndex = label == 'Ingredients'
                ? 0
                : label == ' Steps '
                    ? 1
                    : 2;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: selectedTabIndex ==
                    (label == 'Ingredients'
                        ? 0
                        : label == ' Steps '
                            ? 1
                            : 2)
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildIngredients(Color textColor, Color highlightColor) {
    List<String>? ingredientsList = widget.dishDetails['ingredients']
        ?.replaceAll(RegExp(r"[\[\]']"), '')
        .split(',');
    List<String> itemList = widget.itemlist.toLowerCase().split(',');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredients:',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 25.0, color: textColor)),
        const SizedBox(height: 8), // Add some spacing
        if (ingredientsList != null)
          Column(
            // Use Column instead of ListView.builder
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ingredientsList.map((ingredient) {
              bool isHighlighted =
                  itemList.contains(ingredient.trim().toLowerCase());
              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 2.0), // Add spacing between ingredients
                child: Row(
                  // Use a Row for the icon and text
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.circle,
                        color: isHighlighted ? highlightColor : textColor,
                        size: 11),
                    const SizedBox(
                        width: 12), // Add some spacing between icon and text
                    Expanded(
                      // Make the text take the remaining space
                      child: Text(
                        _capitalizeFirstLetter(ingredient),
                        style: TextStyle(
                            color: isHighlighted ? highlightColor : textColor,
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSteps(Color textColor) {
    List<String> stepsList = (widget.dishDetails['steps'] as String)
        .split(',')
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .map((step) {
      // Correct the syntax for the map function
      while (step.isNotEmpty && !RegExp(r'[a-zA-Z]').hasMatch(step[0])) {
        step = step.substring(1).trim();
      }
      return step;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Steps:',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 22.0, color: textColor)),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stepsList.length,
          itemBuilder: (context, index) {
            String capitalizedStep = stepsList[index][0].toUpperCase() +
                stepsList[index].substring(1);
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.orange,
                child: Text('${index + 1}',
                    style: const TextStyle(color: Colors.black, fontSize: 15)),
              ),
              title: Text(
                capitalizedStep,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            );
          },
          separatorBuilder: (context, index) =>
              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
        ),
      ],
    );
  }

  Widget _buildNutrients(Color textColor) {
    if (recipeDetails.containsKey('totalNutrients') &&
        recipeDetails['totalNutrients'] != null &&
        recipeDetails['totalNutrients'].isNotEmpty) {
      // Check if it's NOT empty

      Map<String, dynamic> nutrients = recipeDetails['totalNutrients'];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Nutrients:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 12.0),
          Column(
            children: nutrients.keys.map((key) {
              Map<String, dynamic> nutrient = nutrients[key];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: const Icon(Icons.local_dining, color: Colors.orange),
                  title: Text(
                    nutrient['label'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    '${nutrient['quantity'].toStringAsFixed(1)} ${nutrient['unit']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    } else {
      return const Text('No nutrient information available.');
    }
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isNotEmpty) {
      return input[0].toUpperCase() + input.substring(1);
    }
    return '';
  }

  Future<String> fetchRecipeImage(String recipeName) async {
    final apiUrl =
        'https://api.edamam.com/search?q=$recipeName&app_id=b78772ec&app_key=97b09424dba99226112c19ce11d39189';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hits = data['hits'];
      if (hits.isNotEmpty) {
        return hits[0]['recipe']['image'];
      }
    }

    // Placeholder URL or default image URL in case of an error
    return 'https://www.msi-viking.com/sca-dev-2023-1-0/img/no_image_available.jpeg';
  }
}

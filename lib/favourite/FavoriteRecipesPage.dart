// favorites_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:recipe_generator/answer.dart';
import 'package:recipe_generator/new.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; 

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  FavoritesPageState createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  List<Map<String, dynamic>> favoriteRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recipeNames = prefs.getKeys().toList();
    List<Map<String, dynamic>> fetchedRecipes = [];

    for (String recipeName in recipeNames) {
      final recipeData =
          jsonDecode(prefs.getString(recipeName)!) as Map<String, dynamic>;
      final imageUrl = await fetchRecipeImage(recipeName);
      recipeData['image'] = imageUrl;
      fetchedRecipes.add(recipeData);
    }

    setState(() {
      favoriteRecipes = fetchedRecipes;
      isLoading = false;
    });
  }

  void _removeFavorite(String recipeName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(recipeName);

    setState(() {
      favoriteRecipes.removeWhere((recipe) => recipe['name'] == recipeName);
    });
  }

  // Function to fetch recipe image from Edamam API
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
    return 'https://www.msi-viking.com/sca-dev-2023-1-0/img/no_image_available.jpeg'; // Default Image
  }

  // Loading Screen (copied from answer.dart)
  Widget _buildLoadingScreen() {
    Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: backgroundColor,
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
              'Loading favorites...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Recipes'),
      ),
      body: isLoading
          ? _buildLoadingScreen()
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: favoriteRecipes.isEmpty
                  ? const Center(
                      child: Text('No favorite recipes yet!'),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: favoriteRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = favoriteRecipes[index];
                        final recipeName =
                            recipe['name'] as String? ?? 'Unknown Recipe';
                        final imageUrl = recipe['image']
                            as String; // Image URL should be available now

                        return RecipeCard(
                          imageUrl: Future.value(imageUrl),
                          title: recipeName,
                          description: recipe['description'] ?? '',
                          ingredientsMatch: true,
                          time: recipe['minutes'] ?? 0,

                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnswerPage.fromSearch(
                                dishDetails: recipe,
                              ),
                            ),
                          ),
                          onDelete: () => _removeFavorite(
                              recipeName), // Pass onDelete callback
                        );
                      },
                    ),
            ),
    );
  }
}

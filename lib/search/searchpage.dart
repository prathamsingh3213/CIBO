import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_generator/answer.dart'; 
import 'package:recipe_generator/new.dart'; 
import 'package:provider/provider.dart';
import 'package:recipe_generator/themes/provider.dart'; 

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = "";
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _searchRecipeByName(String query) async {
    if (query.isEmpty) {
      setState(() {
        _errorMessage = "Please enter a recipe name.";
        _searchResults = []; // Clear previous results
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      const apiUrl =
          'http://192.168.0.197:5000/recommend_by_name'; 
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'recipe_name': query}),
      );

      if (response.statusCode == 200) {
        final results = json.decode(response.body) as List<dynamic>;
        setState(() {
          _searchResults = results.cast<Map<String, dynamic>>();
        });
      } else {
        setState(() {
          _errorMessage = "Error: Failed to search for recipe.";
          _searchResults = [];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _searchResults = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String trimRecipeName(String name) {
    String trimmedName =
        name.length <= 18 ? name : '${name.substring(0, 17)}...';
    return trimmedName.isNotEmpty
        ? trimmedName[0].toUpperCase() + trimmedName.substring(1)
        : trimmedName;
  }

  Future<String> _fetchRecipeImage(String recipeName) async {
    final apiUrl =
        'https://api.edamam.com/search?q=$recipeName&app_id=b78772ec&app_key=97b09424dba99226112c19ce11d39189';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hits = data['hits'];
      if (hits.isNotEmpty) {
        final firstHit = hits[0] as Map<String, dynamic>;
        final recipe = firstHit['recipe'] as Map<String, dynamic>;
        final image = recipe['image'] as String?;

        return image ??
            'https://www.msi-viking.com/sca-dev-2023-1-0/img/no_image_available.jpeg';
      }
    }
    return 'https://www.msi-viking.com/sca-dev-2023-1-0/img/no_image_available.jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          ' Search Recipes',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontFamily: "head", fontSize: 26),
        ),
        backgroundColor: themeProvider.themeMode == ThemeMode.dark
            ? Colors.grey[800]
            : Colors.white, // Example theme color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: TextStyle(
                // Text color based on theme
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.white
                    : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Search by recipe name',
                filled: true,
                fillColor: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.grey[700]
                    : const Color.fromARGB(255, 219, 212, 212),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isLoading
                    ? Transform.scale(
                        scale: 0.7,
                        child: const CircularProgressIndicator(),
                      )
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _errorMessage = "";
                          });
                        },
                      ),
              ),
              onSubmitted: (query) => _searchRecipeByName(query.trim()),
            ),
            const SizedBox(height: 16.0),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search,
                              size: 64, color: Colors.grey),
                          Text(
                            'Search for recipes above...',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final dish = _searchResults[index];
                        return RecipeCard(
                          imageUrl: _fetchRecipeImage(dish['name']),
                          title: trimRecipeName(dish['name']),
                          description: dish['description'] ?? '',
                          ingredientsMatch: true,
                          time: dish['minutes'] ?? 0,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnswerPage.fromSearch(
                                dishDetails: dish,
                                recipeDetails: const {},
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

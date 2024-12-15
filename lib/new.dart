import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_generator/themes/provider.dart';
import 'answer.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewPage extends StatelessWidget {
  final List recommendationData;
  final String itemlist;

  const NewPage(
      {super.key, required this.recommendationData, required this.itemlist});

  String trimRecipeName(String name) {
    String trimmedName =
        name.length <= 18 ? name : '${name.substring(0, 17)}...';
    return trimmedName.isNotEmpty
        ? trimmedName[0].toUpperCase() + trimmedName.substring(1)
        : trimmedName;
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

  bool checkIngredientsMatch(Map<String, dynamic> dish) {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context)
              .scaffoldBackgroundColor, // Use theme background color
          appBar: AppBar(
            forceMaterialTransparency: true,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.fromLTRB(8, 1, 1, 1),
              child: Text(
                'Top Results',
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: "head",
                  fontSize: 26.0,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.75, // Adjust the aspect ratio as needed
              ),
              itemCount: recommendationData.length,
              itemBuilder: (context, index) {
                final dish = recommendationData[index];
                return RecipeCard(
                  imageUrl:
                      fetchRecipeImage(dish['name']), // Async image loading
                  title: trimRecipeName(dish['name']),
                  description: dish['description'] ?? '',
                  ingredientsMatch: checkIngredientsMatch(dish),
                  time: dish['minutes'] ?? 0,
                  onTap: ()

                  {
                    print('dish$dish');

                    print('itemlist$itemlist');
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnswerPage(
                        dishDetails: dish,
                        itemlist: itemlist,
                        recipeData: null,
                      ),
                    ),
                  );
                  }

                );
              },
            ),
          ),
        );
      },
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Future<String> imageUrl;
  final String title;
  final String description;
  final bool ingredientsMatch; // You might not need this in favorites_page.dart
  final VoidCallback onTap;
  final int time;
  final VoidCallback? onDelete; // Optional onDelete callback

  const RecipeCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.ingredientsMatch,
    required this.onTap,
    required this.time,
    this.onDelete, // Make onDelete optional
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Card(
        elevation: 0,
        color: Theme.of(context).cardColor,
        child: InkWell(
          // <-- Move InkWell inside the Card
          onTap: onTap,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 2,
                    child: FutureBuilder(
                      future: imageUrl,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return const Center(child: Icon(Icons.error));
                        } else {
                          return ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$time minutes',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (onDelete != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.black, // Set the color to orange
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

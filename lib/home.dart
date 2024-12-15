import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_generator/favourite/FavoriteRecipesPage.dart';
import 'package:recipe_generator/lens/lenspage.dart';
import 'package:recipe_generator/search/searchpage.dart';
import 'package:recipe_generator/themes/provider.dart';
import 'selector.dart';
import 'group.dart';
// import "secret.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 1),
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.menu, size: 30.0),
                    onSelected: (value) {
                      if (value == 'Secret') {
                        _showPasswordDialog();
                      } else if (value == 'Theme') {
                      
                      } else {
                        handleMenuClick(value);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'App Version',
                          child: Text('App Version'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'About',
                          child: Text('About'),
                        ),
                        // const PopupMenuItem<String>(
                        //   value: 'Secret',
                        //   child: Text('Secret'),
                        // ),
                        PopupMenuItem<String>(
                          value: 'Theme',
                          child: Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return SwitchListTile(
                                title: const Text('Dark Mode'),
                                value:
                                    themeProvider.themeMode == ThemeMode.dark,
                                onChanged: (value) {
                                  themeProvider
                                      .toggleTheme(value); // Toggle the theme
                                },
                              );
                            },
                          ),
                        ),
                      ];
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),

                 
                  const Spacer(),

                  Padding(
                    // Add padding around the icons
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      // Wrap the icons in a Row
                      children: [
                        IconButton(
                          onPressed: _goToSearchPage,
                          icon: const Icon(Icons.search),
                        ),
                        IconButton(
                          // Heart icon button
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const FavoritesPage()),
                            );
                          },
                          icon: const Icon(Icons.favorite),
                        ),
                        IconButton(
                          onPressed: () {
                            // Navigate to LensPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LensPage()),
                            );
                          },
                          icon: const Icon(Icons
                              .camera_alt), // Or Google Lens icon if available
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showImageDialog();
                    },
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/icons/logo.png'),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
                  child: Text(
                    'Welcome user,',
                    style: TextStyle(
                      fontFamily: 'reg',
                      fontSize: 20,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
                  child: Text(
                    'Let us Cook',
                    style: TextStyle(
                      fontFamily: 'head',
                      fontSize: 35,
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                  width: (MediaQuery.of(context).size.width),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const IngredientSelectionPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromRGBO(88, 88, 88, 1),
                        backgroundColor: const Color.fromRGBO(233, 233, 233, 1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 4, right: 20),
                            child: Icon(Icons.tune),
                          ),
                          Center(
                            child: Text(
                              'Select your ingredients',
                              style: TextStyle(
                                fontFamily: 'reg',
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: (MediaQuery.of(context).size.width),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                          child: Text(
                            'Popular Dishes',
                            style: TextStyle(
                              fontFamily: 'bold',
                              fontSize: 25,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Group23(
                            "Butter chicken",
                            "Butter Chicken also known as Chicken Makhani is a classic Indian dish that's made by simmering marinated & grilled chicken ",
                            "100 mins",
                            "assets/images/bc.jpg",
                            {
                              'name': 'Butter chicken',
                              'minutes': 30,
                              'ingredients':
                               '[Ground beef,Burger buns,Cheese slices,Lettuce,Tomatoes,Onions,Ketchu,Mayonnaise]'
                              ,
                              'steps':
                                'To a pan, heat 1 tablespoon oil and add 1/2 pound of ground beef. You can add more beef patties if you prefer. Fry until well-cooked. Remove to a plate and set aside.,Slice the burger buns in half. Place them on a grill or in a toaster until golden and toasted. Set aside.,Prepare the veggies by washing and slicing lettuce, tomatoes, and onions.,In the same pan, add slices of cheese to the cooked beef patties and cover with a lid for a minute to melt the cheese.,Assemble the burger: Place the cheesy beef patty on the bottom half of the toasted bun. Top it with lettuce, tomatoes, and onions.,Squeeze ketchup and mayonnaise on the veggies. Place the other half of the bun on top.,Delicious Burger is ready to be enjoyed!',


                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Group23(
                            "Burger",
                            "A burger is a handheld culinary delight featuring a seasoned ground meat patty in a bun, customizable with various toppings and condiments.",
                            "30 mins",
                            "assets/images/burger4.png",
                            {
                              'name': 'Burger',
                              'ingredients':
                                '[Buns,Lettuce,Tomato,Cheese slice,Patty,Tandoori sauce]'
                              ,
                              'minutes': 30,
                              'steps':
                                'Use Ground Chuck Beef (80/20) – grind your own or buy it ground, but 20% fat is ideal and keep it refrigerated until you’re ready to use it.,Don’t overwork your meat – this will make it tough and dense.,Shape the patties 1” wider than the bun since they shrink on the grill.,Make an indentation in the center to prevent it from plumping up in the center.,Don’t Season too early – Salt changes the structure of proteins and toughens burgers so don’t season your ground beef until you have formed your patties and are ready to grill.,Get a good Sear – Once on the grill, let patties brown and sear well (3-5 min) before flipping, and do not press down on the burger save that for making',


                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Group23(
                            "Carrot halwa",
                            "Popular Indian sweet dish made from carrot",
                            "180 mins",
                            "assets/images/ch.jpg",
                            {
                              'name': 'Carrot Halwa',
                              'minutes': 150,
                              'ingredients':
                                '[Carrots,Ghee, Milk,Sugar, Khoya]'
                              ,
                              'steps':
                                'To a pan heat 1 tablespoon ghee add 1 tablespoon chopped nuts. You can add more nuts if you prefer. Fry until golden. Remove to a bowl and set aside.,Wash carrots well, trim the edges and peel off the skin. Grate it using a grater, measure 2 cups and add it.,Saute for at least 3-5 mins or until it shrinks a bit and the color changes.,Add 1 and 1/2 cups full-fat milk (boiled). Keep the flame in low medium for the milk to reduce. It will nicely bubble and start reducing slowly, stir on and off. Cook for 10 mins or until milk reduces to 3/4th. Keep stirring in between to avoid sticking at the bottom. Keep scraping the sides for the milk solids, add it into the boiling mixture. Keep cooking in medium flame.,Now milk is reduced to 3/4th. At this stage add 2 tablespoon unsweetened khoya. If you add sweetened khoya adjust sugar accordingly. You can completely skip this step if you do not have khoya.,Add 1/3 cup sugar. Once you add sugar, it will again become runny, just keep cooking and stirring. Keep stirring so that it does not stick to the bottom of the pan. It will start to thicken. Halwa becomes thick but still moist. The mixture comes together with a sticky texture that’s the right consistency.,Delicious Carrot Halwa is ready',


                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void handleMenuClick(String value) {
    switch (value) {
      case 'App Version':
        showAppVersionDialog();
        break;
      case 'About':
        showAboutDialog();
        break;
    }
  }

  void showAppVersionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('App Version'),
          content: const Text('Version beta 1.097'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recipe Generator App: Cibo'),
          content: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Developers:'),
              ListTile(
                leading: Icon(Icons.star),
                title: Text('Pratham'),
              ),
          
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            height: 200.0,
            width: 200.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: const DecorationImage(
                image: AssetImage('assets/icons/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  _goToSearchPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SearchPage()));
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            onChanged: (value) {
              _password = value;
            },
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Password',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_password == 'goty') {
                  // Navigator.pop(context);
                  // Add your secret functionality here
                  // For example: Navigator.push(context, MaterialPageRoute(builder: (context) => SecretPage()));
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => const SecretPage()));
                // } else {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text('Incorrect password')),
                //   );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}

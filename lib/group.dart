import 'package:flutter/material.dart';
import 'package:recipe_generator/answer.dart';
// import 'halwa.dart';

class Group23 extends StatelessWidget {
  final String dishName;
  final String dishDesc;
  final String dishTime;
  final String imageAssetPath;

  final Map<String, dynamic> halwaData;

  const Group23(this.dishName, this.dishDesc, this.dishTime,
      this.imageAssetPath, this.halwaData,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnswerPage(
                  dishDetails: halwaData,
                  itemlist: "",
                  recipeData: null,
                ),
              ),
            ),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.only(
              left: 12,
            ),
            height: MediaQuery.of(context).size.width * 0.4,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: MediaQuery.of(context).size.width * 0.08,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.92,
                    height: MediaQuery.of(context).size.width * 0.29,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(1.00, -0.09),
                        end: Alignment(-1, 0.09),
                        colors: [Color(0xFFF09E23), Color(0xFFDD8400)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.4,
                          top: MediaQuery.of(context).size.width * 0.04,
                          child: Text(
                            dishName,
                            style: const TextStyle(
                              color: Color(0xFF3C2000),
                              fontSize: 20,
                              fontFamily: 'Vinila Test',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.4,
                          top: MediaQuery.of(context).size.width * 0.20,
                          child: Text(
                            dishTime,
                            style: const TextStyle(
                              color: Color(0xFF3C2000),
                              fontSize: 11,
                              fontFamily: 'reg',
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.4,
                          top: MediaQuery.of(context).size.width * 0.1,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.42,
                            height: MediaQuery.of(context).size.width * 0.09,
                            child: Text(
                              dishDesc,
                              style: const TextStyle(
                                color: Color(0xAD1A1A1A),
                                fontSize: 10,
                                fontFamily: 'reg',
                                fontWeight: FontWeight.w500,
                                height: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.04,
                  top: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.33,
                    height: MediaQuery.of(context).size.width * 0.32,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            imageAssetPath), // Load image from assets
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]));
  }
}

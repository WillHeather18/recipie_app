import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../pages/recipe_page.dart';

class RecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipeData;

  RecipeCard({required this.recipeData});

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool isLiked = false;

  bool showMore = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              child: Row(
                children: [
                  Text(widget.recipeData['author']['username'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24)),
                ],
              ),
            ),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetailsPage(recipeData: widget.recipeData)),
                  );
                },
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        decoration: const BoxDecoration(),
                        child: Hero(
                          tag: widget.recipeData['imageURL'],
                          child: Image.network(
                            widget.recipeData['imageURL'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0x0000cd77),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: ListView.builder(
                          itemCount: widget.recipeData['tags'].length,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 20,
                              width: 60,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 12, 179, 109),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Text(
                                widget.recipeData['tags'][index],
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                )),
            Container(
              height: 50,
              decoration: const BoxDecoration(),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.comment_outlined),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Row(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  timeago
                      .format(DateTime.parse(widget.recipeData['datePosted'])),
                  style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

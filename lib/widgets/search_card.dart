import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipie_app/pages/recipe_page.dart';
import '../providers/user_provider.dart';
import '../service/user_service.dart';

class SearchCard extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final String heroTag;

  const SearchCard({Key? key, required this.recipeData, required this.heroTag})
      : super(key: key);

  @override
  State<SearchCard> createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userService = UserService(userProvider: userProvider);

    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailsPage(
                recipeData: widget.recipeData,
                heroTag: widget.heroTag,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                tag: widget.heroTag,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    widget.recipeData['imageURL'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Container(
                  height: 50, // Adjust the height as needed
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Row(children: [
                FutureBuilder<Map<String, dynamic>>(
                    future: userService.getOtherUserDetails(
                        widget.recipeData['author']['username']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(
                            child: Text('Error retrieving author details.'));
                      }

                      final authorDetails = snapshot.data;

                      return CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(
                          authorDetails?['profilePictureUrl'],
                        ),
                      );
                    }),
                const SizedBox(width: 5),
                Text(
                  widget.recipeData['author']['username'],
                  style: const TextStyle(color: Colors.white),
                ),
              ]),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.recipeData['interactions']['likes']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(10)),
                child: Container(
                  height: 60, // Adjust the height as needed
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipeData['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

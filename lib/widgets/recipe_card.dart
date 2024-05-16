import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../pages/recipe_page.dart';
import '../service/recipe_service.dart';
import '../service/user_service.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';

class RecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final String username;

  const RecipeCard(
      {super.key, required this.recipeData, required this.username});

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  var recipeService = RecipeService();
  var userService = UserService(
    userProvider: UserProvider(),
  );
  bool isLiked = false;
  late bool isFollowing;
  Future<bool>? isFollowingFuture;

  bool showMore = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    print("Url is: ${userProvider.profilePictureUrl}");

    var isLiked = userService.checkIsLiked(
        widget.recipeData['recipeId'], widget.username);

    var isFollowing = userService.checkIsFollowing(
        widget.username, widget.recipeData['author']['username']);

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
                  FutureBuilder<Map<String, dynamic>>(
                    future: userService.getOtherUserDetails(
                        widget.recipeData['author']['username']),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // or some other widget while waiting
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final authorDetails = snapshot.data;
                        return CircleAvatar(
                          backgroundImage:
                              NetworkImage(authorDetails?['profilePictureUrl']),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(widget.recipeData['author']['username'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24)),
                  ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  if (widget.username !=
                      widget.recipeData['author']['username'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FutureBuilder<bool>(
                        future: isFollowing,
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // or some other widget while waiting
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return ElevatedButton(
                              onPressed: () async {
                                await userService.followUser(widget.username,
                                    widget.recipeData['author']['username']);
                                bool following =
                                    await userService.checkIsFollowing(
                                        widget.username,
                                        widget.recipeData['author']
                                            ['username']);

                                setState(() {
                                  isFollowing = Future.value(following);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: snapshot.data ?? false
                                    ? Colors.green
                                    : Colors.blue, // background color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                              child: Text(
                                snapshot.data ?? false ? 'Following' : 'Follow',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecipeDetailsPage(
                              recipeData: widget.recipeData,
                              heroTag: widget.recipeData['imageURL'],
                            )),
                  );
                },
                child: Container(
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
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
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, left: 5),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                                height: 20,
                                width: MediaQuery.of(context)
                                    .size
                                    .width, // Set a width for the Container
                                decoration: const BoxDecoration(
                                  color: Color(0x0000cd77),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: Wrap(
                                  spacing: 8.0, // gap between adjacent tags
                                  runSpacing: 4.0, // gap between lines
                                  direction:
                                      Axis.horizontal, // direction of the Wrap
                                  alignment: WrapAlignment
                                      .start, // align tags to the end
                                  children: List.generate(
                                    widget.recipeData['tags'].length,
                                    (index) {
                                      // List of colors
                                      List<Color> colors = [
                                        Colors.red,
                                        Colors.green,
                                        Colors.blue,
                                        Colors.yellow,
                                        Colors.orange,
                                        // Add more colors if needed
                                      ];

                                      return Container(
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: colors[index %
                                              colors
                                                  .length], // Select a color based on the index
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            widget.recipeData['tags'][index],
                                            style: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
            Container(
              height: 50,
              decoration: const BoxDecoration(),
              child: Row(
                children: [
                  Row(
                    children: [
                      FutureBuilder<bool>(
                        future: isLiked,
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () {},
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return IconButton(
                              icon: Icon(
                                snapshot.data ?? false
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    snapshot.data ?? false ? Colors.red : null,
                              ),
                              onPressed: () {
                                recipeService.addLike(
                                    widget.recipeData['recipeId'],
                                    widget.username);
                              },
                            );
                          }
                        },
                      ),
                      Text(
                        widget.recipeData['interactions']['likes'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.comment_outlined),
                        onPressed: () {},
                      ),
                      Text(
                        widget.recipeData['interactions']['comments'].length
                            .toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () {},
                      ),
                      Text(
                        widget.recipeData['interactions']['shares'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Row(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  timeago.format(widget.recipeData['datePosted'].toDate()),
                  style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}

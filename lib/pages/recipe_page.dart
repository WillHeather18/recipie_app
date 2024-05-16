import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecipeDetailsPage extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final String heroTag;

  RecipeDetailsPage({required this.recipeData, required this.heroTag});

  @override
  _RecipeDetailsPageState createState() => _RecipeDetailsPageState();
}

class _RecipeDetailsPageState extends State<RecipeDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var recipeServings;

  @override
  void initState() {
    super.initState();
    recipeServings = widget.recipeData['servings'];
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Duration parseDuration(String str) {
    var parts = str.split(':');
    if (parts.length != 3) {
      throw Exception('Invalid duration string: $str');
    }
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(parts[2].split('.')[0]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: widget.heroTag,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(widget.recipeData['imageURL'],
                        fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.recipeData['title'],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.favorite_outline, color: Colors.red),
                          const SizedBox(width: 4),
                          Text('${widget.recipeData['interactions']['likes']}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Posted ${timeago.format(widget.recipeData['datePosted'].toDate())}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Column(
                        children: [
                          Text(
                            '${widget.recipeData['ingredients'].length}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Ingredients',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        children: [
                          Text(
                            '${(parseDuration(widget.recipeData['prepTime']) + parseDuration(widget.recipeData['cookTime'])).inMinutes.toString()} mins',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Instructions',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Servings: ',
                                style: TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (recipeServings > 1) {
                                    setState(() {
                                      recipeServings = recipeServings - 1;
                                    });
                                  }
                                },
                              ),
                              Text(
                                recipeServings.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    recipeServings = recipeServings + 1;
                                  });
                                },
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount:
                                  widget.recipeData['ingredients'].length,
                              itemBuilder: (context, index) {
                                final ingredient =
                                    widget.recipeData['ingredients'][index];
                                final servingSize = recipeServings;
                                final adjustedQuantity =
                                    int.parse(ingredient['quantity']) *
                                        servingSize.toInt();
                                return ListTile(
                                  title: Text(
                                      '${adjustedQuantity} ${ingredient['measurement']} of ${ingredient['name']}'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Icon(Icons.timer),
                              const SizedBox(width: 8),
                              Text(
                                'Prep Time: ' +
                                    parseDuration(
                                            '${widget.recipeData['prepTime']}')
                                        .inMinutes
                                        .toString() +
                                    ' mins',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.timer),
                              const SizedBox(width: 8),
                              Text(
                                'Cook Time: ' +
                                    parseDuration(
                                            '${widget.recipeData['cookTime']}')
                                        .inMinutes
                                        .toString() +
                                    ' mins',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount:
                                  widget.recipeData['instructions'].length,
                              itemBuilder: (context, index) {
                                final instruction =
                                    widget.recipeData['instructions'][index];
                                return ListTile(
                                  title: Text('${index + 1}. $instruction'),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }
}

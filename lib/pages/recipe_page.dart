import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecipeDetailsPage extends StatelessWidget {
  final Map<String, dynamic> recipeData;
  final String heroTag;

  RecipeDetailsPage({required this.recipeData, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Hero(
                      tag: heroTag,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(recipeData['imageURL'],
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      children: [
                        Text(
                          recipeData['title'],
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'by ${recipeData['author']['username']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Posted ${timeago.format(recipeData['datePosted'].toDate())}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                recipeData['description'],
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Ingredients:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...recipeData['ingredients'].map<Widget>((ingredient) {
              return ListTile(
                title: Text('${ingredient['quantity']} ${ingredient['name']}'),
                subtitle: Text('Measurement: ${ingredient['measurement']}'),
              );
            }).toList(),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Instructions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Stepper(
              physics: const ClampingScrollPhysics(),
              steps: recipeData['instructions'].map<Step>((instruction) {
                return Step(
                  title: Text(instruction),
                  content: const SizedBox
                      .shrink(), // Empty content as the instruction is already in the title
                );
              }).toList(),
              controlsBuilder:
                  (BuildContext context, ControlsDetails controlsDetails) {
                return const SizedBox
                    .shrink(); // Empty widget to remove the continue button
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Posted by ${recipeData['author']['username']} on ${timeago.format(recipeData['datePosted'].toDate())}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeedAdWidget extends StatefulWidget {
  @override
  _AdWidgetState createState() => _AdWidgetState();
}

class _AdWidgetState extends State<FeedAdWidget> {
  static const platform = MethodChannel('com.example.recipie_app/ad');
  String? adTitle;
  String? adDescription;
  String? adImageUrl;
  String? adIconUrl;
  String? adCallToAction;

  @override
  void initState() {
    super.initState();
    _getAdDetails();
  }

  Future<void> _getAdDetails() async {
    try {
      final Map<String, dynamic> adDetails = Map<String, dynamic>.from(
          await platform.invokeMethod('getAdDetails'));
      setState(() {
        adTitle = adDetails['title'];
        adDescription = adDetails['description'];
        adImageUrl = adDetails['imageUrl'];
        adIconUrl = adDetails['iconUrl'];
        adCallToAction = adDetails['callToAction'];
      });
    } on PlatformException catch (e) {
      print("Failed to get ad details: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return adTitle != null
        ? _buildAdWidget()
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildAdWidget() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (adIconUrl != null)
                CircleAvatar(
                  backgroundImage: NetworkImage(adIconUrl!),
                ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  adTitle ??
                      'Test_Ad', // Replace with actual username if needed
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text(
                  adCallToAction ?? 'Follow',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          if (adImageUrl != null)
            Image.network(
              adImageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          const SizedBox(height: 8.0),
          const Text(
            'Posted 5 Hours Ago', // Replace with actual timestamp if needed
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8.0),
          const Row(
            children: [
              Icon(Icons.favorite_border),
              SizedBox(width: 8.0),
              Icon(Icons.comment_outlined),
              SizedBox(width: 8.0),
              Icon(Icons.bookmark_border),
            ],
          ),
        ],
      ),
    );
  }
}

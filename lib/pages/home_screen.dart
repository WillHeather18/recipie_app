import 'package:flutter/material.dart';
import 'package:recipie_app/pages/profile_page.dart';
import 'package:recipie_app/widgets/add_recipe.dart';
import '../pages/recipe_feed.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _clickedCentreFAB = false;

  static final List<Widget> _widgetOptions = <Widget>[
    FeedPage(),
    const Text('Search Page', textAlign: TextAlign.center),
    const Text('Notifications', textAlign: TextAlign.center),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
        _clickedCentreFAB = false;
      });
    }
  }

  void _onCentreFABTapped() {
    if (mounted) {
      setState(() {
        _clickedCentreFAB = !_clickedCentreFAB;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height:
                  _clickedCentreFAB ? MediaQuery.of(context).size.height : 10.0,
              width:
                  _clickedCentreFAB ? MediaQuery.of(context).size.height : 10.0,
              child: AddRecipe(
                clickedCentreFAB: _clickedCentreFAB,
                updateClickedCentreFAB: _onCentreFABTapped,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (mounted) {
            setState(() {
              _clickedCentreFAB = !_clickedCentreFAB;
            });
          }
        },
        shape: const CircleBorder(),
        tooltip: "Centre FAB",
        elevation: 4.0,
        child: Container(
          margin: const EdgeInsets.all(15.0),
          child: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        child: Container(
          margin: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  _onItemTapped(0);
                },
                iconSize: 27.0,
                icon: Icon(
                  Icons.home,
                  color: _selectedIndex == 0
                      ? Colors.blue.shade900
                      : Colors.grey.shade400,
                ),
              ),
              IconButton(
                onPressed: () {
                  _onItemTapped(1);
                },
                iconSize: 27.0,
                icon: Icon(
                  Icons.search,
                  color: _selectedIndex == 1
                      ? Colors.blue.shade900
                      : Colors.grey.shade400,
                ),
              ),
              const SizedBox(
                width: 50.0,
              ),
              IconButton(
                onPressed: () {
                  _onItemTapped(2);
                },
                iconSize: 27.0,
                icon: Icon(
                  Icons.notifications,
                  color: _selectedIndex == 2
                      ? Colors.blue.shade900
                      : Colors.grey.shade400,
                ),
              ),
              IconButton(
                onPressed: () {
                  _onItemTapped(3);
                },
                iconSize: 27.0,
                icon: Icon(
                  Icons.account_circle,
                  color: _selectedIndex == 3
                      ? Colors.blue.shade900
                      : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

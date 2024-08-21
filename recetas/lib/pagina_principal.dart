import 'package:flutter/material.dart';
import 'package:recetas/comidas.dart';
import 'package:recetas/desayunos.dart';
import 'package:recetas/postres.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final _pages = [
    DesayunosPage(),
    ComidasPage(),
    PostresPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recetas'),
      
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.star),
            onPressed: () {
              Navigator.pushNamed(context, '/favoritos');
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/configuracion');
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        },
        items:  [
          BottomNavigationBarItem(
            icon:Image.asset('assets/images/desayuno.png',width: 50, height: 50),
            label: 'Desayunos',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/comida.png',width: 50, height: 50),
            label: 'Comidas',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/postre.png',width: 50, height: 50),
            label: 'Postres',
          ),
        ],
      ),
    );
  }

  PageController _pageController = PageController();
}
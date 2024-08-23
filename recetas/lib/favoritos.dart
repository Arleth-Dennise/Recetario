import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recetas/comidas.dart';
import 'package:recetas/desayunos.dart';
import 'package:recetas/postres.dart';


// Definición de las páginas
class DesayunosfavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Desayunos Favoritos'),
      ),
      body: Center(
        child: FavoritosDesayuno_Page(),
      ),

    );
  }
}



class ComidasfavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comidas Favoritas'),
      ),
      body: Center(
        child: FavoritosComida_Page(),
      ),
    );
  }
}

class PostresfavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Postres Favoritos'),
      ),
      body: Center(
        child: FavoritosComida_Page(),
      ),
    );
  }
}

// Página Favoritos con navegación
class FavoritosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Botón para Desayunos Favoritos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: SizedBox(
              width: double.infinity, // Hace que el botón ocupe todo el ancho disponible
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DesayunosfavPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 7, 40, 67), // Color del texto
                  backgroundColor: const Color.fromARGB(255, 225, 225, 225), // Color de fondo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Bordes redondeados
                  ),
                  minimumSize: Size.fromHeight(80), // Ajusta la altura del botón
                ),
                child: Text('Desayunos Favoritos'),
              ),
            ),
          ),
          SizedBox(height: 30), // Espaciado entre botones
          // Botón para Comidas Favoritas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: SizedBox(
              width: double.infinity, // Hace que el botón ocupe todo el ancho disponible
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ComidasfavPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 3, 40, 4), // Color del texto
                  backgroundColor: const Color.fromARGB(255, 225, 225, 225), // Color de fondo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Bordes redondeados
                  ),
                  minimumSize: Size.fromHeight(80), // Ajusta la altura del botón
                ),
                child: Text('Comidas Favoritas'),
              ),
            ),
          ),
          SizedBox(height: 30), // Espaciado entre botones
          // Botón para Postres Favoritos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: SizedBox(
              width: double.infinity, // Hace que el botón ocupe todo el ancho disponible
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostresfavPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 77, 47, 3), // Color del texto
                  backgroundColor: const Color.fromARGB(255, 225, 225, 225), // Color de fondo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Bordes redondeados
                  ),
                  minimumSize: Size.fromHeight(80), // Ajusta la altura del botón
                ),
                child: Text('Postres Favoritos'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritosDesayuno_Page extends StatefulWidget {
  @override
  _FavoritosDesayuno_PageState createState() => _FavoritosDesayuno_PageState();
}

class _FavoritosDesayuno_PageState extends State<FavoritosDesayuno_Page> {
  final List<Desayuno> _favoritos = [];

  @override
  void initState() {
    super.initState();
    _loadFavoritosFromFirestore();
  }

  Future<void> _loadFavoritosFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('favoritos')
        .doc(user.uid)
        .collection('desayunos')
        .get()
        .then((querySnapshot) {
      setState(() {
        _favoritos.clear();
        for (var doc in querySnapshot.docs) {
          _favoritos.add(Desayuno(
            titulo: doc['titulo'],
            ingredientes: doc['ingredientes'],
            preparacion: doc['preparacion'],
            imagenUrl: doc['imagenUrl'], userId: '',
          ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _favoritos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showDesayunoDetails(context, _favoritos[index]);
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _favoritos[index].imagenUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            _favoritos[index].imagenUrl!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        )
                      : Icon(Icons.breakfast_dining, size: 50),
                  SizedBox(height: 10),
                  Text(
                    _favoritos[index].titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


}
void _showDesayunoDetails(BuildContext context, Desayuno desayuno) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: desayuno.imagenUrl != null
                    ? CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(desayuno.imagenUrl!),
                      )
                    : Icon(Icons.breakfast_dining, size: 80),
              ),
              SizedBox(height: 20),
              Text(
                desayuno.titulo,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Ingredientes:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(desayuno.ingredientes),
              SizedBox(height: 10),
              Text(
                'Preparación:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(desayuno.preparacion),
            ],
          ),
        ),
      );
    },
  );
}

class FavoritosComida_Page extends StatefulWidget {
  @override
  _FavoritosComida_PageState createState() => _FavoritosComida_PageState();
}

class _FavoritosComida_PageState extends State<FavoritosComida_Page> {
  final List<Comida> _favoritos = [];

  @override
  void initState() {
    super.initState();
    _loadFavoritosFromFirestore();
  }

  Future<void> _loadFavoritosFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('favoritos')
        .doc(user.uid)
        .collection('Comida')
        .get()
        .then((querySnapshot) {
      setState(() {
        _favoritos.clear();
        for (var doc in querySnapshot.docs) {
          _favoritos.add(Comida(
            titulo: doc['titulo'],
            ingredientes: doc['ingredientes'],
            preparacion: doc['preparacion'],
            imagenUrl: doc['imagenUrl'], userId: '',
          ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _favoritos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showComidaDetails(context, _favoritos[index]);
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _favoritos[index].imagenUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            _favoritos[index].imagenUrl!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        )
                      : Icon(Icons.breakfast_dining, size: 50),
                  SizedBox(height: 10),
                  Text(
                    _favoritos[index].titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


}
void _showComidaDetails(BuildContext context, Comida comida) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: comida.imagenUrl != null
                    ? CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(comida.imagenUrl!),
                      )
                    : Icon(Icons.breakfast_dining, size: 80),
              ),
              SizedBox(height: 20),
              Text(
                comida.titulo,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Ingredientes:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(comida.ingredientes),
              SizedBox(height: 10),
              Text(
                'Preparación:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(comida.preparacion),
            ],
          ),
        ),
      );
    },
  );
}


class FavoritosPostre_Page extends StatefulWidget {
  @override
  _FavoritosPostre_PageState createState() => _FavoritosPostre_PageState();
}

class _FavoritosPostre_PageState extends State<FavoritosPostre_Page> {
  final List<Postre> _favoritos = [];

  @override
  void initState() {
    super.initState();
    _loadFavoritosFromFirestore();
  }

  Future<void> _loadFavoritosFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('favoritos')
        .doc(user.uid)
        .collection('desayunos')
        .get()
        .then((querySnapshot) {
      setState(() {
        _favoritos.clear();
        for (var doc in querySnapshot.docs) {
          _favoritos.add(Postre(

            titulo: doc['titulo'],
            ingredientes: doc['ingredientes'],
            preparacion: doc['preparacion'],
            imagenUrl: doc['imagenUrl'], userId: ''
          ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoritos'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _favoritos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showPostreDetails(context, _favoritos[index]);
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _favoritos[index].imagenUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            _favoritos[index].imagenUrl!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        )
                      : Icon(Icons.breakfast_dining, size: 50),
                  SizedBox(height: 10),
                  Text(
                    _favoritos[index].titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


}
void _showPostreDetails(BuildContext context, Postre postre) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: postre.imagenUrl != null
                    ? CircleAvatar(
                        radius: 80,
                        backgroundImage: NetworkImage(postre.imagenUrl!),
                      )
                    : Icon(Icons.breakfast_dining, size: 80),
              ),
              SizedBox(height: 20),
              Text(
                postre.titulo,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Ingredientes:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(postre.ingredientes),
              SizedBox(height: 10),
              Text(
                'Preparación:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(postre.preparacion),
            ],
          ),
        ),
      );
    },
  );
}
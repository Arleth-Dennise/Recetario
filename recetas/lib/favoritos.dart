import 'package:flutter/material.dart';

// Definición de las páginas
class DesayunosfavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Desayunos Favoritos'),
      ),
      body: Center(
        child: Text('Página de Desayunos'),
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
        child: Text('Página de Comidas'),
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
        child: Text('Página de Postres'),
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

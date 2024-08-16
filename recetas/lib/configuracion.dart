import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConfiguracionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    String _displayName = user != null ? user.displayName ?? '' : '';
    String _email = user != null ? user.email ?? '' : '';
    String retroUrl = 'https://avatars.githubusercontent.com/${_email}?size=50';

    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(retroUrl),
              ),
              SizedBox(height: 20),
              Text(
                'Nombre: $_displayName',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Correo: $_email',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/inicio_sesion');
                },
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
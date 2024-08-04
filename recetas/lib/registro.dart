import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistroPage extends StatefulWidget {
  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscureText = true;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 241, 246),
     // appBar: AppBar(
       // title: const Text('Registro'),
        //backgroundColor: Color.fromARGB(255, 246, 245, 240),
        //foregroundColor: Color.fromARGB(255, 97, 22, 108),
      //),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 40),
                Image.asset('assets/images/imagen2.png', height: 200),
                SizedBox(height: 10),
                _CustomTextFormField(
                  controller: _nameController,
                  prefixIcon: Icons.person,
                  labelText: 'Nombre',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Ingrese su nombre';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                _CustomTextFormField(
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  labelText: 'Correo',
                  validator: (value) {
                    if (value!.isEmpty ||!value.contains('@')) {
                      return 'Ingrese un correo valido';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),
                _CustomTextFormField(
                  controller: _passwordController,
                  prefixIcon: null,
                  suffixIcon: _obscureText? Icons.visibility_off : Icons.visibility,
                  labelText: 'Contraseña',
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Ingrese su contraseña';
                    }
                    return null;
                  },
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscureText =!_obscureText;
                    });
                  },
                ),
                SizedBox(height: 10),
                _CustomTextFormField(
                  controller: _confirmPasswordController,
                  prefixIcon: null,
                  suffixIcon: _obscureText? Icons.visibility_off : Icons.visibility,
                  labelText: 'Confirmar contraseña',
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value!.isEmpty || value!= _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscureText =!_obscureText;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await FirebaseAuth.instance
                           .createUserWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            )
                           .then((value) {
                          // Update user profile with name
                          value.user!.updateProfile(displayName: _nameController.text);
                          Navigator.pushReplacementNamed(
                            context,
                            '/inicio',
                            arguments: _emailController.text,
                          );
                        });
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'email-already-in-use') {
                          setState(() {
                            _errorMessage = 'El correo electrónico ya está en uso.';
                          });
                        } else if (e.code == 'weak-password') {
                          setState(() {
                            _errorMessage = 'La contraseña es demasiado débil.';
                          });
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 39, 34, 2),
                    backgroundColor: Color.fromARGB(255, 255, 137, 180),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Registrarse'),
                ),
                Text(_errorMessage, style: TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/inicio_sesion');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, 59, 56, 10),
                    textStyle: TextStyle(
                      fontSize: 18,
                     ),
                  ),
                  child: Text('¿Ya tienes una cuenta? Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String labelText;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final VoidCallback? onSuffixIconPressed;

  _CustomTextFormField({
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    required this.labelText,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.onSuffixIconPressed,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<_CustomTextFormField> {

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 20) : null,
        suffixIcon: widget.suffixIcon!= null
           ? IconButton(
                icon: Icon(widget.suffixIcon, size: 20),
                onPressed: widget.onSuffixIconPressed,
              )
            : null,
        labelText: widget.labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
      obscureText: widget.obscureText,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _isLoading = false;
  bool _showValidationErrors = false;

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'\d').hasMatch(_passwordController.text);
  bool get _hasSymbol =>
      RegExp(r'[^A-Za-z0-9]').hasMatch(_passwordController.text);

  bool get _isPasswordValid =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSymbol;

  String? get _emailError {
    final email = _emailController.text.trim();
    if (email.isEmpty) return 'El correo es obligatorio';
    if (!email.endsWith('@tecdesoftware.edu.mx')) {
      return 'Usa tu correo @tecdesoftware.edu.mx';
    }
    return null;
  }

  String? get _passwordError {
    if (_passwordController.text.isEmpty) return 'La contraseña es obligatoria';
    if (!_isPasswordValid) return 'La contraseña no cumple las reglas';
    return null;
  }

  String? get _confirmPasswordError {
    if (_confirmPasswordController.text.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  void _refreshValidation() {
    if (_showValidationErrors) {
      setState(() {});
    }
  }

  Future<void> _onSignUp() async {
    setState(() {
      _showValidationErrors = true;
    });

    if (_emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada, ahora inicia sesión')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      final message = switch (e.code) {
        'email-already-in-use' => 'Este correo ya está registrado.',
        'weak-password' => 'La contraseña es demasiado débil.',
        'invalid-email' => 'El correo no es válido.',
        _ => 'No fue posible crear la cuenta.',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fue posible crear la cuenta.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _passwordRule(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isValid ? Colors.green : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: isValid ? Colors.green : Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _refreshValidation(),
                decoration: InputDecoration(
                  labelText: 'Correo institucional',
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                  errorText: _showValidationErrors ? _emailError : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _isPasswordObscure,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  errorText: _showValidationErrors ? _passwordError : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscure
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordObscure = !_isPasswordObscure;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('La contraseña debe contener:'),
              const SizedBox(height: 8),
              _passwordRule('Mínimo 8 caracteres', _hasMinLength),
              _passwordRule('Una letra mayúscula', _hasUppercase),
              _passwordRule('Una letra minúscula', _hasLowercase),
              _passwordRule('Un número', _hasNumber),
              _passwordRule('Un símbolo', _hasSymbol),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _isConfirmPasswordObscure,
                onChanged: (_) => _refreshValidation(),
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  errorText:
                      _showValidationErrors ? _confirmPasswordError : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordObscure
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordObscure =
                            !_isConfirmPasswordObscure;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _onSignUp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

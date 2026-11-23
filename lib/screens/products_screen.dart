import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  // Para web/iOS usa localhost; para celular físico, la IP local de la PC.
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/pets'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Error al cargar productos de la API');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes de la Veterinaria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final pet = products[index] as Map<String, dynamic>;
              final breed = pet['breed']?.toString() ?? 'Sin raza';
              final age = pet['age']?.toString() ?? 'Sin edad';
              final owner = pet['owner'] as Map<String, dynamic>?;
              final ownerName = owner?['name']?.toString() ?? 'Sin dueño';

              return ListTile(
                leading: const Icon(Icons.pets),
                title: Text(pet['name'].toString()),
                subtitle: Text(
                  '${pet['species']} · $breed · $age años\nDueño: $ownerName',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

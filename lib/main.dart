import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
        ),
      ),
      home: const DogImageApp(),
    );
  }
}

class DogImageApp extends StatefulWidget {
  const DogImageApp({super.key});

  @override
  State<DogImageApp> createState() => _DogImageAppState();
}

class _DogImageAppState extends State<DogImageApp> {
  String? _selectedBreed;
  String? _imageUrl;
  bool _isLoading = false;
  final List<String> _breeds = [];

  @override
  void initState() {
    super.initState();
    _fetchBreeds();
  }

  Future<void> _fetchBreeds() async {
    final response =
        await http.get(Uri.parse("https://dog.ceo/api/breeds/list/all"));
    if (response.statusCode == 200) {
      final Map<String, dynamic> breedsJson =
          json.decode(response.body)["message"];
      setState(() {
        _breeds.addAll(breedsJson.keys
            .map((breed) => breed[0].toUpperCase() + breed.substring(1))
            .toList());
      });
    }
  }

  Future<void> _fetchRandomDogImage() async {
    setState(() {
      _isLoading = true;
    });
    final breed = _selectedBreed?.toLowerCase() ?? "random";
    final response = await http.get(Uri.parse(breed == "random"
        ? "https://dog.ceo/api/breeds/image/random"
        : "https://dog.ceo/api/breed/$breed/images/random"));
    if (response.statusCode == 200) {
      setState(() {
        _imageUrl = json.decode(response.body)["message"];
        _isLoading = false;
      });
    }
  }

  void _resetBreed() {
    setState(() {
      _selectedBreed = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4.0,
        title: const Text("Dog Image App"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 32),
                if (_breeds.isNotEmpty)
                  DropdownButton<String>(
                    value: _selectedBreed,
                    hint: const Text("Bitte wähle eine Hunderasse aus"),
                    onChanged: (value) {
                      setState(() {
                        _selectedBreed = value;
                      });
                    },
                    items: [
                      const DropdownMenuItem(
                        value: "random",
                        child: Text("Zufällige Rasse"),
                      ),
                      ..._breeds.map((breed) {
                        return DropdownMenuItem(
                          value: breed,
                          child: Text(breed),
                        );
                      }),
                    ],
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 32),
            child: DogButton(
              onPressed: _fetchRandomDogImage,
              text: _selectedBreed != null
                  ? "Hundebild anzeigen"
                  : "Zufälliges Hundebild anzeigen",
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 32),
            child: DogButton(
              onPressed: _resetBreed,
              text: "Hunderasse zurücksetzen",
            ),
          ),
          //const FancyDogButton(onPressed: null, text: "Hundebild anzeigen"),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _imageUrl != null
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.network(
                                _imageUrl!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : const Text("Bitte wähle einen Hund aus"),
            ),
          )
        ],
      ),
    );
  }
}

class FancyDogButton extends StatelessWidget {
  const FancyDogButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  final VoidCallback? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: InkWell(
        onTap: onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(color: Colors.brown, "assets/images/dackel.png"),
            Positioned(
              top: 95,
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DogButton extends StatelessWidget {
  const DogButton({super.key, required this.onPressed, required this.text});

  final VoidCallback? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

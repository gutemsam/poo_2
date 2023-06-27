import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CardListScreen(),
                  ),
                );
              },
              child: const Text('Pesquisar Cartas'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllCardsScreen(),
                  ),
                );
              },
              child: const Text('Todas as cartas'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                List<dynamic> deck = await _buildRandomDeck();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeckScreen(deck: deck),
                  ),
                );
              },
              child: const Text('Montar Deck'),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<dynamic>> _buildRandomDeck() async {
    final response = await http.get(Uri.parse('https://db.ygoprodeck.com/api/v7/cardinfo.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final cards = data['data'];
      final random = Random();
      List<dynamic> deck = [];

      for (int i = 0; i < 60; i++) {
        int randomIndex = random.nextInt(cards.length);
        deck.add(cards[randomIndex]);
      }

      return deck;
    } else {
      throw Exception('Failed to load card data');
    }
  }
}

class CardListScreen extends StatefulWidget {
  const CardListScreen({Key? key}) : super(key: key);

  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _searchResults = [];

  Future<void> _searchCards(String query) async {
    final response = await http.get(Uri.parse('https://db.ygoprodeck.com/api/v7/cardinfo.php?fname=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _searchResults = data['data'];
      });
    } else {
      // Error handling
      print('Error: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar Carta'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchCards(value);
              },
              decoration: const InputDecoration(
                labelText: 'Digite o nome da carta',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final card = _searchResults[index];
                return ListTile(
                  title: Text(card['name'] ?? ''),
                  subtitle: Text(card['type'] ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardDetailScreen(card: card),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AllCardsScreen extends StatefulWidget {
  const AllCardsScreen({Key? key}) : super(key: key);

  @override
  _AllCardsScreenState createState() => _AllCardsScreenState();
}

class _AllCardsScreenState extends State<AllCardsScreen> {
  List<dynamic> _allCards = [];

  @override
  void initState() {
    super.initState();
    _getAllCards();
  }

  Future<void> _getAllCards() async {
    final response = await http.get(Uri.parse('https://db.ygoprodeck.com/api/v7/cardinfo.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _allCards = data['data'];
      });
    } else {
      // Error handling
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as cartas'),
      ),
      body: ListView.builder(
        itemCount: _allCards.length,
        itemBuilder: (context, index) {
          final card = _allCards[index];
          return ListTile(
            title: Text(card['name'] ?? ''),
            subtitle: Text(card['type'] ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(card: card),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CardDetailScreen extends StatelessWidget {
  final dynamic card;

  const CardDetailScreen({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da carta'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card['name'] ?? '',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              card['desc'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class DeckScreen extends StatelessWidget {
  final List<dynamic> deck;

  const DeckScreen({Key? key, required this.deck}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck sorteado'),
      ),
      body: ListView.builder(
        itemCount: deck.length,
        itemBuilder: (context, index) {
          final card = deck[index];
          return ListTile(
            title: Text(card['name'] ?? ''),
            subtitle: Text(card['type'] ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(card: card),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

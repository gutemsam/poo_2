import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:translator/translator.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(MyApp());
}

// Aplicativo principal
////////////////
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card App', // Define o título da aplicação
      theme: ThemeData(
        primarySwatch: Colors.brown, // Define a cor primária do tema
      ),
      home: SplashScreen(), // Define a tela inicial como SplashScreen
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(
          seconds: 3), // Define a duração da animação como 3 segundos
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1)
        .animate(_animationController); // Cria uma animação de rotação
    _animationController.repeat(); // Repete a animação continuamente
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 3)); // Aguarda 3 segundos
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(), // Navega para a tela HomeScreen
      ),
    );
  }

  @override
  void dispose() {
    _animationController
        .dispose(); // Libera os recursos do controlador de animação
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF563021), // Define a cor de fundo da tela
      body: Center(
        child: Container(
          width: 250, // Largura da carta
          height: 350, // Altura da carta
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD2691E),
                Color(0xFF8B4513),
                Color(0xFFA0522D),
                Color(0xFFCD853F),
              ], // Define uma gradiente de cores para o fundo da carta
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(
                16), // Define um raio de borda circular para a carta
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: RotationTransition(
                  turns: _rotationAnimation, // Aplica a animação de rotação
                  child: Container(
                    alignment: Alignment.center,
                    width: 150, // Largura da figura oval
                    height: 200, // Altura da figura oval
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Define a forma como círculo
                      color: Colors.black, // Define a cor como preto
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'Card App', // Exibe o texto "Card App" no centro da carta
                    style: TextStyle(
                      fontSize: 24, // Define o tamanho da fonte como 24
                      fontWeight: FontWeight
                          .bold, // Define o peso da fonte como negrito
                      color: Colors.white, // Define a cor do texto como branco
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
///////////////

// Tela inicial
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
              child: const Text('Buscar Cartas'),
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
              child: const Text('Todas as Cartas'),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DevelopersScreen(),
                  ),
                );
              },
              child: const Text('Desenvolvedores'),
            ),
          ],
        ),
      ),
    );
  }

  // Função para construir um deck aleatório
  Future<List<dynamic>> _buildRandomDeck() async {
    final response = await http
        .get(Uri.parse('https://db.ygoprodeck.com/api/v7/cardinfo.php'));
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

// Tela de lista de cartas
class CardListScreen extends StatefulWidget {
  const CardListScreen({Key? key}) : super(key: key);

  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _searchResults = [];

  // Função para buscar cartas com base em um query de pesquisa
  Future<void> _searchCards(String query) async {
    final response = await http.get(Uri.parse(
        'https://db.ygoprodeck.com/api/v7/cardinfo.php?fname=$query'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _searchResults = data['data'];
      });
    } else {
      // Tratamento de erro
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
        title: const Text('Buscar Cartas'),
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
                  leading: CachedNetworkImage(
                    imageUrl: card['card_images'][0]['image_url'],
                    width: 60,
                    height: 90,
                  ),
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

// Tela de todas as cartas
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

  // Função para obter todas as cartas
  Future<void> _getAllCards() async {
    final response = await http
        .get(Uri.parse('https://db.ygoprodeck.com/api/v7/cardinfo.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _allCards = data['data'];
      });
    } else {
      // Tratamento de erro
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as Cartas'),
      ),
      body: ListView.builder(
        itemCount: _allCards.length,
        itemBuilder: (context, index) {
          final card = _allCards[index];
          return ListTile(
            title: Text(card['name'] ?? ''),
            subtitle: Text(card['type'] ?? ''),
            leading: CachedNetworkImage(
              imageUrl: card['card_images'][0]['image_url'],
              width: 60,
              height: 90,
            ),
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

// Tela de detalhes da carta
class CardDetailScreen extends StatefulWidget {
  final dynamic card;

  const CardDetailScreen({Key? key, required this.card}) : super(key: key);

  @override
  _CardDetailScreenState createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  String _translatedDescription = '';

  @override
  void initState() {
    super.initState();
    _translateDescription();
  }

  // Função para traduzir a descrição da carta para o idioma atual do dispositivo
  Future<void> _translateDescription() async {
    final translator = GoogleTranslator();
    final description = widget.card['desc'] ?? '';
    final translation =
        await translator.translate(description, from: 'en', to: 'pt');
    setState(() {
      _translatedDescription = translation.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    return Scaffold(
      appBar: AppBar(
        title: Text(card['name'] ?? ''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: card['card_images'][0]['image_url'],
              width: 180,
              height: 270,
            ),
            const SizedBox(height: 16),
            Text(
              'Tipo: ${card['type']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Atributo: ${card['attribute']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Nível: ${card['level']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Ataque: ${card['atk']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Defesa: ${card['def']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Descrição: $_translatedDescription',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela do deck
class DeckScreen extends StatelessWidget {
  final List<dynamic> deck;

  const DeckScreen({Key? key, required this.deck}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Aleatório'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: deck.length,
        itemBuilder: (context, index) {
          final card = deck[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(card: card),
                ),
              );
            },
            child: CachedNetworkImage(
              imageUrl: card['card_images'][0]['image_url'],
              width: 180,
              height: 270,
            ),
          );
        },
      ),
    );
  }
}

// Tela de desenvolvedores
class DevelopersScreen extends StatelessWidget {
  const DevelopersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desenvolvedores'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('SAMUEL GUTEMBERG PEREIRA'),
            subtitle: const Text('Instagram: @sam.gutemberg06'),
            onTap: () {
              // Abre o link do Instagram do Samuel Gutemberg
            },
          ),
          ListTile(
            title: const Text('CINTIA CAMPOS DE QUEIROZ'),
            subtitle: const Text('Instagram: @cqcintia'),
            onTap: () {
              // Abre o link do Instagram da Cintia Campos de Queiroz
            },
          ),
          ListTile(
            title: const Text('BIANCA LAISE MEDEIROS CASSIANO'),
            subtitle: const Text('Instagram: @biancamdros'),
            onTap: () {
              // Abre o link do Instagram da Bianca Laise Medeiros Cassiano
            },
          ),
        ],
      ),
    );
  }
}

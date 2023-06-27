import 'package:http/http.dart' as http; // Importa o pacote http para realizar requisições HTTP
import 'dart:convert'; // Importa o pacote convert para lidar com codificação e decodificação JSON
import 'dart:math'; // Importa o pacote math para gerar números aleatórios
import 'package:flutter/material.dart'; // Importa o pacote flutter/material que contém os widgets do Flutter

void main() {
  runApp(MyApp()); // Inicia a aplicação Flutter
}

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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3), // Define a duração da animação como 3 segundos
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController); // Cria uma animação de rotação
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
    _animationController.dispose(); // Libera os recursos do controlador de animação
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B4513), // Define a cor de fundo da tela
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
            borderRadius: BorderRadius.circular(16), // Define um raio de borda circular para a carta
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
                      fontWeight: FontWeight.bold, // Define o peso da fonte como negrito
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card App'), // Define o título da barra de aplicativos
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
                    builder: (context) => CardListScreen(), // Navega para a tela CardListScreen
                  ),
                );
              },
              child: const Text('Pesquisar Cartas'), // Exibe o texto "Pesquisar Cartas" no botão
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllCardsScreen(), // Navega para a tela AllCardsScreen
                  ),
                );
              },
              child: const Text('Todas as cartas'), // Exibe o texto "Todas as cartas" no botão
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                List<dynamic> deck = await _buildRandomDeck(); // Monta um deck aleatório
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeckScreen(deck: deck), // Navega para a tela DeckScreen com o deck montado
                  ),
                );
              },
              child: const Text('Montar Deck'), // Exibe o texto "Montar Deck" no botão
            ),
          ],
        ),
      ),
    );
  }

  Future<List<dynamic>> _buildRandomDeck() async {
    final response = await http.get(Uri.parse('https://db.ygoprodeck.com/api/v7/cardinfo.php')); // Faz uma requisição para obter informações das cartas
    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Decodifica os dados da resposta em formato JSON
      final cards = data['data'];
      final random = Random();
      List<dynamic> deck = [];

      for (int i = 0; i < 60; i++) {
        int randomIndex = random.nextInt(cards.length);
        deck.add(cards[randomIndex]); // Adiciona uma carta aleatória ao deck
      }

      return deck; // Retorna o deck montado
    } else {
      throw Exception('Failed to load card data'); // Lança uma exceção em caso de falha na carga dos dados das cartas
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
    final response = await http.get(Uri.parse('https://db.ygoprodeck.com/api/v7/cardinfo.php?fname=$query')); // Faz uma requisição para pesquisar cartas com base no nome fornecido
    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Decodifica os dados da resposta em formato JSON
      setState(() {
        _searchResults = data['data']; // Atualiza a lista de resultados de pesquisa
      });
    } else {
      // Error handling
      print('Error: ${response.statusCode}'); // Exibe o código de erro em caso de falha na requisição
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
        title: const Text('Pesquisar Carta'), // Define o título da barra de aplicativos
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchCards(value); // Realiza a pesquisa de cartas ao digitar no campo de texto
              },
              decoration: const InputDecoration(
                labelText: 'Digite o nome da carta',
                suffixIcon: Icon(Icons.search), // Ícone de pesquisa no campo de texto
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final card = _searchResults[index];
                return ListTile(
                  title: Text(card['name'] ?? ''), // Exibe o nome da carta
                  subtitle: Text(card['type'] ?? ''), // Exibe o tipo da carta
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardDetailScreen(card: card), // Navega para a tela de detalhes da carta
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
    _getAllCards(); // Obtém todas as cartas
  }

  Future<void> _getAllCards() async {
    final response = await http.get(Uri.parse('https://db.ygoprodeck.com/api/v7/cardinfo.php')); // Faz uma requisição para obter todas as cartas
    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Decodifica os dados da resposta em formato JSON
      setState(() {
        _allCards = data['data']; // Atualiza a lista de todas as cartas
      });
    } else {
      // Error handling
      print('Error: ${response.statusCode}'); // Exibe o código de erro em caso de falha na requisição
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as cartas'), // Define o título da barra de aplicativos
      ),
      body: ListView.builder(
        itemCount: _allCards.length,
        itemBuilder: (context, index) {
          final card = _allCards[index];
          return ListTile(
            title: Text(card['name'] ?? ''), // Exibe o nome da carta
            subtitle: Text(card['type'] ?? ''), // Exibe o tipo da carta
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(card: card), // Navega para a tela de detalhes da carta
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
        title: Text(card['name'] ?? ''), // Exibe o nome da carta na barra de aplicativos
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${card['type'] ?? ''}'), // Exibe o tipo da carta
            const SizedBox(height: 16),
            Text('Descrição: ${card['desc'] ?? ''}'), // Exibe a descrição da carta
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
        title: const Text('Deck'), // Define o título da barra de aplicativos
      ),
      body: ListView.builder(
        itemCount: deck.length,
        itemBuilder: (context, index) {
          final card = deck[index];
          return ListTile(
            title: Text(card['name'] ?? ''), // Exibe o nome da carta
            subtitle: Text(card['type'] ?? ''), // Exibe o tipo da carta
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardDetailScreen(card: card), // Navega para a tela de detalhes da carta
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:solidart/solidart.dart';

// Enumeração para representar o estado da tabela
enum TableStatus { idle, loading, ready, error }

// Classe responsável por carregar os dados e notificar as mudanças de estado da tabela
class DataService {
  final ValueNotifier<Map<String, dynamic>> tableStateNotifier =
      ValueNotifier({
    'status': TableStatus.idle,
    'dataObjects': [],
  });

  // Função para carregar os dados com base no índice fornecido
  void carregar(index) {
    final funcoes = [carregarComidas];
    tableStateNotifier.value = {
      'status': TableStatus.loading,
      'dataObjects': [],
    };
    funcoes[index]();
  }

  // Função para carregar as refeições de frango da API
  void carregarComidas() {
    var mealsUri = Uri(
      scheme: 'https',
      host: 'www.themealdb.com',
      path: 'api/json/v1/1/search.php',
      queryParameters: {'s': 'chicken'}, // Parâmetro de pesquisa de exemplo para refeições de frango
    );

    http.get(mealsUri).then((response) {
      var mealsJson = jsonDecode(response.body);
      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': mealsJson['meals'],
        'propertyNames': ["strMeal", "strCategory", "strArea"], // Nomes das propriedades a serem exibidas na lista
        'columnNames': ["Name", "Category", "Area"], // Nomes das colunas da tabela
      };
    });
  }
}

// Instância do DataService para gerenciar os dados da tabela
final dataService = DataService();

void main() {
  Solidart.init();
  MyApp app = MyApp();
  runApp(app);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Dicas"),
        ),
        body: ValueListenableBuilder(
          valueListenable: dataService.tableStateNotifier,
          builder: (_, value, __) {
            switch (value['status']) {
              case TableStatus.idle:
                return Center(child: Text("Toque algum botão, abaixo...")); // Mensagem exibida quando a tabela está inativa
              case TableStatus.loading:
                return Center(child: CircularProgressIndicator()); // Indicador de carregamento exibido enquanto os dados estão sendo carregados
              case TableStatus.ready:
                return ListWidget(
                  jsonObjects: value['dataObjects'],
                  propertyNames: value['propertyNames'],
                ); // Exibe a lista de objetos quando os dados estão prontos
              case TableStatus.error:
                return Text("Lascou"); // Mensagem de erro caso ocorra um erro no carregamento dos dados
            }
            return Text("..."); // Estado de fallback, caso nenhum dos casos anteriores seja correspondido
          },
        ),
        bottomNavigationBar: NewNavBar(itemSelectedCallback: dataService.carregar),
      ),
    );
  }
}

// Widget para exibir a barra de navegação inferior
class NewNavBar extends HookWidget {
  final _itemSelectedCallback;

  NewNavBar({itemSelectedCallback})
      : _itemSelectedCallback = itemSelectedCallback ?? (int) {};

  @override
  Widget build(BuildContext context) {
    var state = useState(0);

    return BottomNavigationBar(
      onTap: (index) {
        state.value = index;
        _itemSelectedCallback(index);
      },
      currentIndex: state.value,
      items: const [
        BottomNavigationBarItem(
          label: "Comidas",
          icon: Icon(Icons.restaurant_menu), // Ícone para o item "Comidas" na barra de navegação
        ),
      ],
    );
  }
}

// Widget para exibir a lista de objetos na tela
class ListWidget extends StatelessWidget {
  final List jsonObjects;
  final List<String> propertyNames;

  ListWidget({this.jsonObjects = const [], this.propertyNames = const ["strMeal", "strCategory", "strArea"]});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(10),
      separatorBuilder: (_, __) => Divider(
        height: 5,
        thickness: 2,
        indent: 10,
        endIndent: 10,
        color: Theme.of(context).primaryColor,
      ),
      itemCount: jsonObjects.length,
      itemBuilder: (_, index) {
        var title = jsonObjects[index][propertyNames[0]]; // Obtém o título do objeto com base na primeira propriedade
        var content = propertyNames.sublist(1).map((prop) => jsonObjects[index][prop]).join(" - "); // Obtém o conteúdo concatenando as propriedades restantes

        return Card(
          shadowColor: Theme.of(context).primaryColor,
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                "$title\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ), // Exibe o título em negrito
              Text(content), // Exibe o conteúdo
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

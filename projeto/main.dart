import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:solidart/solidart.dart';

enum TableStatus { idle, loading, ready, error }

class DataService {
  final ValueNotifier<Map<String, dynamic>> tableStateNotifier =
      ValueNotifier({
    'status': TableStatus.idle,
    'dataObjects': [],
  });

  void carregar(index) {
    final funcoes = [carregarComidas];
    tableStateNotifier.value = {
      'status': TableStatus.loading,
      'dataObjects': [],
    };
    funcoes[index]();
  }

  void carregarComidas() {
    var mealsUri = Uri(
      scheme: 'https',
      host: 'www.themealdb.com',
      path: 'api/json/v1/1/search.php',
      queryParameters: {'s': 'chicken'}, // Example search parameter for chicken meals
    );

    http.get(mealsUri).then((response) {
      var mealsJson = jsonDecode(response.body);
      tableStateNotifier.value = {
        'status': TableStatus.ready,
        'dataObjects': mealsJson['meals'],
        'propertyNames': ["strMeal", "strCategory", "strArea"],
        'columnNames': ["Name", "Category", "Area"],
      };
    });
  }
}

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
                return Center(child: Text("Toque algum botão, abaixo..."));
              case TableStatus.loading:
                return Center(child: CircularProgressIndicator());
              case TableStatus.ready:
                return ListWidget(
                  jsonObjects: value['dataObjects'],
                  propertyNames: value['propertyNames'],
                );
              case TableStatus.error:
                return Text("Lascou");
            }
            return Text("...");
          },
        ),
        bottomNavigationBar: NewNavBar(itemSelectedCallback: dataService.carregar),
      ),
    );
  }
}

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
          icon: Icon(Icons.restaurant_menu),
        ),
      ],
    );
  }
}

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
        var title = jsonObjects[index][propertyNames[0]];
        var content = propertyNames.sublist(1).map((prop) => jsonObjects[index][prop]).join(" - ");

        return Card(
          shadowColor: Theme.of(context).primaryColor,
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                "$title\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(content),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo da abelinha',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black54),
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
      ),
      home: const MyHomePage(title: 'Jogo da abelinha'),
    );
  }
}

TextEditingController controller = TextEditingController(text: "");

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final Map<String, String> letras = {
    '0-1': 'r',
    '-10': 's',
    '-11': 't',
    '01': 'e',
    '10': 'n',
    '1-1': 'o',
  };

  final List<String> listaPalavras = [
    "rato",
    "terno",
    "sono",
    "estar",
    "nota",
    "terra",
    "sena",
    "tornar",
    "asteroide",
    "roteador",
    "astro",
    "seta",
    "norte",
    "seara",
    "arte",
    "santo",
    "resto",
    "roer",
    "estorno",
    "tronco",
    "artesao",
    "serra",
    "setor",
    "senhor",
    "ternura",
    "sertao",
    "restar",
    "naso",
    "treno",
    "rota",
    "toner",
    "sorte",
    "antro",
    "renas",
    "estacao",
    "torre",
    "tarso",
    "erro",
    "arroto",
    "ator",
    "setenta",
    "rente",
    "torso",
    "resta",
    "atear",
    "arto",
    "rente",
    "rosto",
    "ostra"
  ];

  final String letraCentral = "a";

  late List<String> palavrasEncontradas = [];

  void rotacionar() {
    setState(() {
      List<String> valuesList = letras.values.toList();
      valuesList.shuffle();

      int index = 0;
      letras.forEach((key, _) {
        letras[key] = valuesList[index];
        index++;
      });

    });
  }

  void validar() {
    if(palavrasEncontradas.contains(controller.text)) {
      print("PAlAVRA já encontrada!");
    }
    else if(listaPalavras.contains(controller.text)) {
      print("PAlAVRA ENCONTRADA");
      palavrasEncontradas.add(controller.text);
    } else {
      print("PAlAVRA Não está no dicionário");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          fieldText(controller),
          const SizedBox(height: 50),
          Center(
            child: SizedBox(
              width: width * 0.8,
              child: _buildGrid(context, controller)
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.delete, size: 50,),
                onPressed: () => controller.text = "",
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 50,),
                onPressed: rotacionar,
              ),
              IconButton(
                icon: const Icon(Icons.send, size: 50,),
                onPressed: validar,
              ),
            ]
          )
        ],
      ),
    );
  }

  Widget fieldText(TextEditingController controller) {

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: TextField(
          controller: controller,
          readOnly: true,
          textAlign: TextAlign.center,
          showCursor: false,
          enabled: false,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 30,
          ),
        ),
      ),
    );

  }

  Widget _buildGrid(BuildContext context, TextEditingController controller) {
    return InteractiveViewer(
      minScale: 0.1,
      maxScale: 4.0,
      child: HexagonGrid(
        hexType: HexagonType.FLAT,
        depth: 1,
        buildTile: (coordinates) {
          String letra = coordinates.q == 0 && coordinates.r == 0 ? letraCentral
              : letras['${coordinates.q}${coordinates.r}']!;
          return HexagonWidgetBuilder(
            color: coordinates.q == 0 && coordinates.r == 0 ? Colors.yellow.shade800 : Colors.yellow,
                padding: 2.0,
                cornerRadius: 8.0,
            child: Container(
              padding: const EdgeInsets.all(5.0), // Adjust the padding as needed
              child: InkWell(
                onTap: () {
                  controller.text = controller.text + letra;
                },
                highlightColor: Colors.transparent,
                child: Center(
                  child: Text(
                    letra.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }

}
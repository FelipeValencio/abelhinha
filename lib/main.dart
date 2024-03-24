import 'dart:io';

import 'package:abelhinha/palavras_dia.dart';
import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

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

  late final Future futureController;

  late List<String> pangrams;

  final Map<String, String> letras = {
    '0-1': '',
    '-10': '',
    '-11': '',
    '01': '',
    '10': '',
    '1-1': '',
  };

  late List<String> answers;

  late String letraCentral;

  late List<String> palavrasEncontradas = [];

  late int letrasEncontradas = 0;

  Future<int> prepararJogo() async {

    String? letrasDia = await PalavrasDia().getLettersForDay();

    letraCentral = letrasDia![0];

    int i = 1;

    letras.forEach((key, value) {
      letras.update(key, (existingValue) {
        return letrasDia[i];
      });
      i++;
    });

    answers = await readFile("answers-${getCurrentDate()}.txt");
    pangrams = await readFile("pangrams-${getCurrentDate()}.txt");

    return 1;

  }

  @override
  void initState() {
    futureController = prepararJogo();
    super.initState();
  }

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
    if(controller.text.length < 4) {
      print("Palavra muito curta!");
      return;
    }

    if(palavrasEncontradas.contains(controller.text)) {
      print("PAlAVRA já encontrada!");
      return;
    }

    if(answers.contains(controller.text)) {
      print("PAlAVRA ENCONTRADA");
      setState(() {
        palavrasEncontradas.add(controller.text);
        controller.text = "";
      });
      return;
    }

    print("PAlAVRA Não está no dicionário");

  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: futureController,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            print(snapshot.stackTrace);
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                score(),
                fieldText(controller),
                Center(
                  child: SizedBox(
                      width: width * 0.8,
                      child: buildColmeia(context, controller)
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
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
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

  Widget buildColmeia(BuildContext context, TextEditingController controller) {
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

  Widget score() {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                  "0"
              ),
              Text(
                  "${(answers.length * 0.25).floor()}"
              ),
              Text(
                  "${(answers.length * 0.5).floor()}"
              ),
              Text(
                  "${(answers.length * 0.75).floor()}"
              ),
              Text(
                  "${answers.length}"
              ),
            ],
          ),
        ),
        const SizedBox(height: 5,),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: StepProgressIndicator(
            totalSteps: (answers.length / 100000).floor(),
            currentStep: palavrasEncontradas.length,
            size: 20,
            selectedColor: Colors.yellow,
            unselectedColor: Colors.grey,
          ),
        ),
        const SizedBox(height: 10,),
        Center(
          child: Text(
            "Palavras encontradas: ${palavrasEncontradas.length}",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
            ),
          )
        )
      ],
    );
  }

  readFile(String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$fileName');
    return await file.readAsLines();
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
  }

}
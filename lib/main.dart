import 'dart:io';

import 'package:abelhinha/palavras_dia.dart';
import 'package:flutter/cupertino.dart';
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
      debugShowCheckedModeBanner: false,
      color: Colors.amber,
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

  static const double MAX_SCORE_PERC = 0.2;

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

  late int maxScore = 0;

  int currentScore = 0;

  Future<int> prepararJogo() async {

    String? letrasDia = await PalavrasDia().getLettersForDay();

    maxScore = await PalavrasDia().maxScore();

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

    String palavra = controller.text.toLowerCase();

    if(palavra.length < 4) {
      mostrarMensagem("Palavra muito curta");
      return;
    }

    if(palavrasEncontradas.contains(palavra)) {
      mostrarMensagem("Palavra já encontrada!");
      return;
    }

    if(answers.contains(palavra) || pangrams.contains(palavra)) {
      setState(() {
        int pontoGanho = pontoPorPalavra(palavra);
        if(pangrams.contains(palavra)) {
          mostrarMensagem("Pangram!!! +$pontoGanho");
        } else {
          mostrarMensagem("Palavra encontrada! +$pontoGanho");
        }
        palavrasEncontradas.add(palavra);
        currentScore += pontoGanho;
        controller.text = "";
      });
      return;
    }

    mostrarMensagem("Palavra não existe :(");

  }

  int pontoPorPalavra(String word) {
    if (word.length == 4) return 1;
    if (pangrams.contains(word)) return word.length + 7;
    return word.length;
  }

  void mostrarMensagem(String mensagem, {int duracao=1500}) {
    final snackBar = SnackBar(
      content: Text(
        mensagem,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold
        ),
      ),
      duration: Duration(milliseconds: duracao),
      backgroundColor: Colors.yellow,
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.up,
      margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 50,
          right: 50),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
            return Stack(
              children: [
                Column(
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
                ),
                buildListaPalavrasEncontradas(),
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
                  controller.text = controller.text + letra.toUpperCase();
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
              const Text("0"),
              Text(
                  "${(maxScore * MAX_SCORE_PERC  * 1/4).floor()}"
              ),
              Text(
                  "${(maxScore * MAX_SCORE_PERC  / 2).floor()}"
              ),
              Text(
                  "${(maxScore * MAX_SCORE_PERC  * 3/4).floor()}"
              ),
              Text(
                  "${(maxScore * MAX_SCORE_PERC).floor()}"
              ),
            ],
          ),
        ),
        const SizedBox(height: 5,),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: StepProgressIndicator(
            totalSteps: 10,
            currentStep: ((currentScore * 10) / (maxScore * MAX_SCORE_PERC)).floor(),
            size: 20,
            selectedColor: Colors.yellow,
            unselectedColor: Colors.grey,
          ),
        ),
        const SizedBox(height: 10,),
        Center(
          child: Text(
            "Pontuação atual: $currentScore",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
            ),
          )
        )
      ],
    );
  }

  Widget buildListaPalavrasEncontradas() {
    return ExpansionTile(
      title: const Text(
        'Palavras encontradas',
        style: TextStyle(
          color: Colors.amber,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.white,
      iconColor: Colors.amber,
      textColor: Colors.amber,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: GridView.count(
            crossAxisCount: 3, // Two columns
            mainAxisSpacing: 0.0, // Adjust vertical spacing
            crossAxisSpacing: 0.0, // Adjust horizontal spacing
            childAspectRatio: 2.5, // Adjust aspect ratio
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: palavrasEncontradas.map((item) {
              return Text(
                item.toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }


}
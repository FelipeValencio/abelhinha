import 'dart:collection';
import 'dart:io';

import 'package:abelhinha/model/usuario.dart';
import 'package:abelhinha/service/palavras_dia.dart';
import 'package:abelhinha/telas/admin_page.dart';
import 'package:abelhinha/telas/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexagon/hexagon.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../service/database.dart';

class Jogo extends StatefulWidget {

  const Jogo({super.key, required this.usuario});

  final Usuario usuario;

  @override
  State<Jogo> createState() => _JogoState(usuario);
}

class _JogoState extends State<Jogo> {

  TextEditingController controller = TextEditingController(text: "");

  final Usuario usuario;

  final List<String> levelLabels = ["Iniciante", "Bom início", "Avançando", "Bom", "Muito bom", "Demais!", "Incrível!", "Sensacional!", "Gênio!"];

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

  late List<int> levels = [];

  late int currentLevel = 0;

  late int letrasEncontradas = 0;

  late int maxScore = 0;

  late int currentScore;

  _JogoState(this.usuario);

  Future<int> prepararJogo() async {
   String? letrasDia = await PalavrasDia().getLettersForDay();

    maxScore = await PalavrasDia().maxScore();

    levels = getScoreLevels();

    letraCentral = letrasDia![0];

    if(usuario.pontuacaoData[getCurrentDate()] == null) {
      currentScore = 0;

      usuario.pontuacaoData.addAll({getCurrentDate(): 0});

      DBProvider.db.updateUsuario(usuario);

    } else {
      currentScore = usuario.pontuacaoData[getCurrentDate()];
    }

    if(await checkFileExists('${usuario.nome}-${getCurrentDate()}'
        '-palavrasEncontradas.txt')) {
      palavrasEncontradas = await readFile('${usuario.nome}-${getCurrentDate()}'
          '-palavrasEncontradas.txt');
    } else {
      palavrasEncontradas = [];
    }

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

  List<int> getScoreLevels() {
    List<int> levels = [
      0,
      5,
      (maxScore * 0.05).floor(),
      (maxScore * 0.1).floor(),
      (maxScore * 0.15).floor(),
      (maxScore * 0.2).floor(),
      (maxScore * 0.25).floor(),
      (maxScore * 0.3).floor(),
      (maxScore * 0.35).floor()];

    levels.sort();

    print(levels);

    return levels;
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

    if(!palavra.contains(letraCentral)) {
      mostrarMensagem("Obrigatório usar a letra central!");
      return;
    }

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
        writePalavraEncontrada(palavra);
        currentScore += pontoGanho;
        controller.text = "";
        updatePontuacaoDB(currentScore);
      });
      return;
    }

    mostrarMensagem("Palavra não existe :(");

  }

  void updatePontuacaoDB(currentScore) {
    usuario.pontuacaoData.update(getCurrentDate(), (value) => currentScore);

    DBProvider.db.updateUsuario(usuario);
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
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

  Future<void> writePalavraEncontrada(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/${usuario.nome}-${getCurrentDate()}'
        '-palavrasEncontradas.txt');
    await file.writeAsString('$text\n', mode: FileMode.append);
  }

  readFile(String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$fileName');
    return await file.readAsLines();
  }

  Future<bool> checkFileExists(String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$fileName');
    if (file.existsSync()) {
      return true;
    } else {
      return false;
    }
  }

  void deslogar() {
    usuario.logged = 0;

    DBProvider.db.updateUsuario(usuario);

    controller.text = "";
    pangrams.clear();
    letras.clear();
    answers.clear();
    palavrasEncontradas.clear();
    letrasEncontradas = 0;
    currentScore = 0;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.amber,
          title: const Text("Jogo Da Abelhinha"),
          actions: [
            IconButton(
                onPressed: () => buildPontuacoesPassadas(),
                icon: const Icon(Icons.history)
            ),
            usuario.nome=="admin" ? IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AdminPage())),
                icon: const Icon(Icons.admin_panel_settings)
            ) : const SizedBox(),
            IconButton(
              onPressed: ()=>{
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Sair do aplicativo'),
                      content: const Text('Tem certeza que deseja fazer o logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => deslogar(),
                          child: const Text('Sair'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ],
                    );
                  },
                )
              },
              icon: const Icon(Icons.logout)
            )
          ],
        ),
        body: FutureBuilder(
          future: futureController,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot.stackTrace);
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data != null) {
              return Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ultimasPalavrasEncontradas(),
                      score(),
                      fieldText(controller),
                      Center(
                        child: SizedBox(
                            width: width * 0.7,
                            child: buildColmeia(context, controller)
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, size: 50,),
                              onPressed: () => controller.text = "",
                              tooltip: "Excluir",
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 50,),
                              onPressed: rotacionar,
                              tooltip: "Rotacionar",
                            ),
                            IconButton(
                              icon: const Icon(Icons.send, size: 50,),
                              tooltip: "Enviar",
                              onPressed: validar,
                            ),
                          ]
                      )
                    ],
                  ),
                  buildListaPalavrasEncontradas()
                ],
              );
            }
      
            return const Center(child: CircularProgressIndicator());
          },
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            getLevelDescricao(),
            style: const TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(width: 5,),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Divider(thickness: 5,),
                ),
                StepProgressIndicator(
                  totalSteps: levels.length,
                  currentStep: currentLevel + 1,
                  size: 30,
                  selectedColor: Colors.yellow,
                  unselectedColor: Colors.grey,
                  onTap: (int l) => buildLevelsDia,
                  customStep: (index, color, _) => currentLevel == index
                  ? Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      currentScore.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                  : Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    alignment: Alignment.center,
                  )
                ),
              ],
            )
          ),
        ],
      ),
    );
  }

  String getLevelDescricao() {
    if(currentScore < levels[1]) {
      currentLevel = 0;
      return "Iniciante";
    } else if(currentScore >= levels[1] && currentScore < levels[2]) {
      currentLevel = 1;
      return "Bom início";
    } else if(currentScore >= levels[2] && currentScore < levels[3]) {
      currentLevel = 2;
      return "Avançando";
    } else if(currentScore >= levels[3] && currentScore < levels[4]) {
      currentLevel = 3;
      return "Bom";
    } else if(currentScore >= levels[4] && currentScore < levels[5]) {
      currentLevel = 4;
      return "Muito bom";
    } else if(currentScore >= levels[5] && currentScore < levels[6]) {
      currentLevel = 5;
      return "Demais!";
    } else if(currentScore >= levels[6] && currentScore < levels[7]) {
      currentLevel = 6;
      return "Incrível!";
    } else if(currentScore >= levels[7] && currentScore < levels[8]) {
      currentLevel = 7;
      return "Sensacional!";
    } else if(currentScore >= levels[8]) {
      currentLevel = 8;
      return "Gênio!";
    }
    return "Iniciante";
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
          height: MediaQuery.of(context).size.height * 0.7,
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

  Widget ultimasPalavrasEncontradas() {
    List<String> reversedList = palavrasEncontradas.reversed.toList();

    return Container(
      alignment: Alignment.center,
      height: 50,
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(palavrasEncontradas.length, (index) {
            return Padding(
              padding: const EdgeInsets.all(8.0), // Adjust spacing between list items
              child: Text(
                reversedList[index].toUpperCase(),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void buildLevelsDia() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              height:  MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(8),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Níveis',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Os níveis são calculados com base na quantidade '
                              'máxima de pontos possível com as letras do dia',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: levelLabels.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 40, bottom: 8, right: 8, top: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                levelLabels[index],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      }
                  ),

                  Container(
                    padding: const EdgeInsets.only(left: 17),
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: const VerticalDivider(thickness: 5,),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: StepProgressIndicator(
                      totalSteps: levels.length,
                      currentStep: currentLevel + 1,
                      size: 50,
                      direction: Axis.vertical,
                      selectedColor: Colors.yellow,
                      unselectedColor: Colors.grey,
                      customStep: (index, color, _) => currentLevel == index
                      ? Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          levels[index].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      )
                      : Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          levels[index].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                      )
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
    return;
  }

  void buildPontuacoesPassadas() {
    Map<String, dynamic> pontos = reverseMapOrder(usuario.pontuacaoData);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: (150 * pontos.length).ceilToDouble(),
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Text(
                  'Suas pontuações',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: pontos.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              convertDateFormat(pontos.entries.elementAt(index).key),
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              "${pontos.entries.elementAt(index).value.toString()} pontos",
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 10,),
                      ],
                    );
                  }
                ),
              ],
            ),
          ),
        );
      }
    );
    return;
  }

  Map<String, int> reverseMapOrder(Map<String, dynamic> originalMap) {
    // Create a LinkedHashMap to preserve insertion order
    LinkedHashMap<String, int> reversedMap = LinkedHashMap.from(originalMap);

    // Reverse the order of entries in the LinkedHashMap
    List<MapEntry<String, int>> entries = reversedMap.entries.toList();
    reversedMap.clear();

    for (int i = entries.length - 1; i >= 0; i--) {
      reversedMap[entries[i].key] = entries[i].value;
    }

    return reversedMap;
  }

  String convertDateFormat(String inputDate) {
    // Split the input date string by "-"
    List<String> parts = inputDate.split('-');

    // Extract year, month, and day from the parts
    String year = parts[0];
    String month = parts[1];
    String day = parts[2];

    // Create the formatted date string in the new format "dd-MM-yyyy"
    String formattedDate = '$day-$month-$year';

    return formattedDate;
  }
}
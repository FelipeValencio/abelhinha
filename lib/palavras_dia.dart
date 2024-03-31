import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';


class PalavrasDia {

  Future<String?> getLettersForDay() async {

    if(!(await checkFileExists("answers-all.txt"))) {
      await createAllAnswersFile();
    }

    if(!(await checkFileExists("pangrams-all.txt"))) {
      await createAllPangramsFile();
    }

    if(!(await checkFileExists("letras-all.txt"))) {
      await createAllLettersFile();
    }

    if(!(await checkFileExists("letras-${getCurrentDate()}.txt"))) {
      await createDayLetters();
    }

    if(!(await checkFileExists("answers-${getCurrentDate()}.txt"))) {
      await createDayAnswers();
    }

    if(!(await checkFileExists("pangrams-${getCurrentDate()}.txt"))) {
      await createDayPangrams();
    }

    return await readFileString("letras-${getCurrentDate()}.txt");
  }

  Future<void> createAllAnswersFile() async {
    LineSplitter ls = const LineSplitter();
    List<String> palavras = ls.convert(await rootBundle.loadString('assets/palavras-all.txt'));

    List<String> validWords = palavras.where((word) {
      if (word.length < 4) return false;
      Set<String> uniqueLetters = Set<String>.from(word.split(''));
      if (uniqueLetters.length > 7) return false;
      return true;
    }).toList();

    await writeToFile("answers-all.txt", validWords);
  }

  Future<void> createAllPangramsFile() async {
    if(!(await checkFileExists("answers-all.txt"))) throw "Answer all file not found";

    List<String> validWords = await readFile("answers-all.txt");

    List<String> pangrams = validWords.where((word) => Set<String>.from(word.split('')).length == 7).toList();

    await writeToFile("pangrams-all.txt", pangrams);
  }

  Future<void> createAllLettersFile() async {
    if(!(await checkFileExists("answers-all.txt"))) throw "Answer all file not found";
    if(!(await checkFileExists("pangrams-all.txt"))) throw "Pangrams all file not found";

    List<String> pangrams = await readFile("pangrams-all.txt");

    Set<String> uniqueLetterCombinations = pangrams.fold<Set<String>>(<String>{}, (acc, pangram) {
      Set<String> uniqueLetters = Set<String>.from(pangram.split('').toList()..sort());
      acc.add(uniqueLetters.join(''));
      return acc;
    });

    await writeToFile("letras-all.txt", uniqueLetterCombinations.toList());
  }

  Future<void> createDayAnswers() async {
    if(!(await checkFileExists("answers-all.txt"))) throw "Answer all file not found";
    if(!(await checkFileExists("letras-${getCurrentDate()}.txt"))) throw "Letras dia file not found";

    List<String> words = await readFile("answers-all.txt");

    String letras = await readFileString("letras-${getCurrentDate()}.txt");

    List<String> letters = letras.split('');
    String specificLetter = letras[0];

    List<String> filteredWords = words.where((word) {
      // Check if the word contains only letters from the list
      if (!word.split('').every((char) => letters.contains(char))) {
        return false;
      }

      // Check if the word contains the specific letter
      if (!word.contains(specificLetter)) {
        return false;
      }

      return true;
    }).toList();

    await writeToFile("answers-${getCurrentDate()}.txt", filteredWords);

  }

  Future<void> createDayPangrams() async {
    if(!(await checkFileExists("pangrams-all.txt"))) throw "Pangrams all file not found";
    if(!(await checkFileExists("letras-${getCurrentDate()}.txt"))) throw "Letras dia file not found";

    List<String> pangrams = await readFile("pangrams-all.txt");

    String letras = await readFileString("letras-${getCurrentDate()}.txt");

    List<String> letters = letras.split('');
    String specificLetter = letras[0];

    List<String> filteredWords = pangrams.where((pangram) {
      // Check if the word contains only letters from the list
      if (!pangram.split('').every((char) => letters.contains(char))) {
        return false;
      }

      // Check if the word contains the specific letter
      if (!pangram.contains(specificLetter)) {
        return false;
      }

      return true;
    }).toList();

    await writeToFile("pangrams-${getCurrentDate()}.txt", filteredWords);
  }

  Future<void> createDayLetters() async {
    if(!(await checkFileExists("letras-all.txt"))) throw "Letras all file not found";

    List<String> letrasAll = await readFile("letras-all.txt");

    Random random = Random();

    String letras = letrasAll.elementAt(random.nextInt(letrasAll.length));

    await writeToFileString("letras-${getCurrentDate()}.txt", letras);
  }

  Future<int> maxScore() async {
    if(!(await checkFileExists("pangrams-${getCurrentDate()}.txt"))) throw "Pangrams dia file not found";
    if(!(await checkFileExists("answers-${getCurrentDate()}.txt"))) throw "Answers dia file not found";

    int maxScore = 0;

    List<String> answers = await readFile("answers-${getCurrentDate()}.txt");
    List<String> pangrams = await readFile("pangrams-${getCurrentDate()}.txt");

    for (String a in answers) {
      if (a.length == 4) {
        maxScore++;
      } else {
        maxScore += a.length;
      }
    }

    for (String p in pangrams) {
      maxScore += p.length + 7;
    }

    return maxScore;
  }

  Future<void> writeToFile(String fileName, List<String> text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$fileName');
    await file.writeAsString(text.join('\n'));
  }

  Future<void> writeToFileString(String fileName, String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$fileName');
    await file.writeAsString(text);
  }

  String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
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

  Future<String> readFileString(String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$fileName');
    return await file.readAsString();
  }

  Future<List<String>> readFile(String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/$fileName');
    return await file.readAsLines();
  }


}
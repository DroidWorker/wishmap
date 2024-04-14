import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class WordWrapWidget extends StatelessWidget {
  final String text;
  final int maxCharactersPerLine;

  WordWrapWidget({
    required this.text,
    this.maxCharactersPerLine = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildText(),
    );
  }

  List<Widget> _buildText() {
    List<Widget> textWidgets = [];

    List<String> words = text.split(' ');

    for (String word in words) {
      if (word.length > maxCharactersPerLine) {
        // Слово длиннее максимального количества символов
        int splitIndex = _findVowelSplitIndex(word);
        if (splitIndex != -1) {
          String firstPart = word.substring(0, splitIndex + 1); // Включаем гласную букву в первую часть
          String secondPart = word.substring(splitIndex + 1);

          // Добавляем первую и вторую части слова как отдельные виджеты
          textWidgets.add(AutoSizeText(
            textAlign: TextAlign.center,
            minFontSize: 8,
            maxFontSize: 18,
            "$firstPart\n$secondPart",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ));
        } else {
          // Если не найдена подходящая гласная буква, просто добавляем слово как один виджет
          textWidgets.add(AutoSizeText(
            minFontSize: 8,
            maxFontSize: 18,
            word,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ));
        }
      } else {
        // Слово помещается в строку без переноса
        textWidgets.add(AutoSizeText(
          minFontSize: 8,
          maxFontSize: 18,
          word,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ));
      }
    }

    return textWidgets;
  }

  int _findVowelSplitIndex(String word) {
    String vowels = 'aeiouAEIOUаеёиоуыэюяАЕЁИОУЫЭЮЯ';
    int closestVowelIndex = -1;

    for (int i = maxCharactersPerLine - 1; i >= 0; i--) {
      if (vowels.contains(word[i])) {
        closestVowelIndex = i;
        break;
      }
    }

    return closestVowelIndex;
  }
}
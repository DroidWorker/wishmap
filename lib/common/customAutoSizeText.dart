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
    String currentLine = '';

    for (String word in words) {
      if (currentLine.length + word.length + 1 <= maxCharactersPerLine) {
        // If the word fits, add it to the current line
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        // If the current line is not empty, add it to the list
        if (currentLine.isNotEmpty) {
          textWidgets.add(_buildAutoSizeText(currentLine));
        }

        // Split the word if it doesn't fit
        if (word.length > maxCharactersPerLine) {
          List<String> splitWord = _splitWord(word);
          for (String part in splitWord) {
            currentLine = part;
            textWidgets.add(_buildAutoSizeText(currentLine));
          }
        } else {
          // If the word fits by itself, start a new line
          currentLine = word;
        }
      }
    }

    // Add any remaining text in the current line
    if (currentLine.isNotEmpty) {
      textWidgets.add(_buildAutoSizeText(currentLine));
    }

    return textWidgets.take(2).toList(); // Limit to 2 lines
  }

  AutoSizeText _buildAutoSizeText(String text) {
    return AutoSizeText(
      text,
      minFontSize: 8,
      maxFontSize: 18,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  List<String> _splitWord(String word) {
    String vowels = 'aeiouAEIOUаеёиоуыэюяАЕЁИОУЫЭЮЯ';
    List<String> parts = [];
    int lastSplitIndex = 0;

    for (int i = 0; i < word.length; i++) {
      // If the part length exceeds maxCharactersPerLine
      if (i - lastSplitIndex >= maxCharactersPerLine) {
        // Split at the last vowel before exceeding the limit
        while (lastSplitIndex < i && !vowels.contains(word[i - 1])) {
          i--;
        }
        // Add the part before the split
        parts.add(word.substring(lastSplitIndex, i));
        lastSplitIndex = i;
      }
    }

    // Add any remaining part
    if (lastSplitIndex < word.length) {
      parts.add(word.substring(lastSplitIndex));
    }

    return parts;
  }
}
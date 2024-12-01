import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../testingEngine/data/models.dart';

class EditableTable extends StatefulWidget {
  final double maxWidth;
  final List<Question> questions;
  final List<String> indexTitle;

  Function(List<double>) onValueUpdate;

  EditableTable({Key? key, required this.maxWidth, required this.questions, this.indexTitle = const [
    "Здоровье",
    "Отношения",
    "Окружение",
    "Призвание",
    "Богатство",
    "Саморазвитие",
    "Яркость жизни",
    "Духовность"
  ], required this.onValueUpdate}) : super(key: key);

  @override
  _EditableTableState createState() => _EditableTableState();
}

class _EditableTableState extends State<EditableTable> {
  List<double> summList = [];
  Future<List<DataRow>> _loadData() async {
    // Ваши асинхронные операции
    await Future.delayed(Duration(seconds: 2)); // Пример задержки

    // Возвращаем результаты в виде списка DataRow
    return widget.questions.map((question) {
      TextEditingController questionController =
      TextEditingController(text: question.question);
      List<TextEditingController> indexesControllers = question.indexes
          .map((index) => TextEditingController(text: index.toString()))
          .toList();

      return DataRow(cells: [
        DataCell(
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.black,
              ),
            ),
            child: TextFormField(
              controller: questionController,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (value) {
                question.question = value;

              },
            ),
          )
        ),
        ...indexesControllers.map((controller) => DataCell(
          Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.black,
                ),
              ),
              child: TextFormField(
                textAlign: TextAlign.center,
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            onChanged: (value) {
              int index = indexesControllers.indexOf(controller);
              question.indexes[index] = double.tryParse(value) ?? 0;
              double summ = 0;
                for(int j = 0; j<widget.questions.length; j++){
                  summ+=widget.questions[j].indexes[index];
                }
                summList[index]=summ;
              widget.onValueUpdate(summList);
            },
          )),
        )),
      ]);
    }).toList();
  }

  @override
  void initState() {
    widget.questions.firstOrNull?.indexes.forEach((element) {
      summList.add(100);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DataRow>>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Возвращаем заглушку или индикатор загрузки во время ожидания
          return CircularProgressIndicator(color: Colors.yellow,);
        } else if (snapshot.hasError) {
          // Обработка ошибки, если есть
          return Text('Error: ${snapshot.error}');
        } else {
          // Возвращаем DataTable после завершения асинхронных операций
          return DataTable(
            columns: [
              const DataColumn(label: Text('')),
              ...List.generate(
                widget.questions[0].indexes.length,
                    (index) => DataColumn(
                  label: Text(
                    widget.indexTitle[index],
                    style: const TextStyle(fontSize: 8),
                  ),
                ),
              ),
            ],
            columnSpacing: 3,
            rows: snapshot.data ?? [], // Используем результаты асинхронной операции
          );
        }
      },
    );
  }
}
import 'package:cross_scroll/cross_scroll.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HokinsDistributionForQuestionEdit extends StatefulWidget {
  final List<String> answers;
  final List<List<int>> koeffs;
  final List<String> indexTitle;

  HokinsDistributionForQuestionEdit({Key? key, required this.answers, required this.koeffs, this.indexTitle =
  const [
    "Стыд",
    "Вина",
    "Апатия",
    "Горе",
    "Страх",
    "Вожделение",
    "Гнев",
    "Гордость",
    "Смелость",
    "Нейтралитет",
    "Готовность",
    "Принятие",
    "Разумность",
    "Любовь",
    "Радость",
    "Покой",
    "Итого"
  ]
  }) : super(key: key);

  @override
  _EditableTableState createState() => _EditableTableState();
}

class _EditableTableState extends State<HokinsDistributionForQuestionEdit> {
  final ScrollController scrollController = ScrollController();
  List<int> summ = [100, 100, 100, 100, 100];
  @override
  Widget build(BuildContext context) {
    summ = [];
    for (var element in widget.koeffs) {
      summ.add(element.reduce((a, b) => a + b));
    }
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      scrollbarOrientation: ScrollbarOrientation.bottom,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Column(children: [
              const Text(""),
              DataTable(
                columnSpacing: 1,
                columns: const [
                  DataColumn(label: Text("Текст ответа\n "),),
                ],
                rows: widget.answers.map((answer) {
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
                        initialValue: answer,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            widget.answers[widget.answers.indexOf(answer)] = value;
                          });
                        },
                      )),
                    ),
                  ]);
                }).toList(),
              )
            ],),
            Column(children: [
              const Text(""),
              DataTable(
                columnSpacing: 1,
                columns: const [
                  DataColumn(label: Text("Значение ответа \n'Колесо'", maxLines: 2)),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(
                      const Text('1'),
                    ),
                  ]),
                  DataRow(cells: [
                    DataCell(
                      const Text('0.75'),
                    ),
                  ]),
                  DataRow(cells: [
                    DataCell(
                      const Text('0.5'),
                    ),
                  ]),
                  DataRow(cells: [
                    DataCell(
                      const Text('0.25'),
                    ),
                  ]),
                  DataRow(cells: [
                    DataCell(
                      const Text('0'),
                    ),
                  ]),
                ],
              )
            ],),
            Column(children: [
              const Text("Распределение вероятности 'Хокинс'"),
              DataTable(
                columnSpacing: 2,
                columns: List.generate(
                  widget.indexTitle.length,
                      (index) => DataColumn(label: Text(widget.indexTitle[index])),
                ),
                rows: widget.koeffs.map((row) {
                  List<TextEditingController> controllers = row.map((value) => TextEditingController(text: value.toString())).toList();

                  return DataRow(cells: [
                    ...controllers.map((controller) => DataCell(
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
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          int columnIndex = controllers.indexOf(controller);
                          int rowIndex = widget.koeffs.indexOf(row);
                          setState(() {
                            widget.koeffs[rowIndex][columnIndex] = int.tryParse(value) ?? 0;
                          });
                        },
                      )),
                    )),
                    DataCell(Text(summ[widget.koeffs.indexOf(row)].toString(), textAlign: TextAlign.center,))
                  ]);
                }).toList(),
              )
            ],),
          ],
        ),
      ),
    );
  }
}
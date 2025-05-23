import 'dart:typed_data';

import 'package:flutter/material.dart';

class AuthData {
  final String login;
  final String password;

  AuthData({required this.login, required this.password});
}

class LockParams {
  String password;
  bool allowFingerprint;

  LockParams({required this.password, required this.allowFingerprint});
}

class ProfileData {
  String id = "";
   String name;
   String surname;
  String thirdname = "";
   DateTime birtday;
   bool male;
  String phone  = "";
  final String email;
  String tg = "";

  ProfileData({this.id = "", required this.name, required this.surname, required this.birtday, required this.male, required this.email, this.thirdname = "", this.phone = "", this.tg = ""});

  ProfileData copy(){
    return ProfileData(id: id, name: name, surname: surname, thirdname: thirdname, birtday: birtday, male: male, phone: phone, email: email, tg: tg);
  }
}

class ActualizingSettingData{
  bool fastActMainSphere = true;

  bool actualizeFullBranch = true;

  int sphereActualizingMode = 1;
  bool fastActSphere = true;
  //0-Автоматическая актуализация всех сфер при актуализации 'Я'
  //1-автоматическая актуализация конкретной сферы при актуализации нижестоящего желания (верхнего уровня)
  int wishActualizingMode = 0;
  bool fastActWish = true;
  //0-режим автоматическая актуализация желания сверху вниз каскадом
  //1-автоматическая актуализация снизу вверх по ветке
  int taskActualizingMode = 0;
  bool fastActtask = false;
  //0-taskAutoActualizingOff
  //1-"автоматически актуализировать невыполненные задачи  при актуализации новой карты, то задач, которые потребуют ручной актуализации не будет, они все автоматом будут актуализированы при актуализации вышестоящей цели, а значит и желания.
  ActualizingSettingData({this.sphereActualizingMode = 1, this.wishActualizingMode = 0, this.taskActualizingMode = 0});

  int quoteupdateFreq=10;

  int treeView = 0;
  //0-old
  //1-new

 bool animationEnabled = true;
}
class Promocode{
  String promocode;
  String expDate;
  String type;

  Promocode(this.promocode, this.expDate, this.type);
}

class CircleData{
  final int id;
  String text;
  String subText = "";
  Color color;
  final int parenId;
  String affirmation;
  String photosIds = "";
  bool isChecked;
  bool isActive;
  bool isHidden;

  bool shuffle=false;
  String lastShuffle="|";

  //link mechanism
  int prevId;
  int nextId;

  CircleData({required this.id, required this.prevId, required this.nextId, required this.text, this.subText = "", required this.color, required this.parenId, this.affirmation="", this.photosIds="", this.isChecked = false, this.isActive = true, this.isHidden = false});

  @override
  String toString(){
    return "circleData: $id $text";
  }

  CircleData copy(){
    return (CircleData(
    id: id,
    prevId: prevId,
    nextId: nextId,
    text: text,
    subText: subText,
    color: color,
    parenId: parenId,
    affirmation: affirmation,
    photosIds:  photosIds,
    isChecked: isChecked,
    isActive: isActive,
    )
    ..shuffle=shuffle
    ..lastShuffle=lastShuffle);
  }
}

class Circle {
  final int id;
  final int parentId;
  String text;
  Color color;
  int radius;
  bool isActive;
  bool isChecked;

  //link mechanism
  int prevId;
  int nextId;

  Circle({required this.id, required this.parentId, required this.prevId, required this.nextId, required this.text, required this.color, this.radius=80, this.isActive = true, this.isChecked = true});

  Map toJson() => {
    'id': id,
    'parentId': parentId,
      'text': text,
  'color': color,
      'radius': radius,
  'isActive': isActive,
      'isChecked': isChecked,
  'prevId': prevId,
      'nextId': nextId,
  };
}

class MainCircle {
  final int id;
  Pair coords;
  String text;
  String substring = "";
  int textSize = 24;
  Color color;
  double radius;
  bool isVisible;
  bool isActive;
  bool isChecked;

  MainCircle({required this.id, required this.coords, required this.text, this.substring = "", this.textSize = 24, required this.color, this.radius=52, this.isVisible = true, this.isActive = true, this.isChecked = false});

  Map toJson() => {
    'id': id,
    'coords': coords,
    'text': text,
    'substring': substring,
    'textSize': textSize,
    'color': color,
    'radius': radius,
    'isVisible': isVisible,
    'isActive': isActive,
    'isChecked': isChecked,
  };

  @override
  String toString(){
    return "{MainCircle $id  $text ${coords.key}.${coords.value}";
  }
}

class Pair{
  double key;
  double value;

  Pair({required this.key, required this.value});
}

class MoonItem {
  final int id;
  final double filling;
  final String text;
  final String date;

  MoonItem({required this.id, required this.filling, required this.text, required this.date});
}

class TaskItem {
  final int id;
  final int parentId;
  final String text;
  bool isChecked;
  bool isActive;

  TaskItem({required this.id, required this.parentId, required this.text, required this.isChecked, required this.isActive});
}

class TaskData {
  final int id;
  final int parentId;
  String text;
  String description;
  bool isChecked = false;
  bool isActive = true;

  TaskData({required this.id, required this.parentId, required this.text, required this.description, this.isChecked=false, this.isActive=true});
}

class WishItem {
  final int id;
  final String text;
  bool isChecked;
  bool isActive;
  bool isHidden;
  int parentId;

  WishItem({required this.id, required this.text, required this.isChecked, required this.isActive, required this.isHidden, this.parentId=-1});
}

class WishData {
  final int id;
  final int parentId;
  String text;
  String description;
  List<int> photolist = [];
  String photoIds = "";
  String affirmation;
  Color color;
  Map<String, int> childAims = {};
  Map<int, Uint8List> photos = {};
  bool isChecked = false;
  bool isActive = true;
  bool isHidden = false;

  bool shuffle=false;
  String lastShuffle="|";

  //link mechanism
  int prevId;
  int nextId;

  WishData({required this.id, required this.prevId, required this.nextId, required this.parentId, required this.text, required this.description, this.photoIds = "", required this.affirmation, required this.color});
}

class AimItem {
  final int id;
  final parentId;
  final String text;
  bool isChecked;
  bool isActive;

  AimItem({required this.id, required this.parentId, required this.text, required this.isChecked, required this.isActive});
}

class AimData {
  final int id;
  final int parentId;
  String text;
  String description;
  List<int> childTasks = [];
  bool isChecked = false;
  bool isActive = true;

  AimData({required this.id, required this.parentId, required this.text, required this.description, this.isChecked=false, this.isActive=true});
}

class ProfileItem {
  final String id;
  final String name;
  final String surname;
  final String email;
  final Color bgcolor;

  ProfileItem({required this.id, required this.name, required this.surname, required this.email, required this.bgcolor});
}

class MyTreeNode {
  MyTreeNode({
    required this.id,
    required this.type,
    required this.title,
    required this.isChecked,
    this.isHidden = false,
    this.isActive = true,
    this.children = const <MyTreeNode>[],
  });

  final int  id;
  final String type;//m-maincircle s-sphere w-wish a-aim t-task
  final String title;
  bool isChecked;
  bool isHidden;
  bool isActive;
  bool noClickable = false;
  final List<MyTreeNode> children;

  @override
  String toString(){
    return "treeNode $id $title";
  }
}

List<MyTreeNode> convertListToMyTreeNodes(List<WishItem> dataList) {

  List<MyTreeNode> roots = [];

  var idsList = dataList.map((e) => e.id).toList();
  idsList.forEach((element) {
    final wi = dataList.firstWhere((e) => e.id==element);
    roots.add(MyTreeNode(id: wi.id, type: 'w', title: wi.text, isChecked: wi.isChecked, isActive: wi.isActive, children: getChildren(dataList, element), isHidden: wi.isHidden));
  });
  List<int> rootsIds = [];
  List<MyTreeNode> finalroots = List.from(roots);
  for (var element in roots) {
    final v = getRootsIds(element);
    v.forEach((e) {
      if(rootsIds.contains(e)){
        finalroots.removeWhere((i) => i.id==element.id);
      }
      else{
        rootsIds.add(e);
      }
    });
  }
  return finalroots;
}
List<MyTreeNode> getChildren(List<WishItem> dataList, id){
  final children = dataList.where((element) => element.parentId==id).toList();
  return children.map((e) => MyTreeNode(id: e.id, type: 'w', title: e.text, isChecked: e.isChecked, isActive: e.isActive, children: getChildren(dataList, e.id), isHidden: e.isHidden)).toList();
}
List<int> getRootsIds(MyTreeNode node){
  List<int> ids = [];
  if(node.children.isNotEmpty) {
    node.children.forEach((element) {
      ids.addAll(getRootsIds(element));
    });
  }else{ids.add(node.id);}
  return ids;
}

class MainScreenState {
  final MoonItem moon;
  List<CircleData> allCircles = [];
  bool needToUpdateCoords = true;
  final int musicId;

  MainScreenState({required this.moon, required this.musicId});
}

class WishScreenState {
  WishData wish;
  List<AimItem> wishAims = [];
  List<TaskItem>wishTasks = [];
  bool isDataloaded = false;

  WishScreenState({required this.wish});
}

class MessageError {
  String text = "";

  MessageError();
}

class CardData{
  final int id;
  String emoji;
  String title;
  String description;
  String text;
  Color color;

  CardData({required this.id, required this.emoji, required this.title, required this.description, required this.text, required this.color});
}

class Article{
  final int id;
  final int parentId;
  String text;
  String date;
  String time;
  List<String> attachments;

  Article(this.id, this.parentId, this.text, this.date, this.time, this.attachments);
}

abstract class ReminderInterface{
  int id;
  int TaskId;
  DateTime dateTime;
  List<String> remindDays;
  String music;
  bool remindEnabled;
  bool vibration;

  ReminderInterface(this.id, this.TaskId, this.dateTime, this.remindDays, this.music, this.remindEnabled, {this.vibration = true});
}

class Reminder extends ReminderInterface{
  final int id;
  final int TaskId;//id задачи которой принадлежит reminder
  DateTime dateTime;//время когда сработает напоминание
  List<String> remindDays;//список дней когда напоминание должно сработать
  String music;//музыка напоминания
  bool remindEnabled;//флаг определяющий включен ли повтор напоминанаий
  bool vibration;
  int moonId;

  Reminder(this.id, this.TaskId, this.moonId, this.dateTime, this.remindDays, this.music, this.remindEnabled, {this.vibration = true}) : super(id, TaskId, dateTime, remindDays, music, remindEnabled, vibration: vibration);
}

class Alarm extends ReminderInterface{
  final int id;
  final int TaskId;//id задачи которой принадлежит reminder
  DateTime dateTime;//время когда сработает напоминание
  List<String> remindDays;//список дней когда напоминание должно сработать
  String music;//музыка напоминания
  bool remindEnabled;//флаг определяющий включен ли повтор напоминанаий
  bool vibration;
  String text;
  List<int> notificationIds;
  List<int> offMods;
  Map<String, String> offModsParams;
  String snooze;

  Alarm(this.id, this.TaskId, this.dateTime, this.remindDays, this.music, this.remindEnabled, this.text, {this.vibration = true, this.notificationIds = const[], this.offMods= const[], this.offModsParams = const{}, this.snooze = ""}) : super(id, TaskId, dateTime, remindDays, music, remindEnabled, vibration: vibration);
}

List<CircleData> sortList(List<CircleData> inputList) {
  Map<int, CircleData> circleDataMap = {};
  List<CircleData> sortedList = [];

  // Создаем словарь, используя id в качестве ключей
  inputList.forEach((circleData) {
    circleDataMap[circleData.id] = circleData;
  });

  // Находим корневые элементы (те, у которых prevId == -1)
  List<CircleData> rootElements = inputList.where((circleData) => circleData.prevId == -1).toList();

  // Рекурсивно строим отсортированный список
  void buildSortedList(int parentId) {
    if (circleDataMap.containsKey(parentId)) {
      CircleData parent = circleDataMap[parentId]!;
      sortedList.add(parent);

      // Проверяем nextId и рекурсивно вызываем для следующего элемента
      if (parent.nextId != -1) {
        buildSortedList(parent.nextId);
      }
    }
  }

  // Для каждого корневого элемента вызываем построение отсортированного списка
  rootElements.forEach((root) {
    buildSortedList(root.id);
  });

  sortedList.addAll(inputList.where((circleData) => circleData.prevId < -1).toList());

  sortedList.forEach((element) {
    print("element ${element.id}  ${element.text}");
  });

  print("sort list returned ${sortedList.length} items");
  return sortedList;
}


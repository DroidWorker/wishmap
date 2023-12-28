import 'dart:typed_data';

import 'package:flutter/material.dart';

class AuthData {
  final String login;
  final String password;

  AuthData({required this.login, required this.password});
}

class ProfileData {
  String id = "";
  final String name;
  final String surname;

  ProfileData({this.id = "", required this.name, required this.surname});
}

class ActualizingSettingData{
  bool fastActMainSphere = false;

  int sphereActualizingMode = 0;
  bool fastActSphere = false;
  //0-Автоматическая актуализация всех сфер при актуализации 'Я'
  //1-автоматическая актуализация конкретной сферы при актуализации нижестоящего желания (верхнего уровня)
  int wishActualizingMode = 0;
  bool fastActWish = false;
  //0-режим автоматическая актуализация желания сверху вниз каскадом
  //1-автоматическая актуализация снизу вверх по ветке
  int taskActualizingMode = 0;
  bool fastActtask = false;
  //0-taskAutoActualizingOff
  //1-"автоматически актуализировать невыполненные задачи  при актуализации новой карты, то задач, которые потребуют ручной актуализации не будет, они все автоматом будут актуализированы при актуализации вышестоящей цели, а значит и желания.
  ActualizingSettingData({this.sphereActualizingMode = 0, this.wishActualizingMode = 0, this.taskActualizingMode = 0});

  int quoteupdateFreq=10;
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

  CircleData({required this.id, required this.text, this.subText = "", required this.color, required this.parenId, this.affirmation="", this.photosIds="", this.isChecked = false, this.isActive = true, this.isHidden = false});

  @override
  String toString(){
    return "circleData: $id $text";
  }

  CircleData copy(){
    return CircleData(
    id: id,
    text: text,
    subText: subText,
    color: color,
    parenId: parenId,
    affirmation: affirmation,
    photosIds:  photosIds,
    isChecked: isChecked,
    isActive: isActive,
    );
  }
}

class Circle {
  final int id;
  final String text;
  final Color color;
  int radius;
  bool isActive;

  Circle({required this.id, required this.text, required this.color, this.radius=80, this.isActive = true});
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

  MainCircle({required this.id, required this.coords, required this.text, this.substring = "", this.textSize = 24, required this.color, this.radius=52, this.isVisible = true, this.isActive = true});
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

  WishData({required this.id, required this.parentId, required this.text, required this.description, this.photoIds = "", required this.affirmation, required this.color});
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
    this.children = const <MyTreeNode>[],
  });

  final int  id;
  final String type;//m-maincircle w-wish a-aim t-task
  final String title;
  bool isChecked;
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
    roots.add(MyTreeNode(id: wi.id, type: 'w', title: wi.text, isChecked: wi.isChecked, children: getChildren(dataList, element)));
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
  return children.map((e) => MyTreeNode(id: e.id, type: 'w', title: e.text, isChecked: e.isChecked, children: getChildren(dataList, e.id))).toList();
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
  final int musicId;
  String hint = "";

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
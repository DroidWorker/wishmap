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

  CircleData({required this.id, required this.text, this.subText = "", required this.color, required this.parenId, this.affirmation="", this.photosIds="", this.isChecked = false, this.isActive = true});
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
  int textSize = 24;
  Color color;
  double radius;
  bool isVisible;
  bool isActive;

  MainCircle({required this.id, required this.coords, required this.text, this.textSize = 24, required this.color, this.radius=52, this.isVisible = true, this.isActive = true});
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
  final String text;
  bool isChecked;

  TaskItem({required this.id, required this.text, required this.isChecked});
}

class TaskData {
  final int id;
  final int parentId;
  String text;
  String description;
  bool isChecked = false;

  TaskData({required this.id, required this.parentId, required this.text, required this.description, this.isChecked=false});
}

class WishItem {
  final int id;
  final String text;
  bool isChecked;
  int parentId;

  WishItem({required this.id, required this.text, required this.isChecked, this.parentId=-1});
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

  WishData({required this.id, required this.parentId, required this.text, required this.description, this.photoIds = "", required this.affirmation, required this.color});
}

class AimItem {
  final int id;
  final String text;
  bool isChecked;

  AimItem({required this.id, required this.text, required this.isChecked});
}

class AimData {
  final int id;
  final int parentId;
  String text;
  String description;
  List<int> childTasks = [];
  bool isChecked = false;

  AimData({required this.id, required this.parentId, required this.text, required this.description, this.isChecked=false});
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
  final List<MyTreeNode> children;
}

class MainScreenState {
  final MoonItem moon;
  List<CircleData> allCircles = [];
  final int musicId;

  MainScreenState({required this.moon, required this.musicId});
}

class WishScreenState {
  final WishData wish;
  List<AimItem> wishAims = [];
  List<TaskItem>wishTasks = [];

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
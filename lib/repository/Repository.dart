import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/data/models.dart';

import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Repository{
  final DatabaseReference userRef = FirebaseDatabase.instance.refFromURL('https://wishmap-c3e06-default-rtdb.europe-west1.firebasedatabase.app/').child('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Repository(){
    _init();
  }

  Future _init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<ProfileData?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (_auth.currentUser != null) {
        DataSnapshot snapshot = (await userRef.child(_auth.currentUser!.uid).once()).snapshot;
        if (snapshot.value != null) {
          Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
          String name = userData['name']?? '';
          String surname = userData['surname']?? '';
          return ProfileData(id: _auth.currentUser!.uid, name: name, surname: surname);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case "INVALID_LOGIN_CREDENTIALS":
          case "user-disabled":
          case "user-not-found":
            throw Exception("Email не найден");
          case "email-already-in-use":
          case "operation-not-allowed":
            throw Exception("Пользователь уже существует");
          case "too-many-requests":
            throw Exception("Подозрительная активность: попробуйте позже");
          case "weak-password":
            throw Exception("Пароль слишком слабый, используйте другой пароль");
        }
      } else {
        print("eeerrrr $e");
        throw Exception("unknown exception #rep001");
      }
    }
  }
  Future<String?> registration(ProfileData pd, AuthData ad) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: ad.login, password: ad.password);
      if(_auth.currentUser!=null){
        userRef.child(_auth.currentUser!.uid).set({
          'name': pd.name,
          'surname': pd.surname,
          'email': ad.login
        });
        return _auth.currentUser!.uid;
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch(e.code){
          case "invalid-email":
          case "user-disabled":
          case "user-not-found":
            throw Exception("Email не найден");
          case "email-already-in-use":
          case "operation-not-allowed":
            throw Exception("Пользователь удже существует");
          case "too-many-requests":
            throw Exception("Подозрительная активность: попробуйте позже");
          case "weak-password":
            throw Exception("Пароль слишком слабый, используйте другой пароль");
        }
      } else {
        throw Exception("unknown exception #rep001");
      }
    }
  }

  Future<List<MoonItem>?> getMoonList() async {
    if (_auth.currentUser != null) {
      DataSnapshot snapshot = (await userRef.child(_auth.currentUser!.uid).child("moonlist").once()).snapshot;
      if (snapshot.children.isNotEmpty) {
        List<MoonItem> moons = [];
        snapshot.children.forEach((element) {
          if(element.key!=null&&element.value!=null) {
            int id = int.parse(element.key!);
            final Map<dynamic, dynamic> dataList = element.value as Map<dynamic,dynamic>;
            String text = dataList['text'];
            String date = dataList['date'];
            double filling = dataList['filling'];
            moons.add(MoonItem(id: id, filling: filling, text: text, date: date));
          }
        });
        return moons;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
  Future addMoon(MoonItem moonItem, List<CircleData> defaultCircles) async {
    if(_auth.currentUser!=null){
        userRef.child(_auth.currentUser!.uid).child("moonlist").child(moonItem.id.toString()).set({
          'text': moonItem.text,
          'date': moonItem.date,
          'filling': moonItem.filling
        });
        List<Map<String, dynamic>> circleDataList = [];

        // Преобразуем каждый объект CircleData в Map
        for (CircleData circleData in defaultCircles) {
          Map<String, dynamic> circleDataMap = {
            'id': circleData.id,
            'text': circleData.text,
            'subText': circleData.subText,
            'color': circleData.color.value, // Сохраняем цвет как строку
            'parentId': circleData.parenId,
          };
          circleDataList.add(circleDataMap);
        }
        userRef.child(_auth.currentUser!.uid).child("moonlist").child(moonItem.id.toString()).child("spheres").set(
          circleDataList
        );
    }
  }

  Future<List<CircleData>?> getSpheres(int moonId) async{
    List<CircleData> circleDataList = [];

    if(_auth.currentUser!=null) {
      DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
          .child("moonlist").child(moonId.toString()).child("spheres")
          .once()).snapshot;
      if (dataSnapshot.children.isNotEmpty) {
        dataSnapshot.children.forEach((element) {
          final Map<dynamic, dynamic> dataList = element.value as Map<dynamic,dynamic>;
          CircleData circleData = CircleData(
            id: int.parse(element.key.toString()),
            text: dataList['text'],
            subText: dataList['subText'] ?? "",
            color: Color(int.parse(dataList['color'].toString())),
            parenId: int.parse(dataList['parentId'].toString()),
          );
          circleDataList.add(circleData);
        });
      }
      return circleDataList;
    }
    return null;
  }

  Future<List<TaskItem>?> getMyTasks(int moonId) async{
// Реализация
  }

  Future<List<AimItem>?> getMyAims(int moonId) async{
// Реализация
  }

  Future<List<WishItem>?> getMyWishs(int moonId) async{
// Реализация
  }

  Future createSphereWish(WishData wd) async {
    // Реализация
  }

  Future createAim(AimData ad, int parentWishId) async {
    // Реализация оздания цели и добавления полученного идентификатра в желание
  }

  Future createTask(TaskData td, int parentAimId) async {
    // Реализация оздания адачи и добавления полученного идентификатра в цель
  }

  //temp data
  static getChildrenSpheres(int parentId){
    switch(parentId){
      case 0:
        return [
          Circle(id: 1, text: 'Икигай', color: const Color(0xFFFF0000)),
          Circle(id: 2, text: 'Любовь', color: const Color(0xFFFF006B)),
          Circle(id: 3, text: 'Дети', color: const Color(0xFFD9D9D9)),
          Circle(id: 4, text: 'Путешествия', color: const Color(0xFFFFE600)),
          Circle(id: 5, text: 'Карьера', color: const Color(0xFF0029FF)),
          Circle(id: 6, text: 'Образование', color: const Color(0xFF46C8FF)),
          Circle(id: 7, text: 'Семья', color: const Color(0xFF3FA600)),
          Circle(id: 8, text: 'Богатство', color: const Color(0xFFB4EB5A)),
          ];
      default:
        return [Circle(id: 11, text: "child11", color: Colors.deepOrangeAccent), Circle(id: 12, text: "child12", color: Colors.orange), Circle(id: 13, text: "child13", color: Colors.purpleAccent)];
    }
  }
  static getProfile(String? login, String? password){
    if(login!=null&&password!=null){//get profile by auth screen

      throw Exception("user not found #001");
    }else{//get login from db

      return ProfileItem(id: 0, name: "test_name", surname: "surname", email: "email@email.com", bgcolor: Colors.pinkAccent);
    }
  }
  static registerProfile(String name, String surname, String login, String password){
      return ProfileItem(id: 0, name: "test_name", surname: "surname", email: "email@email.com", bgcolor: Colors.pinkAccent);
  }

  static saveAim(){
    return true;
  }
}
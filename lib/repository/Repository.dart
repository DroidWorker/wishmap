import 'dart:async';
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

  Future<List<int>?> getSpheresChildAims(int sphereId, int moonId) async{
      if(_auth.currentUser!=null) {
        List<int> numberList = [];
        DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
            .child("moonlist").child(moonId.toString()).child("spheres").child(sphereId.toString()).child("childAims")
            .once()).snapshot;
        if (dataSnapshot.value != null) {
          final Map<dynamic, dynamic> data = dataSnapshot.value as Map<dynamic, dynamic>;

          data.forEach((key, value) {
            // Пропустите ключи и добавьте только значения
            if (value is int) {
              numberList.add(value);
            }
          });
        }
      return numberList;
    }
    return null;
  }
  Future<List<int>?> getAimsChildTasks(int aimId, int moonId) async{
    if(_auth.currentUser!=null) {
      List<int> numberList = [];
      DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
          .child("moonlist").child(moonId.toString()).child("aims").child(aimId.toString()).child("childTasks")
          .once()).snapshot;
      if (dataSnapshot.value != null) {
        final Map<dynamic, dynamic> data = dataSnapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          // Пропустите ключи и добавьте только значения
          if (value is int) {
            numberList.add(value);
          }
        });
      }
      return numberList;
    }
    return null;
  }

  Future<List<TaskItem>?> getMyTasks(int moonId) async{
    if(_auth.currentUser!=null) {
      List<TaskItem> tasksList = [];
      DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
          .child("moonlist").child(moonId.toString()).child("tasks")
          .once()).snapshot;
      if (dataSnapshot.children.isNotEmpty) {
        dataSnapshot.children.forEach((element) {
          final Map<dynamic, dynamic> dataList = element.value as Map<dynamic,dynamic>;
          tasksList.add(TaskItem(
              id: int.parse(dataList['id'].toString()),
              text: dataList['text'],
              isChecked: dataList['isChecked']
          ));
        });
      }
      return tasksList;
    }
    return null;
  }

  Future<List<AimItem>?> getMyAims(int moonId) async{
    if(_auth.currentUser!=null) {
      List<AimItem> aimsList = [];
      DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
          .child("moonlist").child(moonId.toString()).child("aims")
          .once()).snapshot;
      if (dataSnapshot.children.isNotEmpty) {
        dataSnapshot.children.forEach((element) {
          final Map<dynamic, dynamic> dataList = element.value as Map<dynamic,dynamic>;
          aimsList.add(AimItem(
              id: int.parse(dataList['id'].toString()),
              text: dataList['text'],
              isChecked: dataList['isChecked']
          ));
        });
      }
      return aimsList;
    }
    return null;
  }

  Future<List<WishItem>?> getMyWishs(int moonId) async{
    if(_auth.currentUser!=null) {
      List<WishItem> wishesList = [];
      DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
          .child("moonlist").child(moonId.toString()).child("spheres")
          .once()).snapshot;
      if (dataSnapshot.children.isNotEmpty) {
        dataSnapshot.children.forEach((element) {
          final Map<dynamic, dynamic> dataList = element.value as Map<dynamic,dynamic>;
          wishesList.add(WishItem(
              id: int.parse(dataList['id'].toString()),
              text: dataList['text'],
              isChecked: dataList['isChecked']??false,
              parentId: dataList['parentId']
          ));
        });
      }
      return wishesList.where((element) => element.parentId>1).toList();
    }
    return null;
  }
  Future<WishData?> getMyWish(int id, int moonId) async{
    if(_auth.currentUser!=null) {
      DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
          .child("moonlist").child(moonId.toString()).child("spheres").child(id.toString())
          .once()).snapshot;
      if (dataSnapshot.children.isNotEmpty) {
          final Map<dynamic, dynamic> dataList = dataSnapshot.value as Map<dynamic,dynamic>;
          var tmp = dataSnapshot.child("childAims").value as Map<dynamic, dynamic>?;
          Map<String, int> childAims = {};
          if(tmp!=null){
            tmp.forEach((key, value) {
              childAims[key] = (int.parse(value.toString()));
            });
          }

          var wd =  WishData(
            id: int.parse(dataList['id'].toString()),
            text: dataList['text'],
            description: dataList['subText'] ?? "",
            color: Color(int.parse(dataList['color'].toString())),
            parentId: int.parse(dataList['parentId'].toString()),
            affirmation: dataList['affirmation'] ?? '',
          );
          wd.childAims = childAims;
          return wd;
      }
    }
    return null;
  }

  Future createSphereWish(WishData wd, int currentMoonId) async {
    if(_auth.currentUser!=null){
      // Преобразуем каждый объект в Map
        Map<String, dynamic> dataMap = {
          'id': wd.id,
          'text': wd.text,
          'subText': wd.description,
          'childAims': wd.childAims,
          'color': wd.color.value, // Сохраняем цвет как строку
          'parentId': wd.parentId,
          'affirmation': wd.affirmation
        };
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("spheres").child(wd.id.toString()).set(
          dataMap
      );
    }
  }
  Future deleteSphereWish(int wdid, int currentMoonId) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("spheres").child(wdid.toString()).remove();
    }
  }
  Future changeWishStatus(int id, int currentMoonId, bool status) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("spheres").child(id.toString()).child("isChecked").set(status);
    }
  }

  Future<int?> createAim(AimData ad, int parentWishId, int currentMoonId) async {
    if(_auth.currentUser!=null){
      //Получаем последний идентификатор
      final DataSnapshot snapshot = (await userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("aims").orderByKey().limitToLast(1).once()).snapshot;
      int index = 0;
      if(snapshot.value!=null){
        index = int.parse(snapshot.children.last.key!)+1;
      }
      // Преобразуем каждый объект в Map
      Map<String, dynamic> dataMap = {
        'id': index,
        'parentId': parentWishId,
        'text': ad.text,
        'subText': ad.description,
        'childTasks': ad.childTasks,
        'isChecked': false
      };
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("aims").child(index.toString()).set(
          dataMap
      );
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("spheres").child(parentWishId.toString()).child("childAims").push().set(
          index
      );
      return index;
    }
    return null;
  }
  Future<AimData?> getMyAim(int id, int moonId) async{
    if(_auth.currentUser!=null) {
      DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
          .child("moonlist").child(moonId.toString()).child("aims").child(id.toString())
          .once()).snapshot;
      if (dataSnapshot.children.isNotEmpty) {
        final Map<dynamic, dynamic> dataList = dataSnapshot.value as Map<dynamic,dynamic>;
        return AimData(
          id: int.parse(dataList['id'].toString()),
          text: dataList['text'],
          description: dataList['subText'] ?? "",
          parentId: int.parse(dataList['parentId'].toString()),
          isChecked: dataList['isChecked']
        );
      }
    }
    return null;
  }
  Future<void> updateAim(AimData ad, int currentMoonId) async {
    if(_auth.currentUser!=null){
      // Преобразуем каждый объект в Map
      Map<String, dynamic> dataMap = {
        'id': ad.id,
        'text': ad.text,
        'subText': ad.description,
        'childTasks': ad.childTasks,
        'isChecked': false
      };
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("aims").child(ad.id.toString()).set(
          dataMap
      );
    }
  }
  Future deleteAim(int id, int currentMoonId) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("aims").child(id.toString()).remove();
    }
  }
  Future changeAimStatus(int id, int currentMoonId, bool status) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("aims").child(id.toString()).child("isChecked").set(status);
    }
  }

  Future<int?> createTask(TaskData td, int parentAimId, int currentMoonId) async {
    if(_auth.currentUser!=null){
      //Получаем последний идентификатор
      final DataSnapshot snapshot = (await userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("tasks").orderByKey().limitToLast(1).once()).snapshot;
      int index = 0;
      if(snapshot.value!=null){
        index = int.parse(snapshot.children.last.key!)+1;
      }
      // Преобразуем каждый объект в Map
      Map<String, dynamic> dataMap = {
        'id': index,
        'text': td.text,
        'subText': td.description,
        'isChecked': false
      };
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("tasks").child(index.toString()).set(
          dataMap
      );
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("aims").child(parentAimId.toString()).child("childTasks").push().set(
          index
      );
      return index;
    }
    return null;
  }
  Future<TaskData?> getMyTask(int id, int moonId) async{
    if(_auth.currentUser!=null) {
      DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
          .child("moonlist").child(moonId.toString()).child("tasks").child(id.toString())
          .once()).snapshot;
      if (dataSnapshot.children.isNotEmpty) {
        final Map<dynamic, dynamic> dataList = dataSnapshot.value as Map<dynamic,dynamic>;
        return TaskData(
            id: int.parse(dataList['id'].toString()),
            text: dataList['text'],
            description: dataList['subText'] ?? "",
            parentId: int.parse(dataList['parentId'].toString()),
            isChecked: dataList['isChecked']
        );
      }
    }
    return null;
  }
  Future updateTask(TaskData td, int currentMoonId) async {
    if(_auth.currentUser!=null){
      // Преобразуем каждый объект в Map
      Map<String, dynamic> dataMap = {
        'id': td.id,
        'parentId': td.parentId,
        'text': td.text,
        'subText': td.description,
        'isChecked': false
      };
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("tasks").child(td.id.toString()).set(
          dataMap
      );
    }
  }
  Future deleteTask(int id,  int currentMoonId) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("tasks").child(id.toString()).remove();
    }
  }
  Future changeTaskStatus(int id, int currentMoonId, bool status) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("tasks").child(id.toString()).child("isChecked").set(status);
    }
  }

  Future addDiary(List<CardData> data, int moonId) async {
    if(_auth.currentUser!=null){
      if(data.length>1){
        List<Map<String, dynamic>> diary = [];
        data.forEach((element) {
          diary.add(
              {
                'id': element.id,
                'emoji': element.emoji,
                'title': element.title,
                'description': element.description,
                'text': element.text,
                'color': element.color.value
              }
          );
        });
        userRef.child(_auth.currentUser!.uid).child("moonlist").child(moonId.toString()).child("diary").set(
            diary
        );
      }else{
        Map<String, dynamic> dataMap ={
          'id': data.last.id,
          'emoji': data.last.emoji,
          'title': data.last.title,
          'description': data.last.description,
          'text': data.last.text,
          'color': data.last.color.value
        };
        userRef.child(_auth.currentUser!.uid).child("moonlist").child(moonId.toString()).child("diary").child(data.last.id.toString()).set(
            dataMap
        );
      }
    }
  }
  Future updateDiary(CardData data, int moonId) async {
    if(_auth.currentUser!=null){
        Map<String, dynamic> dataMap ={
          'id': data.id,
          'emoji': data.emoji,
          'title': data.title,
          'description': data.description,
          'text': data.text,
          'color': data.color.value
        };
        userRef.child(_auth.currentUser!.uid).child("moonlist").child(moonId.toString()).child("diary").child(data.id.toString()).set(
            dataMap
        );
    }
  }
  Future<List<CardData>?> getDiaryList(int moonId) async{
    if(_auth.currentUser!=null) {
      List<CardData> diaryList = [];
      DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
          .child("moonlist").child(moonId.toString()).child("diary")
          .once()).snapshot;
      if (dataSnapshot.children.isNotEmpty) {
        dataSnapshot.children.forEach((element) {
          final Map<dynamic, dynamic> dataList = element.value as Map<dynamic,dynamic>;
          diaryList.add(CardData(
              id: int.parse(dataList['id'].toString()),
              emoji: dataList['emoji'],
              title: dataList['title'],
              description: dataList['description'],
              text: dataList['text'],
              color: Color(int.parse(dataList['color'].toString())),
          ));
        });
      }
      return diaryList;
    }
    return null;
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

  static saveAim(){
    return true;
  }
}
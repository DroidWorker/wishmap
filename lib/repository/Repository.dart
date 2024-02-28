import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
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

  Future<int?> getLastImageId() async{
    if(_auth.currentUser!=null){
      DataSnapshot snapshot = (await userRef.child(_auth.currentUser!.uid).child("images").once()).snapshot;
      if(snapshot.children.isNotEmpty){
        return int.parse(snapshot.children.last.key!);
      }else {
        return 0;
      }
    }
    return null;
  }

  Future<Map<int, String>> fetchImages(int id) async {
    DatabaseReference reference = userRef.child(_auth.currentUser!.uid).child("images");

    DataSnapshot snapshot = (await reference.orderByKey().startAt(id.toString()).once()).snapshot;

    Map<int, String> photos = {};

    // Iterate through the snapshot to get photo strings
    if(snapshot.value!=null){
      for (var element in snapshot.children) {
        if(element.key!=null)photos[int.parse(element.key!)] = element.value.toString();
      }
      return photos;
    }

    return {};
  }

  Future<int> getLastMoonSyncData(int moonId) async{
    if(_auth.currentUser!=null){
      DataSnapshot snapshot = (await userRef.child(_auth.currentUser!.uid).child("moonlist").child(moonId.toString()).child("lastSyncDate").once()).snapshot;
      if(snapshot.value!=null){
        return int.parse(snapshot.value.toString());
      }
    }
    return -1;
  }

  Future<Uint8List?> getImage(int id) async{
    if(_auth.currentUser!=null){
      DataSnapshot snapshot = (await userRef.child(_auth.currentUser!.uid).child("images").child(id.toString()).once()).snapshot;
      if(snapshot.value!=null){
        return base64Decode(snapshot.value.toString());
      }
    }
    return null;
  }

  Future addImage(int id, Uint8List image) async{
    if(_auth.currentUser!=null){
      String encodedImage = base64Encode(image);
      userRef.child(_auth.currentUser!.uid).child("images").child(id.toString()).set(
          encodedImage
      );
    }
  }

  Future updateMoonSync(int moonId, int timestamp)async {
    if (_auth.currentUser != null) {
      (await userRef.child(_auth.currentUser!.uid).child("moonlist").child(moonId.toString()).child("lastSyncDate").set(
        timestamp
      ));
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
        await userRef.child(_auth.currentUser!.uid).child("moonlist").child(moonItem.id.toString()).set({
          'text': moonItem.text,
          'date': moonItem.date,
          'filling': moonItem.filling
        });

        // Записываем данные для circles, используя индексы из объектов
        Map<String, dynamic> circleDataMap = {};

        for (CircleData circleData in defaultCircles) {
          String circleId = circleData.id.toString();
          circleDataMap[circleId] = {
            "id": circleData.id,
            'prevId': circleData.prevId,
            'nextId': circleData.nextId,
            'text': circleData.text,
            'subText': circleData.subText,
            'color': circleData.color.value,
            'parentId': circleData.parenId,
            'isActive': circleData.isActive,
            'affirmation': circleData.affirmation,
          };
        }
        await userRef.child(_auth.currentUser!.uid).child("moonlist").child(moonItem.id.toString()).child("spheres").set(
          circleDataMap
        );
        //updateMoonSync(moonItem.id);
    }
  }
  Future addAllCircles(List<CircleData> circles, int moonId) async {
    if(_auth.currentUser!=null){
      // Записываем данные для circles, используя индексы из объектов
      Map<String, dynamic> circleDataMap = {};

      for (CircleData wishData in circles) {
        String circleId = wishData.id.toString();
        circleDataMap[circleId] = {
          "id": wishData.id,
          "prevId": wishData.prevId,
          "nextId": wishData.nextId,
          'text': wishData.text,
          'subText': wishData.subText,
          'color': wishData.color.value,
          'parentId': wishData.parenId,
          'isActive': wishData.isActive,
          'affirmation': wishData.affirmation,
          "photosIds": wishData.photosIds,
          "isChecked": wishData.isChecked
        };
      }
      await userRef.child(_auth.currentUser!.uid).child("moonlist").child(moonId.toString()).child("spheres").set(
          circleDataMap
      );
      //updateMoonSync(moonId);
    }
  }
  Future addAllAims(List<AimData> aims, int moonId) async {
    if(_auth.currentUser!=null){
      // Записываем данные для circles, используя индексы из объектов
      Map<String, dynamic> circleDataMap = {};

      for (AimData aimData in aims) {
        String circleId = aimData.id.toString();
        circleDataMap[circleId] = {
          "id": aimData.id,
          'text': aimData.text,
          'subText': aimData.description,
          'parentId': aimData.parentId,
          "isChecked": aimData.isChecked,
          "isActive": aimData.isActive,
          'childTask': aimData.childTasks.asMap()
        };
      }
      await userRef.child(_auth.currentUser!.uid).child("moonlist").child(moonId.toString()).child("aims").set(
          circleDataMap
      );
      //updateMoonSync(moonId);
    }
  }
  Future addAllTasks(List<TaskData> tasks, int moonId) async {
    if(_auth.currentUser!=null){
      // Записываем данные для circles, используя индексы из объектов
      Map<String, dynamic> circleDataMap = {};

      for (TaskData taskData in tasks) {
        String circleId = taskData.id.toString();
        circleDataMap[circleId] = {
          "id": taskData.id,
          'text': taskData.text,
          'subText': taskData.description,
          'parentId': taskData.parentId,
          "isChecked": taskData.isChecked,
          "isactive": taskData.isActive
        };
      }
      await userRef.child(_auth.currentUser!.uid).child("moonlist").child(moonId.toString()).child("tasks").set(
          circleDataMap
      );
      //updateMoonSync(moonId);
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
              nextId: dataList['nextId'] == null ? -1 : (dataList['nextId'] is int ? dataList['nextId'] : int.tryParse(dataList['nextId']) ?? -1),
              prevId: dataList['prevId'] == null ? -1 : (dataList['prevId'] is int ? dataList['prevId'] : int.tryParse(dataList['prevId']) ?? -1),
              text: dataList['text'],
            subText: dataList['subText'] ?? "",
            color: Color(int.parse(dataList['color'].toString())),
            parenId: int.parse(dataList['parentId'].toString()),
            photosIds: dataList['photosIds']??"",
            affirmation: dataList['affirmation']??"",
            isChecked: dataList['isChecked']??false,
            isActive: dataList["isActive"]??true,
            isHidden: dataList['isHidden']??false
          );
          circleDataList.add(circleData);
        });
      }
      return circleDataList;
    }
    return null;
  }

  Future<List<WishData>?> getWishes(int moonId) async{
    List<WishData> circleDataList = [];

    if(_auth.currentUser!=null) {
      DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
          .child("moonlist").child(moonId.toString()).child("spheres")
          .once()).snapshot;
      if (dataSnapshot.children.isNotEmpty) {
        dataSnapshot.children.forEach((element) {
          final Map<dynamic, dynamic> dataList = element.value as Map<dynamic,dynamic>;
          WishData circleData = WishData(
              id: int.parse(element.key.toString()),
              nextId: dataList['nextId'] == null ? -1 : (dataList['nextId'] is int ? dataList['nextId'] : int.tryParse(dataList['nextId']) ?? -1),
              prevId: dataList['prevId'] == null ? -1 : (dataList['prevId'] is int ? dataList['prevId'] : int.tryParse(dataList['prevId']) ?? -1),
              text: dataList['text'].toString(),
              description: dataList['subText'].toString() ?? "",
              color: Color(int.parse(dataList['color'].toString())),
              parentId: int.parse(dataList['parentId'].toString()),
              photoIds: dataList['photosIds']??"",
              affirmation: dataList['affirmation']??""
          )..isChecked = dataList['isChecked']??false
          ..isActive = dataList['isActive']??true
          ..isHidden = dataList['isHidden']??false;
          if(dataList['childAims']!=null){
            final Map<dynamic, dynamic> aimsData = dataList['childAims'] as Map<dynamic, dynamic>;
            final Map<String, int> aims = {};
            aimsData.forEach((key, value) {
              if (value is int) {
                aims[key]=value;
              }
            });
            circleData.childAims = aims;
          }
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
              parentId: int.parse(dataList['parentId'].toString()),
              text: dataList['text'],
              isChecked: dataList['isChecked'],
            isActive: dataList['isActive']
          ));
        });
      }
      return tasksList;
    }
    return null;
  }

  Future<List<TaskData>?> getMyTasksData(int moonId) async{
    if(_auth.currentUser!=null) {
      List<TaskData> tasksList = [];
      DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
          .child("moonlist").child(moonId.toString()).child("tasks")
          .once()).snapshot;
      if (dataSnapshot.children.isNotEmpty) {
        dataSnapshot.children.forEach((element) {
          final Map<dynamic, dynamic> dataList = element.value as Map<dynamic,dynamic>;
          tasksList.add(TaskData(
              id: int.parse(dataList['id'].toString()),
              parentId: int.parse(dataList['parentId'].toString()),
              text: dataList['text'],
              description: dataList['subText'],
              isChecked: dataList['isChecked'],
            isActive: dataList['isActive']??false
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
              parentId: int.parse(dataList['parentId'].toString()),
              text: dataList['text'],
              isChecked: dataList['isChecked'],
            isActive: dataList['isActive']
          ));
        });
      }
      return aimsList;
    }
    return null;
  }

  Future<List<AimData>?> getMyAimsData(int moonId) async{
    if(_auth.currentUser!=null) {
      List<AimData> aimsList = [];
      DataSnapshot dataSnapshot = (await userRef.child(_auth.currentUser!.uid)
          .child("moonlist").child(moonId.toString()).child("aims")
          .once()).snapshot;
      if (dataSnapshot.children.isNotEmpty) {
        dataSnapshot.children.forEach((element) {
          final Map<dynamic, dynamic> dataList = element.value as Map<dynamic,dynamic>;
          Map<dynamic, dynamic> childTasksMap = {};
          if (dataList['childTasks'] != null) {
            if (dataList['childTasks'] is List) {
              // Преобразовать список в карту, если это необходимо
              for (var i = 0; i < dataList['childTasks'].length; i++) {
                childTasksMap[i] = dataList['childTasks'][i];
              }
            } else if (dataList['childTasks'] is Map) {
              // Просто присвоить, если уже является картой
              childTasksMap = Map<dynamic, dynamic>.from(dataList['childTasks']);
            } else {
              // Обработка других случаев, если необходимо
            }
          }
          List<int> childTasksList = childTasksMap.values.map((value) => int.parse(value.toString())).toList();
          aimsList.add(AimData(
              id: int.parse(dataList['id'].toString()),
              parentId: int.parse(dataList['parentId'].toString()),
              text: dataList['text'],
              isChecked: dataList['isChecked'],
              description: dataList['subText'],
            isActive: dataList['isActive']??false
          )..childTasks = childTasksList);
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
              parentId: dataList['parentId'],
            isActive: dataList['isActive']??true,
            isHidden: dataList['isHidden']??false
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
            nextId: dataList['nextId']==null?-1:int.tryParse(dataList['nextId'])??-1,
            prevId: dataList['prevId']==null?-1:int.tryParse(dataList['prevId'])??-1,
            text: dataList['text'],
            description: dataList['subText'] ?? "",
            color: Color(int.parse(dataList['color'].toString())),
            parentId: int.parse(dataList['parentId'].toString()),
            photoIds: dataList['photosIds'].toString()??"",
            affirmation: dataList['affirmation'] ?? '',
          );
          wd.isActive = dataList['isActive']??true;
          wd.childAims = childAims;
          wd.isChecked = dataList['isChecked']??false;
          wd.isHidden = dataList['isHidden']??false;
          return wd;
      }
    }
    return null;
  }

  Future createSphereWish(WishData wd, int currentMoonId) async {
    if(_auth.currentUser!=null){
      String photosId = "";
      wd.photos.forEach((key, value) {
        if(photosId.isNotEmpty)photosId+="|";
        photosId+="$key";
        addImage(key, value);
      });
      // Преобразуем каждый объект в Map
        Map<String, dynamic> dataMap = {
          'id': wd.id,
          'prevId': wd.prevId,
          'nextId': wd.nextId,
          'text': wd.text,
          'subText': wd.description,
          'childAims': wd.childAims,
          'color': wd.color.value, // Сохраняем цвет как строку
          'parentId': wd.parentId,
          'photosIds': photosId,
          'affirmation': wd.affirmation,
          'isActive': true,
          'isHidden': false,
        };
      await userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("spheres").child(wd.id.toString()).set(
          dataMap
      );
      //updateMoonSync(currentMoonId);
    }
  }
  Future deleteSphereWish(int wdid, int currentMoonId) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("spheres").child(wdid.toString()).remove();
      //updateMoonSync(currentMoonId);
    }
  }
  Future updateNeighbour(int sphereId, bool updateNextId, int newId, int currentMoonId) async {
    if(_auth.currentUser!=null){
      updateNextId?userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("spheres").child(sphereId.toString()).child("nextId").set(newId):
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("spheres").child(sphereId.toString()).child("prevId").set(newId);
      //updateMoonSync(currentMoonId);
    }
  }
  Future changeWishStatus(int id, int currentMoonId, bool status) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("spheres").child(id.toString()).child("isChecked").set(status);
      //updateMoonSync(currentMoonId);
    }
  }
  Future activateWish(int id, int currentMoonId, bool status) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("spheres").child(id.toString()).child("isActive").set(status);
      //updateMoonSync(currentMoonId);
    }
  }
  Future hideWish(int id, int currentMoonId, bool isHide) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("spheres").child(id.toString()).child("isHidden").set(isHide);
      //updateMoonSync(currentMoonId);
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
        'isChecked': false,
        'isActive': ad.isActive
      };
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("aims").child(index.toString()).set(
          dataMap
      );
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("spheres").child(parentWishId.toString()).child("childAims").push().set(
          index
      );
      //updateMoonSync(currentMoonId);
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
        var tmp = dataSnapshot.child("childTasks").value as Map<dynamic, dynamic>?;
        List<int> childTasks = [];
        if(tmp!=null){
          tmp.forEach((key, value) {
            childTasks.add(int.parse(value.toString()));
          });
        }
        var ad = AimData(
          id: int.parse(dataList['id'].toString()),
          text: dataList['text'],
          description: dataList['subText'] ?? "",
          parentId: int.parse(dataList['parentId'].toString()),
          isChecked: dataList['isChecked'],
            isActive: dataList['isActive']
        );
        ad.childTasks = childTasks;
        return ad;
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
        'parentId': ad.parentId,
        'childTasks': ad.childTasks,
        'isChecked': false,
        'isActive': ad.isActive
      };
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("aims").child(ad.id.toString()).set(
          dataMap
      );
      //updateMoonSync(currentMoonId);
    }
  }
  Future deleteAim(int id, int currentMoonId) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("aims").child(id.toString()).remove();
      //updateMoonSync(currentMoonId);
    }
  }
  Future changeAimStatus(int id, int currentMoonId, bool status) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("aims").child(id.toString()).child("isChecked").set(status);
      //updateMoonSync(currentMoonId);
    }
  }
  Future activateAim(int id, int currentMoonId, bool status) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("aims").child(id.toString()).child("isActive").set(status);
      //updateMoonSync(currentMoonId);
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
        'parentId': parentAimId,
        'subText': td.description,
        'isChecked': false,
        'isActive': td.isActive
      };
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("tasks").child(index.toString()).set(
          dataMap
      );
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("aims").child(parentAimId.toString()).child("childTasks").push().set(
          index
      );
      //updateMoonSync(currentMoonId);
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
            isChecked: dataList['isChecked'],
          isActive: dataList['isActive']
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
        'isChecked': false,
        'isActive': td.isActive
      };
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("tasks").child(td.id.toString()).set(
          dataMap
      );
      //updateMoonSync(currentMoonId);
    }
  }
  Future deleteTask(int id,  int currentMoonId) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("tasks").child(id.toString()).remove();
      //updateMoonSync(currentMoonId);
    }
  }
  Future changeTaskStatus(int id, int currentMoonId, bool status) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("tasks").child(id.toString()).child("isChecked").set(status);
      //updateMoonSync(currentMoonId);
    }
  }
  Future activateTask(int id, int currentMoonId, bool status) async {
    if(_auth.currentUser!=null){
      userRef.child(_auth.currentUser!.uid).child("moonlist").child(currentMoonId.toString()).child("tasks").child(id.toString()).child("isActive").set(status);
      //updateMoonSync(currentMoonId);
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
      //updateMoonSync(moonId);
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
        //updateMoonSync(moonId);
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
}
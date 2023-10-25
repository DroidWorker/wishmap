import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/repository/Repository.dart';
import 'package:wishmap/repository/local_repository.dart';
import 'package:dart_suncalc/suncalc.dart';

import 'data/models.dart';

class AppViewModel with ChangeNotifier {
  LocalRepository localRep = LocalRepository();
  Repository repository = Repository();

  MessageError messageError = MessageError();

  //auth/regScreen
  ValueNotifier<AuthData?> authDataNotifier = ValueNotifier<AuthData?>(null);
  AuthData? get authData => authDataNotifier.value;

  set authData(AuthData? value) {
    authDataNotifier.value = value;
    notifyListeners();
  }
  ProfileData? profileData;
  //moonListScreen
  List<MoonItem> moonItems = [];
  //mainScreen
  MainScreenState? mainScreenState;
  List<MainCircle> mainCircles = [];
  List<Circle> currentCircles = [];
  //wishScreen
  WishScreenState? wishScreenState;
  //MyTasksScreen
  List<TaskItem> taskItems = [];
  //MyAimsScreen
  List<AimItem> aimItems = [];
  //MyWishesScreen
  List<WishItem> wishItems = [];

  Future<void> init() async {
    authData = await localRep.getAuth();
    profileData = await localRep.getProfile();
    notifyListeners();
  }

  void addError(String text){
    messageError.text = text;
    print("eeeeeerrrrror $text");
    notifyListeners();
  }

  Future<void> signIn(String login, String password) async{
    await localRep.saveAuth(login, password);
    try {
      ProfileData? pd = await repository.signIn(login, password);
      if (pd != null) {
        await localRep.saveProfile(pd);
        init();
      } else {
        throw Exception("unknown error #vm001");
      }
    }catch(ex){
      addError(ex.toString().replaceAll("Exception:", ""));
      throw Exception("no access #vm002");
    }
  }
  Future<void> register(ProfileData pd, AuthData ad) async{
    try {
      String? userUid = await repository.registration(pd, ad);
      if(userUid!=null){
        pd.id = userUid;
        localRep.saveProfile(pd);
        localRep.saveAuth(ad.login, ad.password);
        init();
      }
    }catch(ex){
      addError(ex.toString());
      throw Exception("no access #vm003");
    }
  }

  Future<void> getMoons() async{
    List<CircleData> defaultCircles = [
      CircleData(id: 0, text: 'Я', subText: "состояние", color: const Color(0xFF000000), parenId: -1),
      CircleData(id: 1, text: 'Икигай', color: const Color(0xFFFF0000), parenId: 0),
      CircleData(id: 2, text: 'Любовь', color: const Color(0xFFFF006B), parenId: 0),
      CircleData(id: 3, text: 'Дети', color: const Color(0xFFD9D9D9), parenId: 0),
      CircleData(id: 4, text: 'Путешествия', color: const Color(0xFFFFE600), parenId: 0),
      CircleData(id: 5, text: 'Карьера', color: const Color(0xFF0029FF), parenId: 0),
      CircleData(id: 6, text: 'Образование', color: const Color(0xFF46C8FF), parenId: 0),
      CircleData(id: 7, text: 'Семья', color: const Color(0xFF3FA600), parenId: 0),
      CircleData(id: 8, text: 'Богатство', color: const Color(0xFFB4EB5A), parenId: 0),
    ];
    try {
      DateTime now = DateTime.now();
      final moonIllumination = SunCalc.getMoonIllumination(now);
      moonItems = (await repository.getMoonList())??[];
      if(moonItems.isEmpty||isDateAfter(now, moonItems.last.date)) {
        int moonId = moonItems.isNotEmpty?moonItems.last.id + 1:0;
        moonItems.add(MoonItem(id: moonId,
            filling: moonIllumination.phase,
            text: "Я",
            date: "${now.day.toString().padLeft(2, '0')}.${now.month.toString()
                .padLeft(2, '0')}.${now.year}"));
        if(moonItems.length==1) {
          repository.addMoon(moonItems.last, defaultCircles);
        }else{
          List<CircleData> moonCircles = (await repository.getSpheres(moonId-1))??[];
          if(moonCircles.isNotEmpty){
            repository.addMoon(moonItems.last, moonCircles);
          }else{
            repository.addMoon(moonItems.last, defaultCircles);
          }
        }
      }
      notifyListeners();
    }catch(ex){
      addError(ex.toString());
    }
  }

  bool isDateAfter(DateTime firstDate, String secondDate){
// Преобразование строки в формат "yyyy-MM-dd"
    var parts = secondDate.split(".");
    String formattedDateString = parts[2]+parts[1]+parts[0];

// Преобразование в DateTime
    DateTime dateFromString = DateTime.parse(formattedDateString);

    DateTime currentDate = DateTime(firstDate.year, firstDate.month, firstDate.day);

// Сравнение
    if (currentDate.isAfter(dateFromString)) {
      return true;
    } else if (currentDate.isBefore(dateFromString)) {
      return false;
    } else {
      return false;
    }
  }

  Future<void> startMainScreen(MoonItem mi) async {
    if (mainScreenState == null) {
      mainScreenState = MainScreenState(moon: mi, musicId: 0);
      try {
        mainScreenState!.allCircles = (await repository.getSpheres(mi.id)) ?? [];
        var ms = mainScreenState!.allCircles.first;
        mainCircles.add(MainCircle(id: ms.id, coords: Pair(key: 0.0, value: 0.0), text: ms.text, color: ms.color));
        var cc = mainScreenState!.allCircles.where((element) => element.parenId == mainCircles.last.id).toList();
        cc.forEach((element) {
          currentCircles.add(Circle(id: element.id, text: element.text, color: element.color));
        });
      } catch (ex) {
        addError(ex.toString());
      }
      notifyListeners();
    }
  }

  List<Circle>? openSphere(int id) {
    if (mainScreenState != null&&mainScreenState!.allCircles.isNotEmpty) {
      try {
        var mc = mainScreenState!.allCircles.firstWhere((element) => element.id == id);
        mainCircles.add(MainCircle(id: mc.id, coords: Pair(key: 0.0, value: 0.0), text: mc.text, color: mc.color));
        var cc = mainScreenState!.allCircles.where((element) => element.parenId == id).toList();
        currentCircles.clear();
        cc.forEach((element) {
          currentCircles.add(Circle(id: element.id, text: element.text, color: element.color));
        });
      } catch (ex) {
        addError(ex.toString());
      }
      return currentCircles;
    }
    return null;
  }

  Future<void> startWishScreen(int wishId, int parentId) async{
    try {
      WishData wdItem;
      var tmp = mainScreenState!.allCircles.where((element) => element.id==wishId);
      if(tmp.isNotEmpty){
        wdItem = (await repository.getMyWish(wishId, mainScreenState!.moon.id)) ?? WishData(id: -100, parentId: 0, text: "не удалось загрузить данные", description: "", affirmation: "", color: Colors.transparent);
      }else{
        wdItem = WishData(id: wishId, parentId: parentId, text: "", description: "", affirmation: "", color: Colors.green);
      }
      wishScreenState = WishScreenState(wish: wdItem);
      notifyListeners();
    }catch(ex){
      addError(ex.toString());
    }
  }

  Future<void> startMyTasksScreen() async{
    try {
      taskItems = (await repository.getMyTasks(mainScreenState?.moon.id??0)) ?? [];
      notifyListeners();
    }catch(ex){
      addError(ex.toString());
    }
  }
  Future<List<TaskItem>?> getTasksForAim(int aimId) async {
    try {
      var list = (await repository.getAimsChildTasks(
          aimId, mainScreenState?.moon.id ?? 0)) ?? [];
      if (list.isNotEmpty){
        if(taskItems.isNotEmpty){
          return taskItems.where((element) => list.contains(element.id)).toList();
        }else{
          taskItems = (await repository.getMyTasks(mainScreenState?.moon.id??0)) ?? [];
          return taskItems.where((element) => list.contains(element.id)).toList();
        }
      }else {
        return null;
      }
    }catch(ex){
      addError("Ошибка загрузки задач: $ex");
    }
    return null;
  }

  Future<void> startMyAimsScreen() async{
    try {
      aimItems = (await repository.getMyAims(mainScreenState?.moon.id??0)) ?? [];
      notifyListeners();
    }catch(ex){
      addError(ex.toString());
    }
  }
  Future<List<AimItem>?> getAimsForCircles(int sphereId) async {
    try {
      var list = (await repository.getSpheresChildAims(
          sphereId, mainScreenState?.moon.id ?? 0)) ?? [];
      if (list.isNotEmpty){
        if(aimItems.isNotEmpty){
          return aimItems.where((element) => list.contains(element.id)).toList();
        }else{
          aimItems = (await repository.getMyAims(mainScreenState?.moon.id??0)) ?? [];
          return aimItems.where((element) => list.contains(element.id)).toList();
        }
      }else {
        return null;
      }
    }catch(ex){
      addError("Ошибка загрузки задач: $ex");
    }
    return null;
  }

  Future<void> startMyWishesScreen() async{
    try {
      wishItems = (await repository.getMyWishs(mainScreenState?.moon.id??0)) ?? [];
      notifyListeners();
    }catch(ex){
      addError(ex.toString());
    }
  }

  Future<void> createNewSphereWish(WishData wd) async{
    try {
      await repository.createSphereWish(wd, mainScreenState?.moon.id??0);
      mainScreenState!.allCircles.add(CircleData(id: wd.id, text: wd.text, color: wd.color, parenId: wd.parentId));
    }catch(ex){
      addError("сфера не была сохранена: $ex");
    }
  }
  Future<void> deleteSphereWish(WishData wd) async{
    try {
      await repository.deleteSphereWish(wd, mainScreenState?.moon.id??0);
    }catch(ex){
      addError("сфера не была удалена: $ex");
    }
  }

  Future<int?> createAim(AimData ad, int parentCircleId) async{
    try {
      int? aimId = (await repository.createAim(ad, parentCircleId, mainScreenState?.moon.id??0))??-1;
      aimItems.add(AimItem(id: aimId, text: ad.text, isChecked: ad.isChecked));
      return aimId;
    }catch(ex){
      addError(ex.toString());
    }
  }
  Future<void> deleteAim(int aimId) async{
    try {
      await repository.deleteAim(aimId, mainScreenState?.moon.id??0);
    }catch(ex){
      addError(ex.toString());
    }
  }
  Future<void> updateAimStatus(int aimId, bool status) async{
    try {
      await repository.changeAimStatus(aimId, mainScreenState?.moon.id??0, status);
    }catch(ex){
      addError(ex.toString());
    }
  }

  Future<void> createTask(TaskData ad, int parentAimId) async{
    try {
      await repository.createTask(ad, parentAimId, mainScreenState?.moon.id??0);
    }catch(ex){
      addError(ex.toString());
    }
  }
  Future<void> deleteTask(int taskId) async{
    try {
      await repository.deleteTask(taskId, mainScreenState?.moon.id??0);
    }catch(ex){
      addError(ex.toString());
    }
  }
  Future<void> updateTaskStatus(int taskId, bool status) async{
    try {
      await repository.changeTaskStatus(taskId, mainScreenState?.moon.id??0, status);
    }catch(ex){
      addError(ex.toString());
    }
  }
}
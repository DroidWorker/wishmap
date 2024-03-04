import 'dart:math';
import 'dart:typed_data';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/data/static_affirmations_women.dart';
import 'package:wishmap/repository/Repository.dart';
import 'package:wishmap/repository/photosSearch.dart';
import 'package:wishmap/repository/local_repository.dart';

import 'data/models.dart';

class AppViewModel with ChangeNotifier {
  LocalRepository localRep = LocalRepository();
  Repository repository = Repository();

  MessageError messageError = MessageError();

  var isDataFetched = 4;

  var connectivity = 'No Internet Connection';

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
  String mainhint = "";

  String get hint => mainhint;
  set onChange(VoidCallback callback) {
    _hintChanged = callback;
  }
  set hint(String value) {
    mainhint=value;
    _hintChanged?.call();
  }
  VoidCallback? _hintChanged;
  List<MainCircle> mainCircles = [];
  List<Circle> currentCircles = [];
  //mainSphereEdirtScreenn
  CircleData? mainSphereEditCircle;
  bool isChanged = false;
  //wishScreen
  WishScreenState? wishScreenState;
  //MyTasksScreen
  List<TaskItem> taskItems = [];
  //MyAimsScreen
  List<AimItem> aimItems = [];
  //MyWishesScreen
  List<WishItem> wishItems = [];
  //
  AimData? currentAim;
  TaskData? currentTask;
  //treeNodes
  List<MyTreeNode> myNodes = [];

  //images
  List<Uint8List> cachedImages = [];
  int lastImageId = -1;
  //gallery
  List<String> photoUrls = [];
  List<String> photopexelsUrls = [];

  //appcfg
  var isinLoading = false;

  //settings
  ActualizingSettingData settings = ActualizingSettingData();
  int backPressedCount = 0;

  List<CircleData> defaultCircles = [
    CircleData(id: 0, prevId: -1, nextId: 100, text: 'Я', subText: "состояние", color: const Color(0xFF000000), affirmation: defaultAffirmations.join("|"), parenId: -1)..shuffle=true..lastShuffle="${defaultAffirmations[Random().nextInt(defaultAffirmations.length)]}|${DateTime.now().weekday.toString()}",
    CircleData(id: 100, prevId: 0, nextId: 200, text: 'Икигай', color: const Color(0xFFFF0000), affirmation: defaultAffirmations.join("|"), parenId: 0)..shuffle=true..lastShuffle="${defaultAffirmations[Random().nextInt(defaultAffirmations.length)]}|${DateTime.now().weekday.toString()}",
    CircleData(id: 200, prevId: 100, nextId: 300, text: 'Любовь', color: const Color(0xFFFF006B), affirmation: defaultAffirmations.join("|"), parenId: 0)..shuffle=true..lastShuffle="${defaultAffirmations[Random().nextInt(defaultAffirmations.length)]}|${DateTime.now().weekday.toString()}",
    CircleData(id: 300, prevId: 200, nextId: 400, text: 'Дети', color: const Color(0xFFD9D9D9), affirmation: defaultAffirmations.join("|"), parenId: 0)..shuffle=true..lastShuffle="${defaultAffirmations[Random().nextInt(defaultAffirmations.length)]}|${DateTime.now().weekday.toString()}",
    CircleData(id: 400, prevId: 300, nextId: 500, text: 'Путешествия', color: const Color(0xFFFFE600), affirmation: defaultAffirmations.join("|"), parenId: 0)..shuffle=true..lastShuffle="${defaultAffirmations[Random().nextInt(defaultAffirmations.length)]}|${DateTime.now().weekday.toString()}",
    CircleData(id: 500, prevId: 400, nextId: 600, text: 'Карьера', color: const Color(0xFF0029FF), affirmation: defaultAffirmations.join("|"), parenId: 0)..shuffle=true..lastShuffle="${defaultAffirmations[Random().nextInt(defaultAffirmations.length)]}|${DateTime.now().weekday.toString()}",
    CircleData(id: 600, prevId: 500, nextId: 700, text: 'Образование', color: const Color(0xFF46C8FF), affirmation: defaultAffirmations.join("|"), parenId: 0)..shuffle=true..lastShuffle="${defaultAffirmations[Random().nextInt(defaultAffirmations.length)]}|${DateTime.now().weekday.toString()}",
    CircleData(id: 700, prevId: 600, nextId: 800, text: 'Семья', color: const Color(0xFF3FA600), affirmation: defaultAffirmations.join("|"), parenId: 0)..shuffle=true..lastShuffle="${defaultAffirmations[Random().nextInt(defaultAffirmations.length)]}|${DateTime.now().weekday.toString()}",
    CircleData(id: 800, prevId: 700, nextId: -1, text: 'Богатство', color: const Color(0xFFB4EB5A), affirmation: defaultAffirmations.join("|"), parenId: 0)..shuffle=true..lastShuffle="${defaultAffirmations[Random().nextInt(defaultAffirmations.length)]}|${DateTime.now().weekday.toString()}",
  ];
  //diaryScreen
  List<CardData> diaryItems = [
    CardData(id: 0, emoji: "😃", title: "Благодраность", description: "Чтобы разблокировать путь к желаниям, каждый день начинай с благодарности", text: "no text", color: const Color.fromARGB(255, 233, 255, 250)),
    CardData(id: 1, emoji: "🌟", title: "Виденье на 5 лет", description: "Глабольное видиние своей жизни лежит в основе всех твоих желаний", text: "no text", color: const Color.fromARGB(255, 226, 246, 255)),
    CardData(id: 2, emoji: "🎉", title: "Лучший день", description: "Опиши самый замечательный день или момент жизни за прошедший год", text: "no text", color: const Color.fromARGB(255, 255, 240, 233)),
    CardData(id: 3, emoji: "❤️", title: "100 желаний", description: "Создай свой банк желаний, пусть даже самых невообразимых, и пусть они хранятся здесь", text: "no text", color: const Color.fromARGB(255, 235, 229, 229)),
    CardData(id: 4, emoji: "🌺", title: "Мои сны", description: "Если записывыать свои сны каждый день, ты обретешь суперспособности", text: "no text",color: const Color.fromARGB(255, 244, 205, 221)),
    CardData(id: 5, emoji: "🍔", title: "Мои страхи", description: "Выписывай все свои страхи и они начнут растворятся сами собой", text: "no text", color: const Color.fromARGB(255, 238, 255, 210)),
   ];

  Future<void> init() async {
    authData = await localRep.getAuth();
    profileData = await localRep.getProfile();
    if(authData!=null)getMoons();
    settings = await localRep.getActSetting();
    notifyListeners();
  }

  void addError(String text){
    if(text!=messageError.text) {
      messageError.text = text;
      notifyListeners();
    }
  }

  Future clearLocalDB() async {
    await localRep.clearDatabase(mainScreenState?.moon.id??-1);
  }

  Map<String, int> getHintStates() {
    return localRep.getHintStates();
  }
  setHintState(String k, int v) {
    return localRep.saveHintState(k, v);
  }
  Future saveShuffle( int sphereId, bool shuffle, String lastShuffle) async {
    localRep.updateSphereShuffle(sphereId, shuffle, lastShuffle, mainScreenState!.moon.id);
  }
  saveSettings(){
    localRep.saveActSetting(settings);
  }

  Future searchImages(String query) async{
    photoUrls = await GRepository.searchImages(query);
    notifyListeners();
  }
  
  Future updateMoonSync(int moonId)async{
    final time= DateTime.timestamp().microsecondsSinceEpoch;
    localRep.updateMoonSync(moonId, time);
    if(connectivity!='No Internet Connection')repository.updateMoonSync(moonId, time);
  }

  Future<void> signIn(String login, String password) async{
    await localRep.saveAuth(login, password);
    try {
      ProfileData? pd = await repository.signIn(login, password);
      if (pd != null) {
        await localRep.saveProfile(pd);
        await init();
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
        await init();
      }
    }catch(ex){
      addError(ex.toString());
      throw Exception("no access #vm003");
    }
  }

  Future<void> getMoons() async{
    try {
      DateTime now = DateTime.now();

      var result = await Connectivity().checkConnectivity();
      if(moonItems.isEmpty){
        moonItems = (result!=ConnectivityResult.none)?
        ((await repository.getMoonList())??[]):
        (await localRep.getMoons());
        if((result!=ConnectivityResult.none)){
          //await localRep.clearMoons();
          final localMoons = await localRep.getMoons();
          for (var element in moonItems) {
            if(localMoons.where((e) => e.id==element.id).isEmpty)localRep.addMoon(element);
          }
        }
      }
      if(moonItems.isEmpty/*||isDateAfter(now, moonItems.last.date)*/) {
        int moonId = moonItems.isNotEmpty?moonItems.last.id + 1:0;
        moonItems.add(MoonItem(id: moonId,
            filling: 0.01,
            text: 'Я',
            date: "${now.day.toString().padLeft(2, '0')}.${now.month.toString()
                .padLeft(2, '0')}.${now.year}"));
        if(result!=ConnectivityResult.none){
          if(moonItems.length==1) {
            localRep.addAllMoons(moonItems.last, defaultCircles);
            repository.addMoon(moonItems.last, defaultCircles);
          }else{
            List<CircleData> moonCircles = (await repository.getSpheres(moonId-1))??[];
            if(moonCircles.isNotEmpty){
              for (int i=0; i<moonCircles.length; i++){
                moonCircles[i].isActive = false;
              }
              localRep.addAllMoons(moonItems.last, moonCircles);
              repository.addMoon(moonItems.last, moonCircles);
            }else{
              localRep.addAllMoons(moonItems.last, defaultCircles);
              repository.addMoon(moonItems.last, defaultCircles);
            }
          }
        }else{
          if(moonItems.length==1) {
            localRep.addAllMoons(moonItems.last, defaultCircles);
          }else{
            List<CircleData> moonCircles = await localRep.getAllMoonSpheres(moonId-1);
            if(moonCircles.isNotEmpty){
              for (int i=0; i<moonCircles.length; i++){
                moonCircles[i].isActive = false;
              }
              localRep.addAllMoons(moonItems.last, moonCircles);
            }else{
              localRep.addAllMoons(moonItems.last, defaultCircles);
            }
          }
        }
      }
      notifyListeners();
      lastImageId = await repository.getLastImageId()??-1;
    }catch(ex){
      addError(ex.toString());
    }
  }
  Future createNewMoon(String date) async{
    var result = await Connectivity().checkConnectivity();
    int moonId = moonItems.isNotEmpty?moonItems.last.id + 1:0;
    moonItems.add(MoonItem(id: moonId,
        filling: 0.01,
        text: 'Я',
        date: date));
    if(result!=ConnectivityResult.none){
      await repository.addMoon(moonItems.last, defaultCircles);
      await localRep.addAllMoons(moonItems.last, defaultCircles);
    }else{
      await localRep.addAllMoons(moonItems.last, defaultCircles);
    }
    notifyListeners();
  }
  Future duplicateLastMoon() async{
    DateTime now = DateTime.now();
    var result = await Connectivity().checkConnectivity();
    int moonId = moonItems.isNotEmpty?moonItems.last.id + 1:0;
    moonItems.add(MoonItem(id: moonId,
        filling: 0.01,
        text: 'Я',
        date: "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}"));
    if(result!=ConnectivityResult.none){
      if(moonItems.length==1) {
        await repository.addMoon(moonItems.last, defaultCircles);
        await localRep.addAllMoons(moonItems.last, defaultCircles);
      }else{
        try {
          List<CircleData> moonCircles = (await repository.getSpheres(
              moonId - 1)) ?? [];
          if (moonCircles.isNotEmpty) {
            for (int i = 0; i < moonCircles.length; i++) {
              moonCircles[i].isActive = false;
            }
            await repository.addMoon(moonItems.last, moonCircles);
            await localRep.addAllMoons(moonItems.last, moonCircles);
          } else {
            await repository.addMoon(moonItems.last, defaultCircles);
            await localRep.addAllMoons(moonItems.last, defaultCircles);
          }
        }catch(ex, s){
          print("shot errrrrrrrr $ex --- $s");
        }
      }
    }else{
      if(moonItems.length==1) {
        await localRep.addAllMoons(moonItems.last, defaultCircles);
      }else{
        List<CircleData> moonCircles = await localRep.getAllMoonSpheres(moonId-1);
        if(moonCircles.isNotEmpty){
          for (int i=0; i<moonCircles.length; i++){
            moonCircles[i].isActive = false;
          }
          await localRep.addAllMoons(moonItems.last, moonCircles);
        }else{
          addError("Ошибка! нет соединения!");
          //await localRep.addAllMoons(moonItems.last, defaultCircles);
        }
      }
    }
    List<AimData> aims = await localRep.getAllAimsData(moonId-1);
    if(aims.isEmpty) aims = await repository.getMyAimsData(moonId-1)?? [];
    aims.forEach((element) async {
      element.isActive=false;
      await localRep.addAim(element,moonId);
    });
    List<TaskData> tasks = await localRep.getAllTasksData(moonId-1);
    if(tasks.isEmpty) tasks = await repository.getMyTasksData(moonId-1)?? [];
    tasks.forEach((element) async {
      element.isActive=false;
      await localRep.addTask(element,moonId);
    });
    final diary = await localRep.getAllDiary(moonId-1);
    diary.forEach((element) async {
      await localRep.addDiary(element,moonId);
    });
    repository.addAllAims(aims, moonId);
    repository.addAllTasks(tasks, moonId);
    repository.addDiary(diary, moonId);
    notifyListeners();
  }

  Future getImages(List<int> ids) async {
    cachedImages.clear();
    isinLoading = true;
    for (var element in ids) {
      final photo = await localRep.getImage(element);
      //final photo = await repository.getImage(element);//replaced by localrep
      if(photo!=null)cachedImages.add(photo);
    }
    isinLoading = false;
    notifyListeners();
  }

  Future fetchMoons() async{
    final moons = (await repository.getMoonList())??[];
    for (var value in moons) {
      localRep.addMoon(value);
    }
  }

  Future fetchImages() async{
    final lastId = await localRep.getImageLastId();
    final images = await repository.fetchImages(lastId+1);
    images.forEach((key, value) {
      localRep.addImageStr(key, value);
    });
  }

  Future fetchSpheres(int moonId) async{
    final spheres = await repository.getWishes(moonId);
    spheres?.forEach((element) {
      localRep.addSphere(element,moonId);
    });
    isDataFetched--;
    updateMoonSync(moonId);
  }
  Future pushSpheres(int moonId) async{
    final spheres = await localRep.getAllMoonSpheres(moonId);
    repository.addAllCircles(spheres, moonId);
    isDataFetched--;
    updateMoonSync(moonId);
  }

  Future fetchAims(int moonId) async{
    final aims = await repository.getMyAimsData(moonId);
    aims?.forEach((element) {
      print("aaaaaaaaim ${element.text} - ${element.childTasks.length}");
      localRep.addAim(element,mainScreenState?.moon.id??-1);
    });
    isDataFetched--;
  }
  Future pushAims(int moonId) async{
    final aims = await localRep.getAllAimsData(moonId);
    repository.addAllAims(aims, moonId);
    isDataFetched--;
  }

  Future fetchTasks(int moonId) async{
    final aims = await repository.getMyTasksData(moonId);
    aims?.forEach((element) {
      localRep.addTask(element,mainScreenState?.moon.id??-1);
    });
    isDataFetched--;
  }
  Future pushTasks(int moonId) async{
    final tasks = await localRep.getAllTasksData(moonId);
    repository.addAllTasks(tasks, moonId);
    isDataFetched--;
  }

  Future fetchDiary(int moonId) async{
    final diary = await repository.getDiaryList(moonId);
    diary?.forEach((element) {
      localRep.addDiary(element,mainScreenState?.moon.id??-1);
    });
    isDataFetched--;
  }
  Future pushDiary(int moonId) async{
    final diary = await localRep.getAllDiary(moonId);
    repository.addDiary(diary, moonId);
    isDataFetched--;
  }

  Future fetchDatas(int moonId) async{
    if(connectivity!='No Internet Connection'){
      final dDB = await repository.getLastMoonSyncData(moonId);
      final dLoc = await localRep.getMoonLastSyncDate(moonId);
      debugPrint("datas update $dDB  $dLoc");
      if(dDB!=null&&dDB>dLoc) {
        debugPrint("fetchDatas");
        await localRep.clearDatabase(moonId);
        await fetchSpheres(moonId);
         fetchAims(moonId);
         fetchTasks(moonId);
         fetchDiary(moonId);
      }
      else if(dDB!=null&&dDB<dLoc){
        debugPrint("pushDatas");
        await pushSpheres(moonId);
        await pushAims(moonId);
        await pushTasks(moonId);
        await pushDiary(moonId);
      }
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
      isinLoading = true;
      mainScreenState = MainScreenState(moon: mi, musicId: 0);
      try {
        //mainScreenState!.allCircles = (await repository.getSpheres(mi.id)) ?? [];
        mainScreenState!.allCircles = (await localRep.getAllMoonSpheres(mi.id));
        if(mainScreenState!.allCircles.isEmpty) return;
        var ms = mainScreenState!.allCircles.first;
        mainCircles.add(MainCircle(id: ms.id, coords: Pair(key: 0.0, value: 0.0), text: ms.text, substring: ms.subText, color: ms.color, isActive: ms.isActive, isChecked: ms.isChecked));
        var cc = mainScreenState!.allCircles.where((element) => element.parenId == mainCircles.last.id).toList();
        currentCircles.clear();
        for (var element in cc) {
          if(!element.isHidden)currentCircles.add(Circle(id: element.id, parentId: element.parenId, prevId: element.prevId, nextId: element.nextId, text: element.text, color: element.color, isActive: element.isActive, isChecked: element.isChecked));
        }
        isinLoading=false;
        notifyListeners();
      } catch (ex, s) {
        addError("#579${ex.toString()}");
      }
    }else if(mainScreenState!.moon.id==mi.id){
      var tmp = List<CircleData>.from(mainScreenState!.allCircles);
      mainScreenState = MainScreenState(moon: mi, musicId: 0);
      try {
        mainScreenState!.allCircles = tmp;
        var ms = mainScreenState!.allCircles.first;
        mainCircles.add(MainCircle(id: ms.id, coords: Pair(key: 0.0, value: 0.0), text: ms.text, substring: ms.subText, color: ms.color, isActive: ms.isActive, isChecked: ms.isChecked));
        var cc = mainScreenState!.allCircles.where((element) => element.parenId == mainCircles.last.id).toList();
        currentCircles.clear();
        for (var element in cc) {
          if(!element.isHidden)currentCircles.add(Circle(id: element.id, parentId: element.parenId, prevId: element.prevId, nextId: element.nextId, text: element.text, color: element.color, isActive: element.isActive, isChecked: element.isChecked));
        }
        isinLoading=false;
        notifyListeners();
      } catch (ex) {
        addError("#578${ex.toString()}");
      }
    }
  }
  int getShowedCirclesCount(int parentId){
    var cc = mainScreenState!.allCircles.where((element) => (element.parenId == parentId)&&element.isHidden==false).toList();
    return cc.length;
  }

  List<Circle>? openSphere(int id) {
    if (mainScreenState != null&&mainScreenState!.allCircles.isNotEmpty) {
      try {
        var mc = mainScreenState!.allCircles.firstWhere((element) => element.id == id);
        id>mainCircles.last.id?mainCircles.add(MainCircle(id: mc.id, coords: Pair(key: 0.0, value: 0.0), text: mc.text, color: mc.color, isActive: mc.isActive, isChecked: mc.isChecked)):mainCircles.removeLast();
        var cc = mainScreenState!.allCircles.where((element) => element.parenId == id).toList();
        currentCircles.clear();
        for (var element in cc) {
          if(!element.isHidden)currentCircles.add(Circle(id: element.id, parentId: element.parenId, prevId: element.prevId, nextId: element.nextId, text: element.text, color: element.color, isActive: element.isActive, isChecked: element.isChecked));
        }
      } catch (ex) {
        addError("#5734${ex.toString()}");
      }
      return currentCircles;
    }
    return null;
  }

  Future<WishData> startWishScreen(int wishId, int parentId, {isUpdateScreen = false}) async{
    try {
      var result = await Connectivity().checkConnectivity();
      if(result == ConnectivityResult.none)  connectivity = 'No Internet Connection';
      isChanged = false;
      if(!isUpdateScreen){
        cachedImages.clear();
        myNodes.clear();
      }
      WishData wdItem;
      /*var tmp = mainScreenState!.allCircles.where((element) => element.id==wishId);
      if(tmp.isNotEmpty){*/
        /*isDataFetched!=0?wdItem = (await repository.getMyWish(wishId, mainScreenState!.moon.id)) ?? WishData(id: -100, parentId: 0, text: "не удалось загрузить данные", description: "", affirmation: "", color: Colors.transparent):*/
        wdItem = (await localRep.getSphere(wishId, mainScreenState!.moon.id)) ?? WishData(id: -100, prevId: -1, nextId: -1, parentId: 0, text: "не удалось загрузить данные", description: "", affirmation: "", color: Colors.transparent);
      /*}else{
        wdItem = WishData(id: wishId, parentId: parentId, text: "", description: "", affirmation: "", color: Colors.green);
      }*/
      if(!isUpdateScreen) {
        wishScreenState = WishScreenState(wish: wdItem);
      } else {
        wishScreenState?.wish = wdItem;
      }
      notifyListeners();
      return wdItem;
    }catch(ex, s){
      addError("#436${ex.toString()}");
      print("sssssssssssssssss $s");
    }
    return WishData(id: -1, prevId: -1, nextId: -1, parentId: -1, text: "error 522 cant load data", description: "description", affirmation: "affirmation", color: Colors.red);
  }

  Future<void> startMyTasksScreen() async{
    try {
      isinLoading = true;
      taskItems = /*isDataFetched!=0?((await repository.getMyTasks(mainScreenState?.moon.id??0)) ?? []):*/
      (await localRep.getAllTasks(mainScreenState?.moon.id??0));
      isinLoading = false;
      notifyListeners();
    }catch(ex, m){
      addError("#868${ex.toString()}");
      print("fgfffffffffffffff$m");
    }
  }
  Future getTasksForAims(List<int> aimId) async {
    try {
      List<int> list = [];
      for (var element in aimId) {
        /*isDataFetched!=0?list.addAll((await repository.getAimsChildTasks(element, mainScreenState?.moon.id ?? 0))??[]):*/
        list.addAll(await localRep.getAimsChildTasks(element,mainScreenState?.moon.id??0));
      }
      if (list.isNotEmpty){
        if(taskItems.isNotEmpty){
          wishScreenState?.wishTasks = taskItems.where((element) => list.contains(element.id)).toList();
        }else{
          taskItems = /*isDataFetched!=0?((await repository.getMyTasks(mainScreenState?.moon.id??0)) ?? []):*/
          await localRep.getAllTasks(mainScreenState?.moon.id??0);
          wishScreenState?.wishTasks = taskItems.where((element) => list.contains(element.id)).toList();
        }
      }else {
        return null;
      }
    }catch(ex, s){
      addError("#01 Ошибка загрузки задач: $ex");
      print("errrrrrrrrrrrrrrrrrrr$s");
    }
  }

  Future<void> startMainsphereeditScreen() async{
    try {
      isinLoading = true;
      isChanged = false;
      mainSphereEditCircle=null;
      if(aimItems.isEmpty) {
        /*aimItems = isDataFetched!=0?((await repository.getMyAims(mainScreenState?.moon.id??0)) ?? []):*/
        aimItems = await localRep.getAllAims(mainScreenState?.moon.id??0);
      }
      if(taskItems.isEmpty) {
        /*taskItems = isDataFetched!=0?((await repository.getMyTasks(mainScreenState?.moon.id??0)) ?? []):*/
        taskItems = await localRep.getAllTasks(mainScreenState?.moon.id??0);
      }
      isinLoading = false;
      notifyListeners();
    }catch(ex){
      addError("#448${ex.toString()}");
    }
  }

  Future<void> startMyAimsScreen() async{
    try {
      isinLoading = true;
      /*aimItems = isDataFetched!=0?((await repository.getMyAims(mainScreenState?.moon.id??0)) ?? []):*/
      aimItems = await localRep.getAllAims(mainScreenState?.moon.id??0);
      isinLoading = false;
      notifyListeners();
    }catch(ex){
      addError("#278${ex.toString()}");
    }
  }
  Future getAimsForCircles(int sphereId) async {
    try {
      var list = /*isDataFetched!=0?((await repository.getSpheresChildAims(sphereId, mainScreenState?.moon.id ?? 0)) ?? []):*/
        await localRep.getSpheresChildAims(sphereId, mainScreenState?.moon.id??0);
      if (list.isNotEmpty){
        if(aimItems.isNotEmpty){
          wishScreenState?.wishAims = aimItems.where((element) => list.contains(element.id)).toList();
        }else{
          aimItems = /*isDataFetched!=0?((await repository.getMyAims(mainScreenState?.moon.id??0)) ?? []):*/
          await localRep.getAllAims(mainScreenState?.moon.id??0);
          wishScreenState?.wishAims = aimItems.where((element) => list.contains(element.id)).toList();
        }
        await getTasksForAims(list);
        notifyListeners();
      }else {
        return null;
      }
    }catch(ex){
      addError("#02 Ошибка загрузки задач: $ex");
    }
  }

  Future<void> startMyWishesScreen() async{
    try {
      isinLoading = true;
      wishItems = /*isDataFetched!=0?((await repository.getMyWishs(mainScreenState?.moon.id??0)) ?? []):*/
      await localRep.getAllSpheres(mainScreenState?.moon.id??0);
      isinLoading = false;
      notifyListeners();
    }catch(ex){
      addError("#565${ex.toString()}");
    }
  }

  Future<void> createNewSphereWish(WishData wd, bool updateNeighbours) async{
    try {
      Map<int, Uint8List> photos = {};
      String photosIds = "";
      for (var element in cachedImages) {
        lastImageId++;
        if(photosIds.isNotEmpty)photosIds+="|";
        photosIds+=lastImageId.toString();
        photos[lastImageId]=element;
        localRep.addImage(lastImageId, element);
      }
      wd.photos = photos;
      wd.shuffle = false;
      if(connectivity != 'No Internet Connection')/*await*/ repository.createSphereWish(wd, mainScreenState?.moon.id??0);
      await localRep.insertORudateSphere(wd, mainScreenState?.moon.id??0);
      localRep.updateSphereImages(wd.id, photosIds,mainScreenState?.moon.id??0);
      if(updateNeighbours)updateSphereNeighbours(wd.id, wd.prevId, wd.nextId);
      var sphereInAllCircles= mainScreenState!.allCircles.indexWhere((element) => element.id==wd.id);
      if(sphereInAllCircles==-1){
        mainScreenState!.allCircles.add(CircleData(id: wd.id, prevId: wd.prevId, nextId: wd.nextId, text: wd.text, color: wd.color, parenId: wd.parentId)..shuffle=wd.shuffle..lastShuffle=wd.lastShuffle);
        mainScreenState!.allCircles = sortList(mainScreenState!.allCircles);

        //mainScreenState!.allCircles.sort((a,b)=>a.id.compareTo(b.id));
        if(wd.id > 800)wishItems.add(WishItem(id: wd.id, text: wd.text, isChecked: wd.isChecked, isActive: wd.isActive, isHidden: wd.isHidden));
      }
      else{
        mainScreenState!.allCircles[sphereInAllCircles]
        ..text = wd.text
        ..color = wd.color
        ..isActive = true;
        if(mainCircles.last.id==wd.id) mainCircles.last..color=wd.color..text=wd.text..isActive=true;
      }
      currentCircles.where((element) => element.id==wd.id).firstOrNull?..text=wd.text..color=wd.color;
      /*var sphereInWishesList = wishItems.indexWhere((element) => element.id==wd.id);
      if(sphereInWishesList>=0){
        wishItems[sphereInWishesList]=WishItem(id: wd.id, text: wd.text, isChecked: wd.isChecked,isActive: wd.isActive, isHidden: wd.isHidden);
      }*/
      wishItems.clear();
      updateMoonSync(mainScreenState?.moon.id??0);
    }catch(ex){
      addError("сфера не была сохранена: $ex");
    }
  }
  Future updateSphereNeighbours(int insertedSphere, int prevSphereId, int nextSphereId) async{
    if(mainScreenState?.allCircles!=null){
      if(prevSphereId!=-1){
        mainScreenState!.allCircles.where((element) => element.id==prevSphereId).firstOrNull?.nextId=insertedSphere;
        repository.updateNeighbour(prevSphereId, true, insertedSphere, mainScreenState?.moon.id??0);
        localRep.updateSphereNeighbours(prevSphereId, true, insertedSphere, mainScreenState?.moon.id??0);
      }
      if(nextSphereId!=-1){
        mainScreenState!.allCircles.where((element) => element.id==nextSphereId).firstOrNull?.prevId=insertedSphere;
        repository.updateNeighbour(nextSphereId, false, insertedSphere, mainScreenState?.moon.id??0);
        localRep.updateSphereNeighbours(nextSphereId, false, insertedSphere, mainScreenState?.moon.id??0);
      }
    }
  }
  bool hasChildWishes(int wishId){
    return mainScreenState?.allCircles.where((element) => element.parenId==wishId).isNotEmpty??false;
  }
  Future<void> updateSphereWish(WishData wd) async{
    try {
      Map<int, Uint8List> photos = {};
      String photosIds = "";
      for (var element in cachedImages) {
        lastImageId++;
        if(photosIds.isNotEmpty)photosIds+="|";
        photosIds+=lastImageId.toString();
        photos[lastImageId]=element;
        localRep.addImage(lastImageId, element);
      }
      wd.photos = photos;
      if(connectivity != 'No Internet Connection')/*await*/ repository.createSphereWish(wd, mainScreenState?.moon.id??0);
      await localRep.insertORudateSphere(wd, mainScreenState?.moon.id??0);
      localRep.updateSphereImages(wd.id, photosIds,mainScreenState?.moon.id??0);
      mainScreenState!.allCircles[mainScreenState!.allCircles.indexWhere((element) => element.id==wd.id)] = CircleData(id: wd.id, prevId: wd.prevId, nextId: wd.nextId, text: wd.text, color: wd.color, parenId: wd.parentId, affirmation: wd.affirmation, subText: wd.description)..photosIds=photosIds;
      updateMoonSync(mainScreenState?.moon.id??0);
    }catch(ex){
      addError("сфера не была сохранена: $ex");
    }
  }
  Future<void> activateSphereWish(int id, bool status, {bool updateScreen = false}) async{
    try {
      if(wishItems.isEmpty)wishItems = await localRep.getAllSpheres(mainScreenState?.moon.id??0);
      if(wishItems.where((element) => element.id==id).firstOrNull?.isChecked==true) return;
      if(connectivity != 'No Internet Connection') repository.activateWish(id, mainScreenState!.moon.id, status);
      await localRep.activateSphere(id, status, mainScreenState!.moon.id);
      mainScreenState!.allCircles[mainScreenState!.allCircles.indexWhere((element) => element.id==id)].isActive=true;
      if(id==0){
        if(settings.sphereActualizingMode==0){
          List<int> childSpheres = mainScreenState?.allCircles.where((element) => element.parenId==0).map((e) => e.id).toList()??[];
          childSpheres.forEach((eid) async {
            await activateSphereWish(eid, true, updateScreen: updateScreen);
          });
        }
        //actualize child aims
        List<int> childAims = await localRep.getSpheresChildAims(id, mainScreenState?.moon.id??0);
        List<int> childTasks = [];
        for (var eid in childAims) {
          activateAim(eid, true);
          if(settings.taskActualizingMode==0) {
            final ts = await localRep.getAimsChildTasks(eid, mainScreenState?.moon.id??0);
            childTasks.addAll(ts);
          }
        }
        //actualize childTasks
        for (var eid in childTasks) {
          activateTask(eid, true);
        }
      }else if(id<=800){

      }else{
        if(settings.sphereActualizingMode==1){
          int parentSphere = mainScreenState?.allCircles.where((element) => element.id==id).first.parenId??-1;
          await activateSphereWish(parentSphere, true, updateScreen: updateScreen);
        }else if(settings.wishActualizingMode==0){
          List<int> childWishes = mainScreenState?.allCircles.where((element) => element.parenId==id).map((e) => e.id).toList()??[];
          childWishes.forEach((eid) async {
            await activateSphereWish(eid, true, updateScreen: updateScreen);
          });
        }else if(settings.wishActualizingMode==1){
          int parentWish = mainScreenState?.allCircles.where((element) => element.id==id).first.parenId??-1;
          if(parentWish>800) await activateSphereWish(parentWish, true, updateScreen: updateScreen);
        }
        //actualize child aims
        List<int> childAims = await localRep.getSpheresChildAims(id, mainScreenState?.moon.id??0);
        List<int> childTasks = [];
        for (var eid in childAims) {
          activateAim(eid, true);
          if(settings.taskActualizingMode==0) {
            final ts = await localRep.getAimsChildTasks(eid, mainScreenState?.moon.id??0);
            childTasks.addAll(ts);
          }
        }
        //actualize childTasks
        for (var eid in childTasks) {
          activateTask(eid, true);
        }
      }
      if(myNodes.isNotEmpty)toggleActive(myNodes.first, 'w', id, status);
      if(updateScreen)await startMainScreen(mainScreenState!.moon);
      updateMoonSync(mainScreenState?.moon.id??0);
      notifyListeners();
    }catch(ex, s){
      print("eeeeeeeeeeerrrrrrrrrrrr $s");
      addError("сфера не была актуализирована 006: $ex");
    }
  }
  Future<void> hideSphereWish(int id, bool isHide, bool recursive) async{
    try {
      if(isHide) {
        if(recursive) {
          var allwishes = getFullBranch(id);
          List<CircleData> wishes = [];
          Set<int> uniqueIds = {};

          // Итерируем по внешнему списку
          for (List<CircleData> innerList in allwishes) {
            // Итерируем по внутреннему списку
            for (CircleData obj in innerList) {
              // Если id объекта уникально, добавляем его в результат
              if (uniqueIds.add(obj.id)&&obj.id>=id) {
                wishes.add(obj);
              }
            }
          }
          for (var e in wishes) {
            hideSphereWish(e.id, isHide, false);
            if(mainScreenState!=null){
              final i = mainScreenState!.allCircles.indexWhere((element) => element.id==e.id);
              if(i>=0)mainScreenState!.allCircles[i].isHidden=isHide;
            }
            if(wishItems.isNotEmpty){
              final i = wishItems.indexWhere((element) => element.id == e.id);
              if(i>=0)wishItems[i].isHidden = isHide;
            }
          }
        }
      }
      if(connectivity != 'No Internet Connection')await repository.hideWish(id, mainScreenState!.moon.id, isHide);
      await localRep.hideSphere(id, isHide, mainScreenState!.moon.id);
      print("aaaaaaaaaaaaaaaaf${mainScreenState==null}");
      try{if(myNodes.isNotEmpty)toggleHidden(myNodes.first, 'w', id, isHide);}catch(ex, c){print("eeeeeeeeeeeexxxxxxxxxxxxxxxxxx$c");}
      print("aaaaaaaaaaaaaaaaf0");
      if(mainScreenState!=null){
        final i = mainScreenState!.allCircles.indexWhere((element) => element.id==id);
        print("aaaaaaaaaaaaaaaaf1  ${i}");
        if(i>=0)mainScreenState!.allCircles[i].isHidden=isHide;
      }
      if(wishItems.isNotEmpty){
        final i = wishItems.indexWhere((element) => element.id == id);
        print("aaaaaaaaaaaaaaaaf1  ${i}");
        if(i>=0)wishItems[i].isHidden = isHide;
      }
      updateMoonSync(mainScreenState?.moon.id??0);
      notifyListeners();
    }catch(ex){
      addError("состояние не изменено 007: $ex");
    }
  }
  Future<void> deleteSphereWish(int id, int prevId, int nextId) async{
    try {
      if(mainScreenState!=null){
        for (var element in mainScreenState!.allCircles) {
          if(element.parenId==id){
            deleteSphereWish(element.id, element.prevId, element.nextId);
          }
        }
      }
      if(mainScreenState?.allCircles!=null){
        if(prevId!=-1){
          mainScreenState!.allCircles.where((element) => element.id==prevId).firstOrNull?.nextId=nextId;
          repository.updateNeighbour(prevId, true, nextId, mainScreenState?.moon.id??0);
          localRep.updateSphereNeighbours(prevId, true, nextId, mainScreenState?.moon.id??0);
        }
        if(nextId!=-1){
          mainScreenState!.allCircles.where((element) => element.id==nextId).firstOrNull?.prevId=prevId;
          repository.updateNeighbour(nextId, false, prevId, mainScreenState?.moon.id??0);
          localRep.updateSphereNeighbours(nextId, false, prevId, mainScreenState?.moon.id??0);
        }
      }
      wishItems.removeWhere((element) => element.id==id);
      //mainScreenState!.allCircles.removeWhere((element) => element.id==id);
      await deleteallChildAims(id);
      if(connectivity != 'No Internet Connection')await repository.deleteSphereWish(id, mainScreenState?.moon.id??0);
      await localRep.deleteSphere(id,mainScreenState?.moon.id??0);
      updateMoonSync(mainScreenState?.moon.id??0);
    }catch(ex, s){
      addError("сфера не была удалена: $ex");
    }
  }

  Future<void> deleteallChildAims(int wishId)async{
    try{
      final wish = /*isDataFetched!=0?await repository.getMyWish(wishId, mainScreenState!.moon.id):*/
      await localRep.getSphere(wishId, mainScreenState?.moon.id??0);
      if(wish!=null&&wish.childAims.isNotEmpty){
        wish.childAims.forEach((key, value) async {
          await deleteallChildTasks(value);
          if(connectivity != 'No Internet Connection')repository.deleteAim(value, mainScreenState!.moon.id);
          localRep.deleteAim(value,mainScreenState?.moon.id??0);
        });
      }
    }catch(e){
      addError("ошибка при удалении целей");
    }
  }
  Future<void> deleteallChildTasks(int aimId)async{
    try{
      final aim = /*isDataFetched!=0?await repository.getMyAim(aimId, mainScreenState!.moon.id):*/
      await localRep.getAim(aimId,mainScreenState?.moon.id??0);
      if(aim!=null&&aim.childTasks.isNotEmpty){
        for (var element in aim.childTasks) {
          if(connectivity != 'No Internet Connection')repository.deleteTask(element, mainScreenState!.moon.id);
          localRep.deleteTask(element,mainScreenState?.moon.id??0);
          taskItems.removeWhere((e) => e.id==element);
          wishScreenState?.wishTasks.removeWhere((e) => e.id==element);
        }
      }
      notifyListeners();
    }catch(e){
      addError("ошибка при удалении задач");
    }
  }
  Future<void> updateWishStatus(int wishId, bool status, {bool recursive = true}) async{
    try {
      if(status) {
        if(recursive) {
          var allwishes = getFullBranch(wishId);
          List<CircleData> wishes = [];
          Set<int> uniqueIds = {};

          // Итерируем по внешнему списку
          for (List<CircleData> innerList in allwishes) {
            // Итерируем по внутреннему списку
            for (CircleData obj in innerList) {
              // Если id объекта уникально, добавляем его в результат
              if (uniqueIds.add(obj.id)&&obj.id>=wishId) {
                wishes.add(obj);
              }
            }
          }
          for (var e in wishes) {
            updateWishStatus(e.id, status, recursive: false);
            if(mainScreenState!=null){
              final i = mainScreenState!.allCircles.indexWhere((element) => element.id==e.id);
              if(i>=0)mainScreenState!.allCircles[i].isChecked=status;
            }
            if(wishItems.isNotEmpty){
              final i = wishItems.indexWhere((element) => element.id == e.id);
              if(i>=0)wishItems[i].isChecked = status;
            }
          }
        }
          final aims = /*isDataFetched!=0? await repository.getSpheresChildAims(wishId, mainScreenState!.moon.id):*/
          await localRep.getSpheresChildAims(wishId, mainScreenState?.moon.id??0);
          if (aims != null && aims.isNotEmpty) {
            for (var element in aims) {
              updateAimStatus(element, status);
            }
          }
      }
      if(connectivity != 'No Internet Connection')await repository.changeWishStatus(wishId, mainScreenState?.moon.id??0, status);
      await localRep.updateSphereStatus(wishId, status,mainScreenState?.moon.id??0);
      toggleChecked(myNodes.first, 'w', wishId, status);
      if(mainScreenState!=null){
        final i = mainScreenState!.allCircles.indexWhere((element) => element.id==wishId);
        if(i>=0)mainScreenState!.allCircles[i].isChecked=status;
      }
      if(wishItems.isNotEmpty){
        final i = wishItems.indexWhere((element) => element.id == wishId);
        if(i>=0)wishItems[i].isChecked = status;
      }
      updateMoonSync(mainScreenState?.moon.id??0);
      notifyListeners();
    }catch(ex){
      addError("#566${ex.toString()}");
    }
  }

  Future<int?> createAim(AimData ad, int parentCircleId) async{
    try {
      int? aimId;
      if(connectivity != 'No Internet Connection')/*aimId =*/ (/*await*/ repository.createAim(ad, parentCircleId, mainScreenState?.moon.id??0));
      aimId = await localRep.addAim(AimData(id: aimId??-1, parentId: parentCircleId, text: ad.text, description: ad.description), mainScreenState?.moon.id??-1);
      currentAim=(AimData(id: aimId, parentId: ad.parentId, text: ad.text, description: ad.description, isChecked: ad.isChecked, isActive: ad.isActive));
      aimItems.add(AimItem(id: aimId,parentId: parentCircleId, text: ad.text, isChecked: ad.isChecked, isActive: ad.isActive));
      if(wishScreenState!=null)wishScreenState!.wish.childAims["kjkjkjkj"]=aimId;
      updateMoonSync(mainScreenState?.moon.id??0);
      print("rwturmffffffffffffffffff${aimId}");
      return aimId;
    }catch(ex){
      addError("#5711${ex.toString()}");
    }
  }
  Future getAim(int id) async{
    try{
      currentAim = null;
      var result = await Connectivity().checkConnectivity();
      if(result == ConnectivityResult.none)  connectivity = 'No Internet Connection';
      if(mainScreenState!=null) {
        /*currentAim = isDataFetched!=0?await repository.getMyAim(id, mainScreenState!.moon.id):*/
        try {
          currentAim = await localRep.getAim(id, mainScreenState?.moon.id ?? 0);
        }catch(ex, s){
          print("exxxxxxxxxxxxxxxxxxxxxxxxx $ex --- $s");
        }
        notifyListeners();
      } else {
        throw Exception("#2365 lost datas");
      }
    }catch(ex){
      addError("#764$ex");
    }
  }
  Future<void> activateAim(int id, bool status) async{
    try {
      if(connectivity != 'No Internet Connection') repository.activateAim(id, mainScreenState!.moon.id, status);
      await localRep.activateAim(id, status, mainScreenState!.moon.id);
      aimItems.where((element) => element.id==id).firstOrNull?.isActive=true;
      updateMoonSync(mainScreenState?.moon.id??0);
    }catch(ex){
      addError("сфера не была актуализирована 008: $ex");
    }
  }
  Future<void> updateAim(AimData ad) async{
    try {
      if(connectivity != 'No Internet Connection')await repository.updateAim(ad, mainScreenState?.moon.id??0);
      await localRep.updateAim(ad,mainScreenState?.moon.id??0);
      currentAim=(AimData(id: ad.id, parentId: ad.parentId, text: ad.text, description: ad.description, isChecked: ad.isChecked, isActive: ad.isActive));
      aimItems[aimItems.indexWhere((element) => element.id==ad.id)]=AimItem(id: ad.id, parentId: ad.parentId, text: ad.text, isChecked: ad.isChecked, isActive: ad.isActive);
      updateMoonSync(mainScreenState?.moon.id??0);
    }catch(ex){
      addError("#518${ex.toString()}");
    }
  }
  Future<void> deleteAim(int aimId, int parentWishId) async{
    try {
      await deleteallChildTasks(aimId);
      if(connectivity != 'No Internet Connection')await repository.deleteAim(aimId, mainScreenState?.moon.id??0);
      localRep.deleteAim(aimId,mainScreenState?.moon.id??0);
      localRep.updateWishChildren(parentWishId, aimId, mainScreenState?.moon.id??0);
      aimItems.removeWhere((element) => element.id == aimId);
      updateMoonSync(mainScreenState?.moon.id??0);
    }catch(ex){
      addError("#519${ex.toString()}");
    }
  }
  Future<void> updateAimStatus(int aimId, bool status) async{
    try {
      if(status) {
        final tasks = /*isDataFetched!=0? await repository.getAimsChildTasks(aimId, mainScreenState!.moon.id):*/
        await localRep.getAimsChildTasks(aimId,mainScreenState?.moon.id??0);
        if (tasks != null && tasks.isNotEmpty) {
          for (var element in tasks) {
            updateTaskStatus(element, status);
          }
        }
      }
      currentAim?.isChecked = status;
      if(currentAim!=null){
        final i = aimItems.indexWhere((element) => element.id == currentAim!.id);
        if(i>=0)aimItems[i].isChecked = status;
      }
      if(connectivity != 'No Internet Connection')await repository.changeAimStatus(aimId, mainScreenState?.moon.id??0, status);
      await localRep.updateAimStatus(aimId, status,mainScreenState?.moon.id??0);
      toggleChecked(myNodes.first, 'a', aimId, status);
      updateMoonSync(mainScreenState?.moon.id??0);
      notifyListeners();
    }catch(ex){
      addError("#520${ex.toString()}");
    }
  }

  Future<int?> createTask(TaskData ad, int parentAimId) async{
    try {
      int taskId = -1;
      if(connectivity != 'No Internet Connection')/*taskId = */(/*await*/ repository.createTask(ad, parentAimId, mainScreenState?.moon.id??0));
      taskId = await localRep.addTask(TaskData(id: taskId, parentId: parentAimId, text: ad.text, description: ad.description), mainScreenState?.moon.id??-1);
      currentTask=(TaskData(id: taskId, parentId: ad.parentId, text: ad.text, description: ad.description, isChecked: ad.isChecked, isActive: ad.isActive));
      taskItems.add(TaskItem(id: taskId, parentId: parentAimId, text: ad.text, isChecked: ad.isChecked, isActive: ad.isActive));
      if(currentAim!=null)currentAim!.childTasks.add(taskId);
      updateMoonSync(mainScreenState?.moon.id??0);
      return taskId;
    }catch(ex){
      addError("#522${ex.toString()}");
    }
  }
  Future getTask(int id) async{
    try{
      var result = await Connectivity().checkConnectivity();
      if(result == ConnectivityResult.none)  connectivity = 'No Internet Connection';
      if(mainScreenState!=null) {
        /*currentTask = isDataFetched!=0?await repository.getMyTask(id, mainScreenState!.moon.id):*/
        currentTask = await localRep.getTask(id,mainScreenState?.moon.id??0);
        notifyListeners();
      } else {
        throw Exception("#2366 lost datas");
      }
    }catch(ex){
      addError("#2456$ex");
    }
  }
  Future<void> updateTask(TaskData ad) async{
    try {
      if(connectivity != 'No Internet Connection')await repository.updateTask(ad, mainScreenState?.moon.id??0);
      await localRep.updateTask(ad,mainScreenState?.moon.id??0);
      currentTask=(TaskData(id: ad.id, parentId: ad.parentId, text: ad.text, description: ad.description, isChecked: ad.isChecked, isActive: ad.isActive));
      taskItems[taskItems.indexWhere((element) => element.id==ad.id)]=TaskItem(id: ad.id, parentId: ad.parentId, text: ad.text, isChecked: ad.isChecked, isActive: ad.isActive);
      updateMoonSync(mainScreenState?.moon.id??0);
    }catch(ex){
      addError("#524${ex.toString()}");
    }
  }
  Future<void> deleteTask(int taskId, int parentAimId) async{
    try {
      if(connectivity != 'No Internet Connection')await repository.deleteTask(taskId, mainScreenState?.moon.id??0);
      await localRep.deleteTask(taskId,mainScreenState?.moon.id??0);
      localRep.updateAimChildren(parentAimId, taskId, mainScreenState?.moon.id??0);
      taskItems.removeWhere((element) => element.id == taskId);
      updateMoonSync(mainScreenState?.moon.id??0);
    }catch(ex){
      addError("#526${ex.toString()}");
    }
  }
  Future<void> updateTaskStatus(int taskId, bool status) async{
    try {
      currentTask?.isChecked = status;
      if(currentTask!=null){
        final i = taskItems.indexWhere((element) => element.id == currentTask!.id);
        if(i>=0)taskItems[i].isChecked = status;
      }
      if(connectivity != 'No Internet Connection')await repository.changeTaskStatus(taskId, mainScreenState?.moon.id??0, status);
      await localRep.updateTaskStatus(taskId, status,mainScreenState?.moon.id??0);
      toggleChecked(myNodes.first, 't', taskId, status);
      updateMoonSync(mainScreenState?.moon.id??0);
      notifyListeners();
    }catch(ex){
      addError("#528${ex.toString()}");
    }
  }
  Future<void> activateTask(int id, bool status) async{
    try {
      if(connectivity != 'No Internet Connection') repository.activateTask(id, mainScreenState!.moon.id, status);
      await localRep.activateTask(id, status, mainScreenState!.moon.id);
      taskItems.where((element) => element.id==id).firstOrNull?.isActive=true;
      updateMoonSync(mainScreenState?.moon.id??0);
    }catch(ex, s){
      print("eeeeeeeeerrrrrrrrrrr $ex -|__|- $s");
      addError("сфера не была актуализирована 009: $ex");
    }
  }

  Future<void> getDiary() async{
    List<CardData> cardData = [
      CardData(id: 1, emoji: "😃", title: "Благодраность", description: "Чтобы разблокировать путь к желаниям, каждый день начинай с благодарности", text: "no text", color: Colors.blue),
      CardData(id: 2, emoji: "🌟", title: "Виденье на 5 лет", description: "Глабольное видиние своей жизни лежит в основе всех твоих желаний", text: "no text", color: Colors.lightGreen),
      CardData(id: 3, emoji: "🎉", title: "Лучший день", description: "Опиши самый замечательный день или момент жизни за прошедший год", text: "no text", color: Colors.purpleAccent),
      CardData(id: 4, emoji: "❤️", title: "100 желаний", description: "Создай свой банк желаний, пусть даже самых невообразимых, и пусть они хранятся здесь", text: "no text", color: Colors.amber),
      CardData(id: 5, emoji: "🌺", title: "Мои сны", description: "Если записывыать свои сны каждый день, ты обретешь суперспособности", text: "no text", color: Colors.white54),
      CardData(id: 6, emoji: "🍔", title: "Мои страхи", description: "Выписывай все свои страхи и они начнут растворятся сами собой", text: "no text", color: Colors.cyanAccent),
      ];
    try {
      /*diaryItems = isDataFetched!=0?(await repository.getDiaryList(mainScreenState!.moon.id))??[CardData(id: 0, emoji: "⚽", title: "ничего не найдено", description: "", text: "", color: Colors.transparent),]:*/
      await localRep.getAllDiary(mainScreenState?.moon.id??0);
      if(diaryItems.isEmpty) {
        if(connectivity != 'No Internet Connection')repository.addDiary(cardData, mainScreenState!.moon.id);
        localRep.addAllDiary(cardData, mainScreenState?.moon.id??-1);
        diaryItems = cardData;
      }
      updateMoonSync(mainScreenState?.moon.id??0);
      notifyListeners();
    }catch(ex){
      addError("#532${ex.toString()}");
    }
  }
  Future<void> addDiary(CardData cd)async {
    try{
      diaryItems.add(cd);
      if(connectivity != 'No Internet Connection')await repository.addDiary([cd], mainScreenState!.moon.id);
      await localRep.addDiary(cd, mainScreenState?.moon.id??-1);
      updateMoonSync(mainScreenState?.moon.id??0);
      notifyListeners();
    }catch(ex){
      addError("#534${ex.toString()}");
    }
  }
  Future<void> updateDiary(CardData cd)async{
    try{
      final index = diaryItems.indexWhere((element) => element.id==cd.id);
      if(index==-1)throw Exception("error#vm6794");
      diaryItems[index]=cd;
      if(connectivity != 'No Internet Connection')await repository.updateDiary(cd, mainScreenState!.moon.id);
      await localRep.updateDiary(cd,mainScreenState?.moon.id??0);
      updateMoonSync(mainScreenState?.moon.id??0);
      notifyListeners();
    }catch(ex){
      addError("#536${ex.toString()}");
    }
  }


  Future<List<TaskItem>?> getTasksForAim(int aimId) async {
    try {
      List<int> list = [];
      list.addAll(/*isDataFetched!=0?((await repository.getAimsChildTasks(aimId, mainScreenState?.moon.id ?? 0))??[]):*/
      await localRep.getAimsChildTasks(aimId,mainScreenState?.moon.id??0));
      if (list.isNotEmpty){
        if(taskItems.isNotEmpty){
          return taskItems.where((element) => list.contains(element.id)).toList();
        }else{
          taskItems = /*isDataFetched!=0?((await repository.getMyTasks(mainScreenState?.moon.id??0)) ?? []):*/
          await localRep.getAllTasks(mainScreenState?.moon.id??0);
          return  taskItems.where((element) => list.contains(element.id)).toList();
        }
      }else {
        return null;
      }
    }catch(ex, s){
      addError("#03 Ошибка загрузки задач: $ex");
      print("sssssssssssss$s");
    }
    return null;
  }
  Future convertToMyTreeNode(CircleData circle) async {
    final taskList = await getTasksForAim(circle.id);
    List<CircleData> allCircles = getParentTree(circle.parenId);
    List<MyTreeNode> children = <MyTreeNode>[MyTreeNode(id: circle.id, type: "a", title: circle.text, isChecked: circle.isChecked, isActive: circle.isActive, children: (taskList?.map((e) =>  MyTreeNode(id: e.id, type: 't', title: e.text, isChecked: e.isChecked, isActive: e.isActive)))?.toList()??[])..noClickable=true];
    for (var element in allCircles) {
      children=[MyTreeNode(id: element.id, type: element.id==0?"m":"w", title: element.text, children: children, isChecked: element.isChecked, isActive: element.isActive)];
    }
    myNodes = children;
    notifyListeners();
  }

  Future<List<MyTreeNode>> convertToMyTreeNodeIncludedAimsTasks(MyTreeNode aimNode, int taskId, int wishId) async {
    final taskList = await getTasksForAim(aimNode.id);
    List<CircleData> allCircles = getParentTree(wishId);
    List<MyTreeNode> children = <MyTreeNode>[MyTreeNode(id: aimNode.id, type: "a", title: aimNode.title, isChecked: aimNode.isChecked, isActive: aimNode.isActive, children: (taskList?.map((e) =>  MyTreeNode(id: e.id, type: 't', title: e.text, isChecked: e.isChecked, isActive: e.isActive)..noClickable=e.id==taskId))?.toList()??[])];
    for (var element in allCircles) {
      children=[MyTreeNode(id: element.id, type: element.id==0?"m":"w", title: element.text, isChecked:  element.isChecked, isActive: element.isActive, children: children)];
    }
    myNodes= children;
    notifyListeners();
    return children;
  }

  Future<List<MyTreeNode>> convertToMyTreeNodeFullBranch(int wishId) async {
    var addChildTasksAims = true;
    final fullBranch = getFullBranch(wishId);
    taskItems = /*isDataFetched!=0?((await repository.getMyTasks(mainScreenState!.moon.id))??[]):*/
    await localRep.getAllTasks(mainScreenState?.moon.id??0);
    aimItems = /*isDataFetched!=0?((await repository.getMyAims(mainScreenState!.moon.id))??[]):*/
    await localRep.getAllAims(mainScreenState?.moon.id??0);
    MyTreeNode? root;
    Set<CircleData> commonPart = {};
    // Создаем множество для отслеживания уникальных id
    Set<int> uniqueIds = {};
    // Итерируем по внешнему списку
    List<CircleData> objectsToRemove = [];
    for (List<CircleData> innerList in fullBranch) {
      // Итерируем по внутреннему списку
      for (CircleData obj in innerList) {
        // Если id объекта не уникально, добавляем его в результат
        if (!uniqueIds.add(obj.id)) {
          commonPart.add(obj);
          objectsToRemove.add(obj);
        }
      }
    }
    for (List<CircleData> innerList in fullBranch) {
        innerList.removeWhere((obj) => objectsToRemove.contains(obj));
    }
    final Map<int, int> mchildNodesIds = {};
    final List<MyTreeNode> mchildNodes = [];
    for (var e in fullBranch) {
      MyTreeNode? loclRoot;
      addChildTasksAims=true;
      for (var melement in e) {
        final List<MyTreeNode> childNodes = [];
        if(addChildTasksAims){
          final chilldAims = aimItems.where((element) => element.parentId==melement.id);
          for (var e in chilldAims) {
            final childTasks = taskItems.where((item) => item.parentId==e.id);
            childNodes.add(MyTreeNode(id: e.id, type: 'a', title: e.text, isChecked: e.isChecked,  isActive: e.isActive, children: (childTasks.map((t) => MyTreeNode(id: t.id, type: 't', title: t.text, isChecked: t.isChecked, isActive: e.isActive))).toList()));
          }
        }
        if(loclRoot != null)childNodes.add(loclRoot);
        loclRoot = MyTreeNode(id: melement.id, type: melement.id==0?"m":"w", title: melement.text, isChecked: melement.isChecked, isActive:  melement.isActive,  children: childNodes, isHidden: melement.isHidden)..noClickable=melement.id==wishId?true:false;
        if(melement.id==wishId) addChildTasksAims=false;
      }
      if(loclRoot!=null){
        mchildNodes.add(loclRoot);
        mchildNodesIds[mchildNodes.indexOf(mchildNodes.last)]=(e.last.parenId);
      }
    }
    if(commonPart.isEmpty){
      root = mchildNodes.first;
    }else {
      for (var melement in commonPart) {
        final List<MyTreeNode> childNodes = [];
        if (addChildTasksAims) {
          final chilldAims = aimItems.where((element) =>
          element.parentId == melement.id);
          for (var e in chilldAims) {
            final childTasks = taskItems.where((item) => item.parentId == e.id);
            childNodes.add(MyTreeNode(id: e.id,
                type: 'a',
                title: e.text,
                isChecked: e.isChecked,
                children: (childTasks.map((t) => MyTreeNode(id: t.id,
                    type: 't',
                    title: t.text,
                    isChecked: t.isChecked))).toList()));
          }
        }
        if (root != null) childNodes.add(root!);
        if (mchildNodesIds.values.contains(melement.id)) {
          mchildNodesIds.forEach((k, v) {
            if(v==melement.id)childNodes.add(mchildNodes[k]);
          });
        }
        root = MyTreeNode(id: melement.id,
            type: melement.id == 0 ? "m" : "w",
            title: melement.text,
            isChecked: melement.isChecked,
            isActive: melement.isActive,
            children: childNodes)
          ..noClickable = melement.id == wishId ? true : false;
        if (melement.id == wishId) addChildTasksAims = false;
      }
    }

    if(root!=null) {
      myNodes= [root!];
      notifyListeners();
      return [root!];
    } else {
      myNodes.clear();
      notifyListeners();
      return [];
    }
  }

  void toggleChecked(MyTreeNode e, String type, int targetId, bool value) {
    if (e.id == targetId&&e.type==type) {
      e.isChecked = value;
    } else {
      for (var child in e.children) {
        toggleChecked(child, type, targetId, value);
      }
    }
  }
  void toggleHidden(MyTreeNode e, String type, int targetId, bool value) {
    if (e.id == targetId&&e.type==type) {
      e.isHidden = value;
    } else {
      for (var child in e.children) {
        toggleHidden(child, type, targetId, value);
      }
    }
  }
  void toggleActive(MyTreeNode e, String type, int targetId, bool value) {
    if (e.id == targetId&&e.type==type) {
      e.isActive = value;
    } else {
      for (var child in e.children) {
        toggleChecked(child, type, targetId, value);
      }
    }
  }

  bool isParentSphereActive(int wishId){
    final parentWish = mainScreenState?.allCircles.where((element) => element.id==wishId).firstOrNull;
    if(parentWish!=null&&parentWish.parenId!=0){
      return isParentSphereActive(parentWish.parenId);
    }else {
      return parentWish?.isActive??true;
    }
  }

  List<CircleData> getParentTree(int targetId) {
    if(mainScreenState==null||targetId==-1)return List.empty();
    List<CircleData> objects = mainScreenState!.allCircles;
    List<CircleData> path = [];

    CircleData targetObject = objects.firstWhere((obj) => obj.id == targetId, orElse: () => CircleData(id: -1, prevId: -1, nextId: -1, text: "", color: Colors.transparent, parenId: -1));

    if (targetObject.id == -1) {
      return path; // Возвращаем пустой список, если объект с заданным идентификатором не найден
    }

    path.add(targetObject);

    while (targetObject.parenId >= 0) {
      targetObject = objects.firstWhere((obj) => obj.id == targetObject.parenId);
      path.add(targetObject);
    }
    return path;
  }

  List<List<CircleData>> getFullBranch(int wishId){
    if(mainScreenState==null||wishId==-1)return List.empty();
    List<int> targetIds = getDeepChild(wishId);
    List<List<CircleData>> result = [];
    for (var element in targetIds) {
      result.add(getParentTree(element));
    }
    return result;
  }

  List<int> getDeepChild(id){
    List<int> result = [];
    final childId = mainScreenState!.allCircles.where((element) => element.parenId==id).toList();
    if(childId.isNotEmpty){
      for (var element in childId) {
        result.addAll(getDeepChild(element.id));
    }
    }else {
      result.add(id);
    }
    return result;
  }
}
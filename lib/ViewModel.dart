import 'dart:typed_data';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wishmap/repository/Repository.dart';
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
  List<MainCircle> mainCircles = [];
  List<Circle> currentCircles = [];
  //mainSphereEdirtScreenn
  CircleData? mainSphereEditCircle;
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

  //appcfg
  var isinLoading = false;

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
    getMoons();
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
    List<CircleData> defaultCircles = [
      CircleData(id: 0, text: 'Я', subText: "состояние", color: const Color(0xFF000000), parenId: -1),
      CircleData(id: 100, text: 'Икигай', color: const Color(0xFFFF0000), parenId: 0),
      CircleData(id: 200, text: 'Любовь', color: const Color(0xFFFF006B), parenId: 0),
      CircleData(id: 300, text: 'Дети', color: const Color(0xFFD9D9D9), parenId: 0),
      CircleData(id: 400, text: 'Путешествия', color: const Color(0xFFFFE600), parenId: 0),
      CircleData(id: 500, text: 'Карьера', color: const Color(0xFF0029FF), parenId: 0),
      CircleData(id: 600, text: 'Образование', color: const Color(0xFF46C8FF), parenId: 0),
      CircleData(id: 700, text: 'Семья', color: const Color(0xFF3FA600), parenId: 0),
      CircleData(id: 800, text: 'Богатство', color: const Color(0xFFB4EB5A), parenId: 0),
    ];
    try {
      DateTime now = DateTime.now();

      var result = await Connectivity().checkConnectivity();
      if(moonItems.isEmpty){
        moonItems = (result!=ConnectivityResult.none)?
        ((await repository.getMoonList())??[]):
        (await localRep.getMoons());
        if((result!=ConnectivityResult.none)){
          await localRep.clearMoons();
          moonItems.forEach((element) {
            localRep.addMoon(element);
          });
        }
      }
      if(moonItems.isEmpty||isDateAfter(now, moonItems.last.date)) {
        int moonId = moonItems.isNotEmpty?moonItems.last.id + 1:0;
        moonItems.add(MoonItem(id: moonId,
            filling: 0.01,
            text: "Я",
            date: "${now.day.toString().padLeft(2, '0')}.${now.month.toString()
                .padLeft(2, '0')}.${now.year}"));
        if(result!=ConnectivityResult.none){
          if(moonItems.length==1) {
            repository.addMoon(moonItems.last, defaultCircles);
          }else{
            List<CircleData> moonCircles = (await repository.getSpheres(moonId-1))??[];
            if(moonCircles.isNotEmpty){
              for (int i=0; i<moonCircles.length; i++){
                moonCircles[i].isActive = false;
              }
              repository.addMoon(moonItems.last, moonCircles);
            }else{
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
    moons.forEach((value) {
      localRep.addMoon(value);
    });
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
      localRep.addSphere(element, moonId);
    });
    isDataFetched--;
  }

  Future fetchAims(int moonId) async{
    final aims = await repository.getMyAimsData(moonId);
    aims?.forEach((element) {
      localRep.addAim(element,mainScreenState?.moon.id??-1);
    });
    isDataFetched--;
  }

  Future fetchTasks(int moonId) async{
    final aims = await repository.getMyTasksData(moonId);
    aims?.forEach((element) {
      localRep.addTask(element,mainScreenState?.moon.id??-1);
    });
    isDataFetched--;
  }

  Future fetchDiary(int moonId) async{
    final diary = await repository.getDiaryList(moonId);
    diary?.forEach((element) {
      localRep.addDiary(element,mainScreenState?.moon.id??-1);
    });
    isDataFetched--;
  }

  Future fetchDatas(int moonId) async{
    if(connectivity!='No Internet Connection'){
      final dDB = await repository.getLastMoonSyncData(moonId);
      final dLoc = await localRep.getMoonLastSyncDate(moonId);
      if(dDB!=null&&dDB>dLoc) {
        await localRep.clearDatabase(moonId);
        await fetchSpheres(moonId);
        await fetchAims(moonId);
        await fetchTasks(moonId);
        await fetchDiary(moonId);
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
        mainScreenState!.allCircles = await localRep.getAllMoonSpheres(mi.id);
        if(mainScreenState!.allCircles.isEmpty) return;
        var ms = mainScreenState!.allCircles.first;
        mainCircles.add(MainCircle(id: ms.id, coords: Pair(key: 0.0, value: 0.0), text: ms.text, substring: ms.subText, color: ms.color, isActive: ms.isActive));
        var cc = mainScreenState!.allCircles.where((element) => element.parenId == mainCircles.last.id).toList();
        currentCircles.clear();
        cc.forEach((element) {
          currentCircles.add(Circle(id: element.id, text: element.text, color: element.color, isActive: element.isActive));
        });
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
        mainCircles.add(MainCircle(id: ms.id, coords: Pair(key: 0.0, value: 0.0), text: ms.text, substring: ms.subText, color: ms.color, isActive: ms.isActive));
        var cc = mainScreenState!.allCircles.where((element) => element.parenId == mainCircles.last.id).toList();
        currentCircles.clear();
        cc.forEach((element) {
          currentCircles.add(Circle(id: element.id, text: element.text, color: element.color, isActive: element.isActive));
        });
        isinLoading=false;
        notifyListeners();
      } catch (ex) {
        addError("#578${ex.toString()}");
      }
    }
  }

  List<Circle>? openSphere(int id) {
    if (mainScreenState != null&&mainScreenState!.allCircles.isNotEmpty) {
      try {
        var mc = mainScreenState!.allCircles.firstWhere((element) => element.id == id);
        id>mainCircles.last.id?mainCircles.add(MainCircle(id: mc.id, coords: Pair(key: 0.0, value: 0.0), text: mc.text, color: mc.color, isActive: mc.isActive)):mainCircles.removeLast();
        var cc = mainScreenState!.allCircles.where((element) => element.parenId == id).toList();
        currentCircles.clear();
        cc.forEach((element) {
          currentCircles.add(Circle(id: element.id, text: element.text, color: element.color, isActive: element.isActive));
        });
      } catch (ex) {
        addError("#5734${ex.toString()}");
      }
      return currentCircles;
    }
    return null;
  }

  Future<void> startWishScreen(int wishId, int parentId) async{
    try {
      cachedImages.clear();
      myNodes.clear();
      WishData wdItem;
      var tmp = mainScreenState!.allCircles.where((element) => element.id==wishId);
      if(tmp.isNotEmpty){
        /*isDataFetched!=0?wdItem = (await repository.getMyWish(wishId, mainScreenState!.moon.id)) ?? WishData(id: -100, parentId: 0, text: "не удалось загрузить данные", description: "", affirmation: "", color: Colors.transparent):*/
        wdItem = (await localRep.getSphere(wishId, mainScreenState!.moon.id)) ?? WishData(id: -100, parentId: 0, text: "не удалось загрузить данные", description: "", affirmation: "", color: Colors.transparent);
      }else{
        wdItem = WishData(id: wishId, parentId: parentId, text: "", description: "", affirmation: "", color: Colors.green);
      }
      wishScreenState = WishScreenState(wish: wdItem);
      notifyListeners();
    }catch(ex, s){
      addError("#436${ex.toString()}");
      print("sssssssssssssssss $s");
    }
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
    }catch(ex){
      addError("#01 Ошибка загрузки задач: $ex");
    }
  }

  Future<void> startMainsphereeditScreen() async{
    try {
      isinLoading = true;
      if(aimItems.isEmpty) {
        /*aimItems = isDataFetched!=0?((await repository.getMyAims(mainScreenState?.moon.id??0)) ?? []):*/
        await localRep.getAllAims(mainScreenState?.moon.id??0);
      }
      if(taskItems.isEmpty) {
        /*taskItems = isDataFetched!=0?((await repository.getMyTasks(mainScreenState?.moon.id??0)) ?? []):*/
      await localRep.getAllTasks(mainScreenState?.moon.id??0);
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
      await localRep.getAllAims(mainScreenState?.moon.id??0);
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

  Future<void> createNewSphereWish(WishData wd) async{
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
      localRep.updateSphereImages(wd.id, photosIds,mainScreenState?.moon.id??0);
      wd.photos = photos;
      if(connectivity != 'No Internet Connection')await repository.createSphereWish(wd, mainScreenState?.moon.id??0);
      await localRep.insertORudateSphere(wd, mainScreenState?.moon.id??0);
      var sphereInAllCircles= mainScreenState!.allCircles.indexWhere((element) => element.id==wd.id);
      if(sphereInAllCircles==-1){
        mainScreenState!.allCircles.add(CircleData(id: wd.id, text: wd.text, color: wd.color, parenId: wd.parentId));
        mainScreenState!.allCircles.sort((a,b)=>a.id.compareTo(b.id));
        if(wd.id > 899)wishItems.add(WishItem(id: wd.id, text: wd.text, isChecked: wd.isChecked));
      }
      else{
        mainScreenState!.allCircles[sphereInAllCircles]
        ..text = wd.text
        ..color = wd.color
        ..isActive = true;
        if(mainCircles.last.id==wd.id) mainCircles.last..color=wd.color..text=wd.text..isActive=true;
      }
      var sphereInWishesList = wishItems.indexWhere((element) => element.id==wd.id);
      if(sphereInWishesList>=0){
        wishItems[sphereInWishesList]=WishItem(id: wd.id, text: wd.text, isChecked: wd.isChecked);
      }
    }catch(ex){
      addError("сфера не была сохранена: $ex");
    }
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
      localRep.updateSphereImages(wd.id, photosIds,mainScreenState?.moon.id??0);
      wd.photos = photos;
      if(connectivity != 'No Internet Connection')await repository.createSphereWish(wd, mainScreenState?.moon.id??0);
      await localRep.insertORudateSphere(wd, mainScreenState?.moon.id??0);
      mainScreenState!.allCircles[mainScreenState!.allCircles.indexWhere((element) => element.id==wd.id)] = CircleData(id: wd.id, text: wd.text, color: wd.color, parenId: wd.parentId, affirmation: wd.affirmation, subText: wd.description)..photosIds=photosIds;
    }catch(ex){
      addError("сфера не была сохранена: $ex");
    }
  }
  Future<void> deleteSphereWish(int id) async{
    try {
      if(mainScreenState!=null){
        for (var element in mainScreenState!.allCircles) {
          if(element.parenId==id){
            deleteSphereWish(element.id);
          }
        }
      }
      await deleteallChildAims(id);
      if(connectivity != 'No Internet Connection')await repository.deleteSphereWish(id, mainScreenState?.moon.id??0);
      await localRep.deleteSphere(id,mainScreenState?.moon.id??0);
    }catch(ex){
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
          var wishes = getFullBranch(wishId);
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
      notifyListeners();
    }catch(ex){
      addError("#566${ex.toString()}");
    }
  }

  Future<int?> createAim(AimData ad, int parentCircleId) async{
    try {
      //int? aimId = (await repository.createAim(ad, parentCircleId, mainScreenState?.moon.id??0))??-1;
      int aimId = await localRep.addAim(AimData(id: -1, parentId: parentCircleId, text: ad.text, description: ad.description), mainScreenState?.moon.id??-1);
      currentAim=(AimData(id: aimId, parentId: ad.parentId, text: ad.text, description: ad.description, isChecked: ad.isChecked));
      aimItems.add(AimItem(id: aimId,parentId: parentCircleId, text: ad.text, isChecked: ad.isChecked));
      return aimId;
    }catch(ex){
      addError("#5711${ex.toString()}");
    }
  }
  Future getAim(int id) async{
    try{
      if(mainScreenState!=null) {
        /*currentAim = isDataFetched!=0?await repository.getMyAim(id, mainScreenState!.moon.id):*/
        await localRep.getAim(id,mainScreenState?.moon.id??0);
        notifyListeners();
      } else {
        throw Exception("#2365 lost datas");
      }
    }catch(ex){
      addError("#764$ex");
    }
  }
  Future<void> updateAim(AimData ad) async{
    try {
      if(connectivity != 'No Internet Connection')await repository.updateAim(ad, mainScreenState?.moon.id??0);
      await localRep.updateAim(ad,mainScreenState?.moon.id??0);
      currentAim=(AimData(id: ad.id, parentId: ad.parentId, text: ad.text, description: ad.description, isChecked: ad.isChecked));
    }catch(ex){
      addError("#518${ex.toString()}");
    }
  }
  Future<void> deleteAim(int aimId) async{
    try {
      await deleteallChildTasks(aimId);
      if(connectivity != 'No Internet Connection')await repository.deleteAim(aimId, mainScreenState?.moon.id??0);
      localRep.deleteAim(aimId,mainScreenState?.moon.id??0);
      aimItems.removeWhere((element) => element.id == aimId);
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
      notifyListeners();
    }catch(ex){
      addError("#520${ex.toString()}");
    }
  }

  Future<int?> createTask(TaskData ad, int parentAimId) async{
    try {
      //int taskId = (await repository.createTask(ad, parentAimId, mainScreenState?.moon.id??0))??-1;
      int taskId = await localRep.addTask(TaskData(id: -1, parentId: parentAimId, text: ad.text, description: ad.description), mainScreenState?.moon.id??-1);
      currentTask=(TaskData(id: taskId, parentId: ad.parentId, text: ad.text, description: ad.description, isChecked: ad.isChecked));
      taskItems.add(TaskItem(id: taskId, parentId: parentAimId, text: ad.text, isChecked: ad.isChecked));
      return taskId;
    }catch(ex){
      addError("#522${ex.toString()}");
    }
  }
  Future getTask(int id) async{
    try{
      if(mainScreenState!=null) {
        /*currentTask = isDataFetched!=0?await repository.getMyTask(id, mainScreenState!.moon.id):*/
        await localRep.getTask(id,mainScreenState?.moon.id??0);
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
      currentTask=(TaskData(id: ad.id, parentId: ad.parentId, text: ad.text, description: ad.description, isChecked: ad.isChecked));
    }catch(ex){
      addError("#524${ex.toString()}");
    }
  }
  Future<void> deleteTask(int taskId) async{
    try {
      if(connectivity != 'No Internet Connection')await repository.deleteTask(taskId, mainScreenState?.moon.id??0);
      await localRep.deleteTask(taskId,mainScreenState?.moon.id??0);
      taskItems.removeWhere((element) => element.id == taskId);
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
      notifyListeners();
    }catch(ex){
      addError("#528${ex.toString()}");
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
    List<MyTreeNode> children = <MyTreeNode>[MyTreeNode(id: circle.id, type: "a", title: circle.text, isChecked: circle.isChecked, children: (taskList?.map((e) =>  MyTreeNode(id: e.id, type: 't', title: e.text, isChecked: e.isChecked)))?.toList()??[])..noClickable=true];
    for (var element in allCircles) {
      children=[MyTreeNode(id: element.id, type: element.id==0?"m":"w", title: element.text, children: children, isChecked: element.isChecked)];
    }
    myNodes = children;
    notifyListeners();
  }

  Future<List<MyTreeNode>> convertToMyTreeNodeIncludedAimsTasks(MyTreeNode aimNode, int taskId, int wishId) async {
    final taskList = await getTasksForAim(aimNode.id);
    List<CircleData> allCircles = getParentTree(wishId);
    List<MyTreeNode> children = <MyTreeNode>[MyTreeNode(id: aimNode.id, type: "a", title: aimNode.title, isChecked: aimNode.isChecked, children: (taskList?.map((e) =>  MyTreeNode(id: e.id, type: 't', title: e.text, isChecked: e.isChecked)..noClickable=e.id==taskId?true:false))?.toList()??[])];
    for (var element in allCircles) {
      children=[MyTreeNode(id: element.id, type: element.id==0?"m":"w", title: element.text, isChecked:  element.isChecked, children: children)];
    }
    myNodes= children;
    notifyListeners();
    return children;
  }
  Future<List<MyTreeNode>> convertToMyTreeNodeFullBranch(int wishId) async {
    final fullBranch = getFullBranch(wishId);
    taskItems = /*isDataFetched!=0?((await repository.getMyTasks(mainScreenState!.moon.id))??[]):*/
    await localRep.getAllTasks(mainScreenState?.moon.id??0);
    aimItems = /*isDataFetched!=0?((await repository.getMyAims(mainScreenState!.moon.id))??[]):*/
    await localRep.getAllAims(mainScreenState?.moon.id??0);
    MyTreeNode? root;
    for (var melement in fullBranch) {
      final List<MyTreeNode> childNodes = [];
      final chilldAims = aimItems.where((element) => element.parentId==melement.id);
      for (var e in chilldAims) {
        final childTasks = taskItems.where((item) => item.parentId==e.id);
        childNodes.add(MyTreeNode(id: e.id, type: 'a', title: e.text, isChecked: e.isChecked, children: (childTasks.map((t) => MyTreeNode(id: t.id, type: 't', title: t.text, isChecked: t.isChecked))).toList()));
      }
      if(root != null)childNodes.add(root);
      root = MyTreeNode(id: melement.id, type: melement.id==0?"m":"w", title: melement.text, isChecked: melement.isChecked,children: childNodes)..noClickable=melement.id==wishId?true:false;
    }
    if(root!=null) {
      myNodes= [root];
      notifyListeners();
      return [root];
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

  List<CircleData> getParentTree(int targetId) {
    if(mainScreenState==null||targetId==-1)return List.empty();
    List<CircleData> objects = mainScreenState!.allCircles;
    List<CircleData> path = [];

    CircleData targetObject = objects.firstWhere((obj) => obj.id == targetId, orElse: () => CircleData(id: -1, text: "", color: Colors.transparent, parenId: -1));

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

  List<CircleData> getFullBranch(int wishId){
    if(mainScreenState==null||wishId==-1)return List.empty();
    int targetId = getDeepChild(wishId);
    return getParentTree(targetId);
  }

  int getDeepChild(id){
    final childId = mainScreenState!.allCircles.firstWhere((element) => element.parenId==id, orElse: () => CircleData(id: -1, text: "text", color: Colors.transparent, parenId: -1));
    if(childId.id>0){return getDeepChild(childId.id);}
    else {return id;}
  }
}
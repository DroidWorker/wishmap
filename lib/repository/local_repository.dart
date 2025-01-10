import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wishmap/repository/dbHelper.dart';

import '../data/models.dart';
import '../testModule/testingEngine/data/adminModule.dart';

class LocalRepository {
  SharedPreferences? _prefs;
  late final DatabaseHelper dbHelper;

  List<int> spheresToActivate = [];
  List<int> aimsToActivate = [];
  List<int> tasksToActivate = [];

  List<TaskData> tasksToAdd = [];
  List<AimData> aimsToAdd = [];

  LocalRepository() {
    init();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    dbHelper = DatabaseHelper();
  }

  //<--admin prefs
  saveCalculation(List<CalculationStep> steps) async {
    String stepsJson = jsonEncode(steps.map((step) => step.toJson()).toList());
    if (_prefs == null) {
      await init();
    }
    _prefs!.setString("CircularDiagramCalculation",
        stepsJson);
  }

  List<CalculationStep> getCalculation() {
    try {
      final stepsJson = _prefs!.getString("CircularDiagramCalculation") ?? "";
      List<dynamic> jsonResponse = jsonDecode(stepsJson);
      List<CalculationStep> steps = jsonResponse.map((json) =>
          CalculationStep.fromJson(json)).toList();
      return steps;
    }catch(ex, s){
      print("paaaaaarce - $ex - $s");
      return [];
    }
  }
  //-->admin prefs

  //lockScreen
  Future saveLockParams(LockParams lp) async {
    String sstr(String input) {
      final h = (input.hashCode % 100).toInt();
      return "${(h - int.parse(input[0])).toString().padLeft(2, "0")}${(h - int.parse(input[1])).toString().padLeft(2, "0")}${(h - int.parse(input[2])).toString().padLeft(2, "0")}${(h - int.parse(input[3])).toString().padLeft(2, "0")}${h}";
    }

    if (_prefs == null) {
      await init();
    }
    _prefs!.setString("appPassword",
        lp.password.isNotEmpty ? sstr(lp.password) : lp.password);
    _prefs!.setInt("enableFingerprint", lp.allowFingerprint ? 1 : 0);
  }

  Future setTestPassed() async{
    if (_prefs == null) {
      await init();
    }
    _prefs!.setBool("testPassed",true);
  }

  Future<bool> getTestPassed() async{
    return _prefs!.getBool("testPassed")??false;
  }

  LockParams getLockParams() {
    String unsstr(String input) {
      final h = int.parse(input.substring(8, 10));
      return "${h - int.parse(input.substring(0, 2))}${h - int.parse(input.substring(2, 4))}${h - int.parse(input.substring(4, 6))}${h - int.parse(input.substring(6, 8))}";
    }

    final pass = _prefs!.getString("appPassword");
    final enableFingerprint = _prefs!.getInt("enableFingerprint");
    return LockParams(
        password: pass != null && pass.isNotEmpty ? unsstr(pass) : "",
        allowFingerprint: enableFingerprint == 1 ? true : false);
  }

  Future<String> getLockPass() async {
    if (_prefs == null) {
      await init();
    }
    final pass = _prefs!.getString("appPassword");
    return pass ?? "";
  }

//auth&reg
  Future<void> saveAuth(String login, String password) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    _prefs!.setString("login", login);
    _prefs!.setString("password", password);
  }

  Future<void> clearAuth() async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    _prefs!.remove("login");
    _prefs!.remove("password");
  }

  Future<AuthData?> getAuth() async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    String? login = _prefs!.getString("login");
    String? password = _prefs!.getString("password");
    return (login != null && password != null)
        ? AuthData(login: login, password: password)
        : null;
  }

  bool alarmsChecked() {
    final result = _prefs?.getBool("alarmsChecked") ?? false;
    _prefs?.setBool("alarmsChecked", true);
    return result;
  }

  set setAlarmsChecked(bool v) {
    _prefs?.setBool("alarmsChecked", v);
  }

  //actualizing
  Future<void> saveActSetting(ActualizingSettingData settings) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    _prefs!.setBool("actualizeFullBranch", settings.actualizeFullBranch);
    _prefs!.setBool("fastActMainSphere", settings.fastActMainSphere);
    _prefs!.setInt("taskActualizingMode", settings.taskActualizingMode);
    _prefs!.setInt("wishActualizingMode", settings.wishActualizingMode);
    _prefs!.setBool("fastActualizingWish", settings.fastActWish);
    _prefs!.setInt("sphereActualizingMode", settings.sphereActualizingMode);
    _prefs!.setBool("fastActualizingSphere", settings.fastActSphere);
    _prefs!.setInt("quoteUpdateFreq", settings.quoteupdateFreq);
    _prefs!.setInt("treeView", settings.treeView);
    _prefs!.setBool("animationEnabled", settings.animationEnabled);
  }

  Future<ActualizingSettingData> getActSetting() async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    ActualizingSettingData settings = ActualizingSettingData();
    settings.actualizeFullBranch =
        _prefs!.getBool("actualizeFullBranch") ?? true;
    settings.fastActMainSphere = _prefs!.getBool("fastActMainSphere") ?? true;
    settings.sphereActualizingMode =
        _prefs!.getInt("sphereActualizingMode") ?? 1;
    settings.fastActSphere = _prefs!.getBool("fastActualizingSphere") ?? true;
    settings.wishActualizingMode = _prefs!.getInt("wishActualizingMode") ?? 0;
    settings.fastActWish = _prefs!.getBool("fastActualizingWish") ?? true;
    settings.taskActualizingMode = _prefs!.getInt("taskActualizingMode") ?? 0;
    settings.quoteupdateFreq = _prefs!.getInt("quoteUpdateFreq") ?? 10;
    settings.treeView = _prefs!.getInt("treeView") ?? 0;
    return settings;
  }

  //hints
  Future<void> saveHintState(String key, int value) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    _prefs!.setInt(key, value);
  }

  Map<String, int> getHintStates() {
    Map<String, int> settings = {};
    settings["firstOpenSphere"] = _prefs!.getInt("firstOpenSphere") ?? 0;
    settings["wheelClickNum"] = _prefs!.getInt("wheelClickNum") ?? 0;
    //settings[] = _prefs!.getBool("taskActualizingMode")??false;
    return settings;
  }

  Future<void> saveUserColor(Color value) async {
    if (_prefs == null) {
      await init();
    }
    final colors = _prefs?.getString("userColor") ?? "";
    _prefs!.setString(
        "userColor",
        colors.isEmpty
            ? colors + value.value.toString()
            : "$colors|${value.value}");
  }

  List<Color> getUserColors() {
    List<Color> userColors = [];
    final colorsStr = _prefs!.getString("userColor") ?? "";
    userColors = colorsStr.isNotEmpty
        ? colorsStr.split("|").map((e) => Color(int.parse(e))).toList()
        : [];
    return userColors;
  }

  //music
  Future<void> saveTrack(String name, String path) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    String resstr = _prefs!.getString("music") ?? "";
    resstr += resstr != "" ? "<<$name|$path" : "$name|$path";
    _prefs!.setString("music", resstr);
  }

  Future<void> updateTracks(Map<String, String> trackDatas) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    String data = "";
    trackDatas.forEach((key, value) {
      if (data != "") data += "<<";
      data += "$key|$value";
    });
    _prefs!.setString("music", data);
  }

  Map<String, String> getTracks() {
    Map<String, String> tracks = {};
    final tracksStr = _prefs!.getString("music") ?? "";
    tracksStr.split("<<").forEach((element) {
      if (element.isNotEmpty) {
        final musicEntry = element.split("|");
        tracks[musicEntry[0]] = musicEntry[1];
      }
    });
    return tracks;
  }

  Future<void> cacheTrackNames(Map<String, String> trackDatas) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    String data = "";
    trackDatas.forEach((key, value) {
      if (data != "") data += "<<";
      data += "$key|$value";
    });
    _prefs!.setString("trackDatas", data);
  }

  Map<String, String> getCachedTrackNames() {
    Map<String, String> tracksNames = {};
    final tracksStr = _prefs!.getString("trackDatas") ?? "";
    tracksStr.split("<<").forEach((element) {
      if (element.isNotEmpty) {
        final musicEntry = element.split("|");
        tracksNames[musicEntry[0]] = musicEntry[1];
      }
    });
    return tracksNames;
  }

  Future<void> saveProfile(ProfileData pd) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    await _prefs!.setString("id", pd.id);
    await _prefs!.setString("name", pd.name);
    await _prefs!.setString("surname", pd.surname);
    await _prefs!.setString("lastname", pd.thirdname);
    await _prefs!.setString("birthday", pd.birtday.toString());
    await _prefs!.setBool("male", pd.male);
    await _prefs!.setString("email", pd.email);
    await _prefs!.setString("phone", pd.phone);
    await _prefs!.setString("tg", pd.tg);
  }

  Future<void> clearProfile() async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    await _prefs!.remove("id");
    await _prefs!.remove("name");
    await _prefs!.remove("surname");
  }

  Future<ProfileData?> getProfile() async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }

    String? id = _prefs!.getString("id");
    String? name = _prefs!.getString("name");
    String? surname = _prefs!.getString("surname");
    String? lastname = _prefs!.getString("lastname");
    String? birthday = _prefs!.getString("birthday");
    bool? male = _prefs!.getBool("male");
    String? email = _prefs!.getString("email");
    String? phone = _prefs!.getString("phone");
    String? tg = _prefs!.getString("tg");
    return (id != null && name != null && surname != null)
        ? ProfileData(
            id: id,
            name: name,
            surname: surname,
            birtday: birthday != null
                ? DateTime.parse(birthday)
                : DateTime(2000, 9, 7, 17, 30),
            male: male ?? true,
            email: email ?? "",
            thirdname: lastname ?? "",
            phone: phone ?? "",
            tg: tg ?? "")
        : null;
  }

  Future<void> removeData(String key) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    _prefs!.remove(key);
  }

  Future clearDatabase(int moonId) async {
    await dbHelper.clearDatabase(moonId);
  }

  Future dropDB() async {
    await dbHelper.dropDatabase();
  }

  Future updateMoonSync(int moonId, int timestamp) async {
    await dbHelper.updateLastMoonSync(moonId, timestamp);
  }

  Future<int> getImageLastId() async {
    return await dbHelper.getImageLastId();
  }

  Future<Uint8List> getImage(int id) async {
    final result = await dbHelper.getImage(id);
    return base64Decode(result.first['img'].toString());
  }

  Future addImage(int id, Uint8List image) async {
    dbHelper.insertImage(id, base64Encode(image));
  }

  Future addImageStr(int id, String image) async {
    dbHelper.insertImage(id, image);
  }

  Future addMoon(MoonItem mi) async {
    dbHelper.insertMoon(mi);
  }

  Future clearMoons() async {
    dbHelper.clearMoons();
  }

  Future deleteMoons(List<int> moonIds) async {
    await dbHelper.deleteMoons(moonIds.join(','));
  }

  Future addAllMoons(MoonItem mi, List<CircleData>? childCircles,
      List<WishData>? childWishes) async {
    await dbHelper.insertMoon(mi);
    if (childWishes != null)
      await dbHelper.insertSphere(childWishes, mi.id);
    else if (childCircles != null) {
      List<WishData> wishes = [];
      childCircles.forEach((element) async {
        wishes.add(WishData(
            id: element.id,
            prevId: element.prevId,
            nextId: element.nextId,
            parentId: element.parenId,
            text: element.text,
            description: element.subText,
            affirmation: element.affirmation,
            color: element.color)
          ..isActive = element.isActive
          ..isChecked = element.isChecked
          ..isHidden = element.isHidden);
      });
      await dbHelper.insertSphere(wishes, mi.id);
    }
  }

  Future<List<MoonItem>> getMoons() async {
    final moons = (await dbHelper.getAllMoons());
    return moons
        .map((e) => MoonItem(
            id: e["id"],
            filling: e["filling"],
            text: e["text"],
            date: e["date"]))
        .toList();
  }

  Future<int> getMoonLastSyncDate(int moonId) async {
    final moon = await dbHelper.getMoon(moonId);
    try {
      return int.parse(moon.first["lastSyncDate"].toString());
    } catch (ex) {
      return -1;
    }
  }

  Future<WishData?> getSphere(int id, int moonId) async {
    final result = await dbHelper.getSphere(id, moonId);
    Map<String, dynamic> tmp = jsonDecode(result['childAims']);
    Map<String, int> chAims =
        tmp.map((key, value) => MapEntry(key, int.parse(value.toString())));
    return (result.isNotEmpty
        ? (WishData(
            id: result["id"],
            prevId: result['prevId'],
            nextId: result['nextId'],
            parentId: result["parentId"],
            text: result["text"],
            description: result["subtext"],
            affirmation: result["affirmation"].toString(),
            color: Color(int.parse(result["color"].toString())))
          ..childAims = chAims
          ..photoIds = result['photosIds']
          ..isChecked = result['isChecked'] == "1" ? true : false
          ..isActive = result["isActive"] == "1" ? true : false
          ..isHidden = result['isHidden'] == 1 ? true : false
          ..shuffle = result['shuffle'] == 1 ? true : false
          ..lastShuffle = result['lastShuffle'])
        : null);
  }

  Future<List<WishItem>> getAllSpheres(int moonId) async {
    final result = await dbHelper.getAllSpheres(moonId);
    List<WishItem> list = result
        .map((e) => WishItem(
            id: e['id'],
            parentId: e['parentId'],
            text: e['text'],
            isChecked: e['isChecked'] == "1" ? true : false,
            isActive: e['isActive'].toString() == "1" ? true : false,
            isHidden: e['isHidden'] == 1 ? true : false))
        .toList();
    return list.where((element) => element.parentId > 1).toList();
  }

  Future<List<CircleData>> getAllMoonSpheres(int moonId) async {
    final result = await dbHelper.getAllMoonSpheres(moonId);
    List<CircleData> list = result
        .map((e) {
              var t = CircleData(
                id: e['id'],
                prevId: e['prevId'],
                nextId: e['nextId'],
                parenId: e['parentId'],
                text: e['text'],
                affirmation: e['affirmation'],
                color: Color(e['color']),
                subText: e['subtext'],
                photosIds: e['photosIds'],
                isHidden: e['isHidden'] == 1 ? true : false,
                isActive: e['isActive'] == "1" ? true : false,
                isChecked: e['isChecked'] == "1" ? true : false,
              );
                t.shuffle = e['shuffle'] == 1 ? true : false;
                t.lastShuffle = e['lastShuffle'];
              return t;
            })
        .toList();
    //filter list for queqe displaying
    return sortList(list);
  }

  Future<List<int>> getSpheresChildAims(int id, int moonId) async {
    final result = await dbHelper.getSphere(id, moonId);
    Map<String, dynamic> tmp = jsonDecode(result['childAims']);
    Map<String, int> chAims =
        tmp.map((key, value) => MapEntry(key, int.parse(value.toString())));
    return chAims.values.toList();
  }

  Future addSphere(WishData wd, int moonId) async {
    await dbHelper.insertSphere([wd], moonId);
  }

  Future insertORudateSphere(WishData wd, int moonId) async {
    await dbHelper.insertOrUpdateSphere(wd, moonId);
  }

  Future updateSphereNeighbours(
      int sphereId, bool updateNextId, int newValue, int moonId) async {
    await dbHelper.updateSphereNeighbours(
        sphereId, updateNextId, newValue, moonId);
  }

  Future deleteSphere(int sphereId, int moonId) async {
    await dbHelper.deleteSphere(sphereId, moonId);
  }

  Future updateSphereStatus(int sphereId, bool status, int moonId) async {
    await dbHelper.updateSphereStatus(sphereId, status, moonId);
  }

  activateSphere(int sphereId) {
    spheresToActivate.add(sphereId);
  }

  Future commitASpheresActivation(bool status, int moonId) async {
    await dbHelper.activateSpheres(spheresToActivate, status, moonId);
    spheresToActivate.clear();
  }

  Future hideSphere(int sphereId, bool isHide, int moonId) async {
    await dbHelper.hideSphere(sphereId, isHide, moonId);
  }

  Future updateSphereImages(int sphereId, String imageIds, int moonId) async {
    final t = await dbHelper.updateSphereImages(sphereId, imageIds, moonId);
  }

  Future updateSphereShuffle(
      int sphereId, bool shuffle, String lastShuffle, int moonId) async {
    final t = await dbHelper.updateSphereShuffle(
        sphereId, shuffle, lastShuffle, moonId);
  }

  Future updateWishChildren(int wishId, int removableId, int moonId) async {
    var chAims = await getSpheresChildAims(wishId, moonId);
    chAims.removeWhere((element) => element == removableId);
    await dbHelper.updateWishChildren(wishId, chAims, moonId);
  }

  Future<AimData> getAim(int id, int moonId) async {
    final result = await dbHelper.getAim(id, moonId);
    return AimData(
        id: result['id'],
        parentId: result['parentId'],
        text: result['text'],
        description: result['subtext'])
      ..isChecked = result['isChecked'] == "1" ? true : false
      ..isActive = result["isActive"] == "1" ? true : false
      ..childTasks = (result['childTasks'] != null &&
              result['childTasks'].toString() != "")
          ? result['childTasks']
              .toString()
              .split("|")
              .map((e) => int.parse(e))
              .toList()
          : [];
  }

  Future<List<AimItem>> getAllAims(int moonId) async {
    final result = await dbHelper.getAllAims(moonId);
    return result
        .map((e) => AimItem(
            id: e['id'],
            parentId: e['parentId'],
            text: e['text'],
            isChecked: e['isChecked'] == "1" ? true : false,
            isActive: e['isActive'] == '1' ? true : false))
        .toList();
  }

  Future<List<AimData>> getAllAimsData(int moonId) async {
    final result = await dbHelper.getAllAims(moonId);
    return result
        .map((e) => AimData(
            id: e['id'],
            parentId: e['parentId'],
            text: e['text'],
            isChecked: e['isChecked'] == "1" ? true : false,
            isActive: e["isActive"] == "1" ? true : false,
            description: e['subtext'])
          ..childTasks =
              (e['childTasks'] != null && e['childTasks'].toString() != "")
                  ? e['childTasks']
                      .toString()
                      .split("|")
                      .map((e) => int.parse(e))
                      .toList()
                  : [])
        .toList();
  }

  Future<List<int>> getAimsChildTasks(int id, int moonId) async {
    final result = await dbHelper.getAim(id, moonId);
    print("result aim - ${result['childTasks']}");
    return (result['childTasks'] != null &&
            result["childTasks"].toString() != "")
        ? result['childTasks']
            .toString()
            .split("|")
            .map((e) => int.parse(e))
            .toList()
        : [];
  }

  Future<int> addAim(AimData ad, int moonId) async {
    print("adaim ${ad.childTasks}");
    final aims = await getAllAims(moonId);
    await dbHelper.insertAim(
        AimData(
            id: ad.id == -1
                ? (aims.length > 0 ? aims[aims.length - 1].id : -1) + 1
                : ad.id,
            parentId: ad.parentId,
            text: ad.text,
            description: ad.description,
            isChecked: ad.isChecked,
            isActive: ad.isActive)
          ..childTasks = ad.childTasks,
        moonId);
    int retId = ad.id == -1
        ? (aims.length > 0 ? aims[aims.length - 1].id : -1) + 1
        : ad.id;
    return retId;
  }

  addAllAims(AimData ad) {
    aimsToAdd.add(ad);
  }

  Future commitAimsAdd(int moonId) async {
    await dbHelper.addAllAims(aimsToAdd, moonId);
    aimsToAdd.clear();
  }

  Future deleteAim(int aimId, int moonId) async {
    await dbHelper.deleteAim(aimId, moonId);
  }

  Future updateAim(AimData ad, int moonId) async {
    await dbHelper.updateAim(ad, moonId);
  }

  Future updateAimStatus(int aimId, bool status, int moonId) async {
    await dbHelper.updateAimStatus(aimId, status, moonId);
  }

  Future updateAimChildren(int aimId, int removableId, int moonId) async {
    var chTasks = await getAimsChildTasks(aimId, moonId);
    chTasks.removeWhere((element) => element == removableId);
    await dbHelper.updateAimChildren(aimId, chTasks, moonId);
  }

  activateAim(int aimId) {
    aimsToActivate.add(aimId);
  }

  Future commitAimsActivation(bool status, int moonId) async {
    await dbHelper.activateAim(aimsToActivate, moonId);
    aimsToActivate.clear();
  }

  Future<TaskData> getTask(int id, int moonId) async {
    final result = await dbHelper.getTask(id, moonId);
    return TaskData(
        id: result['id'],
        parentId: result['parentId'],
        text: result['text'],
        description: result['subtext'],
        isActive: result["isActive"] == "1" ? true : false)
      ..isChecked = result['isChecked'] == "1" ? true : false;
  }

  Future<List<TaskItem>> getAllTasks(int moonId) async {
    final result = await dbHelper.getAllTasks(moonId);
    return result
        .map((e) => TaskItem(
            id: e['id'],
            parentId: e['parentId'],
            text: e['text'],
            isChecked: e['isChecked'] == '1' ? true : false,
            isActive: e['isActive'] == '1' ? true : false))
        .toList();
  }

  Future<List<TaskData>> getAllTasksData(int moonId) async {
    final result = await dbHelper.getAllTasks(moonId);
    return result
        .map((e) => TaskData(
            id: e['id'],
            parentId: e['parentId'],
            text: e['text'],
            isChecked: e['isChecked'] == '1' ? true : false,
            isActive: e["isActive"] == "1" ? true : false,
            description: e['subtext']))
        .toList();
  }

  Future addTask(TaskData td, int moonId) async {
    final tasks = await getAllTasks(moonId);
    await dbHelper.insertTask(
        TaskData(
            id: td.id == -1 ? (tasks.lastOrNull?.id ?? -1) + 1 : td.id,
            parentId: td.parentId,
            text: td.text,
            description: td.description,
            isChecked: td.isChecked,
            isActive: td.isActive),
        moonId);
    int retId = td.id == -1
        ? (tasks.length > 0 ? tasks[tasks.length - 1].id : -1) + 1
        : td.id;
    return retId;
  }

  Future addAllTasks(TaskData td) async {
    tasksToAdd.add(td);
  }

  Future commitTasksAdd(int moonId) async {
    await dbHelper.addAllTasks(tasksToAdd, moonId);
    tasksToAdd.clear();
  }

  Future deleteTask(int taskId, int moonId) async {
    await dbHelper.deleteTask(taskId, moonId);
  }

  Future updateTask(TaskData td, int moonId) async {
    await dbHelper.updateTask(td, moonId);
  }

  Future updateTaskStatus(int taskId, bool status, int moonId) async {
    await dbHelper.updateTaskStatus(taskId, status, moonId);
  }

  activateTask(int taskId) {
    tasksToActivate.add(taskId);
  }

  Future commitTasksActivation(bool status, int moonId) async {
    await dbHelper.activateTask(tasksToActivate, moonId);
    tasksToActivate.clear();
  }

  Future<List<CardData>> getAllDiary() async {
    final result = await dbHelper.getAllDiary();
    print("result - $result");
    return result
        .map((e) => CardData(
            id: e['id'],
            emoji: e['emoji'],
            title: e['title'],
            description: e['description'],
            text: e['text'],
            color: Color(int.parse(e["color"].toString()))))
        .toList();
  }

  Future<List<Article>> getArticles(int diaryId) async {
    final result = await dbHelper.getDiaryArticles(diaryId);
    return result
        .map((e) => Article(
            e['rowId'],
            e['parentDiaryId'],
            e['text'],
            e['date'],
            e['time'],
            (e['attacments'] != null)
                ? e['attacments'].toString().split("|")
                : []))
        .toList();
  }

  duplicateArticles(int oldMoonId, newMoonId){
    dbHelper.duplicateArticles(oldMoonId, newMoonId);
  }

  addDiary(CardData cd) {
    print("inseeert diary ${cd}");
    dbHelper.insertDiary(cd);
  }

  Future<int> addDiaryArticle(Article article) async {
    return await dbHelper.insertDiaryArticle(article);
  }

  Future addAllDiary(List<CardData> cd) async {
    for (var element in cd) {
      print("addddddiary - ${element}");
      await dbHelper.insertDiary(element);
    }
  }

  Future updateDiary(CardData cd) async {
    await dbHelper.updateDiary(cd);
  }

  Future updateDiaryArticle(String text, List<String> attachmentsList,
      int articleId) async {
    await dbHelper.updateArticle(text, attachmentsList, articleId);
  }

  void deleteDiary(int diaryId) async {
    await dbHelper.deleteDiary(diaryId);
  }

  void deleteArticle(articleId) async {
    await dbHelper.deleteArticle(articleId);
  }

  Future<List<Reminder>> getReminders(int taskId) async {
    return await dbHelper.getRemindersForTask(taskId);
  }

  Future addReminder(Reminder reminder) async {
    await dbHelper.insertReminder(reminder);
  }

  Future updateReminder(Reminder reminder) async {
    await dbHelper.updateReminder(reminder);
  }

  Future deleteReminder(int id) async {
    await dbHelper.deleteReminder(id);
  }

  Future<List<Alarm>> getAlarms(String? userId) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    return await dbHelper
        .selectAlarms(userId ?? _prefs!.getString("id") ?? "0");
  }

  Future<Alarm?> getAlarmById(int id) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    return await dbHelper.selectAlarm(id, _prefs!.getString("id") ?? "0");
  }

  Future addAlarm(Alarm alarm) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    await dbHelper.insertAlarm(alarm, _prefs!.getString("id") ?? "0");
  }

  Future updateAlarm(Alarm alarm) async {
    await dbHelper.updateAlarm(alarm);
  }

  Future deleteAlarm(int id) async {
    await dbHelper.deleteAlarm(id);
  }

  Future<Map<String, String>> getQ() async {
    return await dbHelper.getQuestions();
  }

  Future<Map<String, String>> getStatic() async {
    return await dbHelper.getStatic();
  }

  void commitAddQ(Map<String, String> questions) {
    dbHelper.addAllQuestions(questions);
  }

  void commitAddStatic(Map<String, String> static) {
    dbHelper.addAllStatic(static);
  }

  Future<void> addPromocode(Promocode promocode, String userId) async {
    dbHelper.addPromocode(promocode, userId);
  }

  Future<Map<String, String>> getPromocodes(String userId,
      {String? pType}) async {
    return await dbHelper.getPromocodes(userId, pType);
  }
}

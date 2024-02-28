import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wishmap/repository/dbHelper.dart';

import '../data/models.dart';

class LocalRepository{
  SharedPreferences? _prefs;
  late final DatabaseHelper dbHelper;

  LocalRepository() {
    init();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    dbHelper = DatabaseHelper();
  }
//auth&reg
  Future<void> saveAuth(String login, String password) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    _prefs!.setString("login", login);
    _prefs!.setString("password", password);
  }

  Future<AuthData?> getAuth() async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    String? login = _prefs!.getString("login");
    String? password = _prefs!.getString("password");
    return (login!=null&&password!=null)?AuthData(login: login, password: password):null;
  }
  //actualizing
  Future<void> saveActSetting(ActualizingSettingData settings) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    _prefs!.setBool("fastActMainSphere", settings.fastActMainSphere);
    _prefs!.setInt("taskActualizingMode", settings.taskActualizingMode);
    _prefs!.setInt("wishActualizingMode", settings.wishActualizingMode);
    _prefs!.setBool("fastActualizingWish", settings.fastActWish);
    _prefs!.setInt("sphereActualizingMode", settings.sphereActualizingMode);
    _prefs!.setBool("fastActualizingSphere", settings.fastActSphere);
    _prefs!.setInt("quoteUpdateFreq", settings.quoteupdateFreq);
  }

  Future<ActualizingSettingData> getActSetting() async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    ActualizingSettingData settings = ActualizingSettingData();
    settings.fastActMainSphere = _prefs!.getBool("fastActMainSphere")??false;
    settings.sphereActualizingMode = _prefs!.getInt("sphereActualizingMode")??0;
    settings.fastActSphere = _prefs!.getBool("fastActualizingSphere")??false;
    settings.wishActualizingMode = _prefs!.getInt("wishActualizingMode")??0;
    settings.fastActWish = _prefs!.getBool("fastActualizingWish")??false;
    settings.taskActualizingMode = _prefs!.getInt("taskActualizingMode")??0;
    settings.quoteupdateFreq = _prefs!.getInt("quoteUpdateFreq")??10;
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
    settings["firstOpenSphere"] = _prefs!.getInt("firstOpenSphere")??0;
    settings["wheelClickNum"] = _prefs!.getInt("wheelClickNum")??0;
    //settings[] = _prefs!.getBool("taskActualizingMode")??false;
    return settings;
  }

  Future<void> saveProfile(ProfileData pd) async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }
    await _prefs!.setString("id", pd.id);
    await _prefs!.setString("name", pd.name);
    await _prefs!.setString("surname", pd.surname);
  }

  Future<ProfileData?> getProfile() async {
    if (_prefs == null) {
      await init(); // Дождитесь завершения инициализации
    }

    String? id = _prefs!.getString("id");
    String? name = _prefs!.getString("name");
    String? surname = _prefs!.getString("surname");
    return (id!=null&&name!=null&&surname!=null)?ProfileData(id: id, name: name, surname: surname):null;
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

  Future updateMoonSync(int moonId, int timestamp) async{
    await dbHelper.updateLastMoonSync(moonId, timestamp);
  }

  Future<int> getImageLastId() async {
    return await dbHelper.getImageLastId();
  }
  Future<Uint8List> getImage(int id) async {
    final result = await dbHelper.getImage(id);
    return base64Decode(result.first['img'].toString());
  }
  Future addImage(int id, Uint8List image) async{
    dbHelper.insertImage(id, base64Encode(image));
  }
  Future addImageStr(int id, String image) async{
    dbHelper.insertImage(id, image);
  }

  Future addMoon(MoonItem mi) async{
    dbHelper.insertMoon(mi);
  }
  Future clearMoons() async{
    dbHelper.clearMoons();
  }
  Future addAllMoons(MoonItem mi, List<CircleData> childCircles) async{
      await dbHelper.insertMoon(mi);
      childCircles.forEach((element) async {
        await dbHelper.insertSphere(WishData(id: element.id, prevId: element.prevId, nextId: element.nextId, parentId: element.parenId, text: element.text, description: element.subText, affirmation: element.affirmation, color: element.color)..isActive=element.isActive..isChecked=element.isChecked..isHidden=element.isHidden, mi.id);
      });
  }
  Future<List<MoonItem>> getMoons() async{
    final moons = (await dbHelper.getAllMoons());
    return moons.map((e) => MoonItem(id: e["id"], filling: e["filling"], text: e["text"], date: e["date"])).toList();
  }
  Future<int> getMoonLastSyncDate(int moonId)async {
    final moon = await dbHelper.getMoon(moonId);
    try{return int.parse(moon.first["lastSyncDate"].toString());}
    catch(ex){
      return -1;
    }
  }

  Future<WishData?> getSphere(int id, int moonId) async {
    final result = await dbHelper.getSphere(id, moonId);
    Map<String, dynamic> tmp = jsonDecode(result['childAims']);
    Map<String, int> chAims = tmp.map((key, value) => MapEntry(key, int.parse(value.toString())));
    return (result.isNotEmpty?(WishData(id: result["id"], prevId: result['prevId'], nextId: result['nextId'], parentId: result["parentId"], text: result["text"], description: result["subtext"], affirmation: result["affirmation"].toString(), color: Color(int.parse(result["color"].toString())))..childAims=chAims..photoIds=result['photosIds']..isChecked=result['isChecked']=="1"?true:false..isActive=result["isActive"]=="1"?true:false..isHidden=result['isHidden']==1?true:false ):null);
  }
  Future<List<WishItem>> getAllSpheres(int moonId) async {
    final result = await dbHelper.getAllSpheres(moonId);
    List<WishItem> list =  result.map((e) => WishItem(id: e['id'], parentId: e['parentId'], text: e['text'], isChecked: e['isChecked']=="1"?true:false, isActive: e['isActive'].toString()=="1"?true:false, isHidden: e['isHidden']==1?true:false)).toList();
    return list.where((element) => element.parentId>1).toList();
  }
  Future<List<CircleData>> getAllMoonSpheres(int moonId) async {
    final result = await dbHelper.getAllMoonSpheres(moonId);
    List<CircleData> list =  result.map((e) => CircleData(id: e['id'], prevId: e['prevId'], nextId: e['nextId'], parenId: e['parentId'], text: e['text'],affirmation: e['affirmation'], color: Color(e['color']), subText: e['subtext'], photosIds: e['photosIds'], isHidden: e['isHidden']==1?true:false, isActive: e['isActive']=="1"?true:false, isChecked: e['isChecked']=="1"?true:false)).toList();
    //filter list for queqe displaying
    return sortList(list);
  }
  Future<List<int>> getSpheresChildAims(int id, int moonId) async {
    final result = await dbHelper.getSphere(id, moonId);
    Map<String, dynamic> tmp = jsonDecode(result['childAims']);
    Map<String, int> chAims = tmp.map((key, value) => MapEntry(key, int.parse(value.toString())));
    return chAims.values.toList();
  }
  Future addSphere(WishData wd, int moonId) async{
    await dbHelper.insertSphere(wd, moonId);
  }
  Future insertORudateSphere(WishData wd, int moonId) async{
    await dbHelper.insertOrUpdateSphere(wd, moonId);
  }
  Future updateSphereNeighbours(int sphereId, bool updateNextId, int newValue, int moonId) async{
    await dbHelper.updateSphereNeighbours(sphereId, updateNextId, newValue, moonId);
  }
  Future deleteSphere(int sphereId, int moonId) async{
    await dbHelper.deleteSphere(sphereId, moonId);
  }
  Future updateSphereStatus(int sphereId, bool status, int moonId) async{
    await dbHelper.updateSphereStatus(sphereId, status, moonId);
  }
  Future activateSphere(int sphereId, bool status, int moonId) async{
    await dbHelper.activateSphere(sphereId, status, moonId);
  }
  Future hideSphere(int sphereId, bool isHide, int moonId) async{
    await dbHelper.hideSphere(sphereId, isHide, moonId);
  }
  Future updateSphereImages(int sphereId, String imageIds, int moonId) async{
    final t = await dbHelper.updateSphereImages(sphereId, imageIds, moonId);
  }
  Future updateSphereShuffle(int sphereId, bool shuffle, String lastShuffle, int moonId) async{
    final t = await dbHelper.updateSphereShuffle(sphereId, shuffle, lastShuffle, moonId);
  }
  Future updateWishChildren(int wishId, int removableId, int moonId) async{
    var chAims = await getSpheresChildAims(wishId, moonId);
    chAims.removeWhere((element) => element==removableId);
    await dbHelper.updateWishChildren(wishId, chAims, moonId);
  }

  Future<AimData> getAim(int id, int moonId) async {
    final result = await dbHelper.getAim(id, moonId);
    return AimData(id: result['id'], parentId: result['parentId'], text: result['text'], description: result['subtext'])..isChecked=result['isChecked']=="1"?true:false..isActive=result["isActive"]=="1"?true:false..childTasks=(result['childTasks']!=null&&result['childTasks'].toString()!="")?result['childTasks'].toString().split("|").map((e) => int.parse(e)).toList():[];
  }
  Future<List<AimItem>> getAllAims(int moonId) async {
    final result = await dbHelper.getAllAims(moonId);
    return result.map((e) => AimItem(id: e['id'], parentId: e['parentId'], text: e['text'], isChecked: e['isChecked']=="1"?true:false, isActive: e['isActive']=='1'?true:false)).toList();
  }
  Future<List<AimData>> getAllAimsData(int moonId) async {
    final result = await dbHelper.getAllAims(moonId);
    return result.map((e) => AimData(id: e['id'], parentId: e['parentId'], text: e['text'], isChecked: e['isChecked']=="1"?true:false, isActive: e["isActive"]=="1"?true:false, description: e['subtext'])..childTasks=(e['childTasks']!=null&&e['childTasks'].toString()!="")?e['childTasks'].toString().split("|").map((e) => int.parse(e)).toList():[]).toList();
  }
  Future<List<int>> getAimsChildTasks(int id, int moonId) async {
    final result = await dbHelper.getAim(id, moonId);
    print("result aim - ${result['childTasks']}");
    return (result['childTasks']!=null&&result["childTasks"].toString()!="")?result['childTasks'].toString().split("|").map((e) => int.parse(e)).toList():[];
  }
  Future<int> addAim(AimData ad, int moonId) async{
    final aims = await getAllAims(moonId);
    await dbHelper.insertAim(AimData(id: ad.id==-1?(aims.length>0?aims[aims.length-1].id:-1)+1:ad.id, parentId: ad.parentId, text: ad.text, description: ad.description, isChecked: ad.isChecked, isActive: ad.isActive)..childTasks = ad.childTasks, moonId);
    int retId = ad.id==-1?(aims.length>0?aims[aims.length-1].id:-1)+1:ad.id;
    return retId;
  }
  Future deleteAim(int aimId, int moonId) async{
    await dbHelper.deleteAim(aimId, moonId);
  }
  Future updateAim(AimData ad, int moonId) async{
    await dbHelper.updateAim(ad, moonId);
  }
  Future updateAimStatus(int aimId, bool status, int moonId) async{
    await dbHelper.updateAimStatus(aimId, status, moonId);
  }
  Future updateAimChildren(int aimId, int removableId, int moonId) async{
    var chTasks = await getAimsChildTasks(aimId, moonId);
    chTasks.removeWhere((element) => element==removableId);
    await dbHelper.updateAimChildren(aimId, chTasks, moonId);
  }
  Future activateAim(int aimId, bool status, int moonId) async{
    await dbHelper.activateAim(aimId, moonId);
  }

  Future<TaskData> getTask(int id, int moonId) async {
    final result = await dbHelper.getTask(id, moonId);
    return TaskData(id: result['id'], parentId: result['parentId'], text: result['text'], description: result['subtext'], isActive: result["isActive"]=="1"?true:false)..isChecked=result['isChecked']=="1"?true:false;
  }
  Future<List<TaskItem>> getAllTasks(int moonId) async {
    final result = await dbHelper.getAllTasks(moonId);
    return result.map((e) => TaskItem(id: e['id'], parentId: e['parentId'], text: e['text'], isChecked: e['isChecked']=='1'?true:false, isActive: e['isActive']=='1'?true:false)).toList();
  }
  Future<List<TaskData>> getAllTasksData(int moonId) async {
    final result = await dbHelper.getAllTasks(moonId);
    return result.map((e) => TaskData(id: e['id'], parentId: e['parentId'], text: e['text'], isChecked: e['isChecked']=='1'?true:false, isActive: e["isActive"]=="1"?true:false, description: e['subtext'])).toList();
  }
  Future addTask(TaskData td, int moonId) async{
    final tasks = await getAllTasks(moonId);
    await dbHelper.insertTask(TaskData(id: td.id==-1?(tasks.lastOrNull?.id??-1)+1:td.id, parentId: td.parentId, text: td.text, description: td.description, isChecked: td.isChecked, isActive: td.isActive), moonId);
    return td.id==-1?tasks.lastOrNull?.id??0:td.id;
  }
  Future deleteTask(int taskId, int moonId) async{
    await dbHelper.deleteTask(taskId, moonId);
  }
  Future updateTask(TaskData td, int moonId) async{
    await dbHelper.updateTask(td, moonId);
  }
  Future updateTaskStatus(int taskId, bool status, int moonId) async{
    await dbHelper.updateTaskStatus(taskId, status, moonId);
  }
  Future activateTask(int taskId, bool status, int moonId) async{
    await dbHelper.activateTask(taskId, moonId);
  }

  Future<List<CardData>> getAllDiary(int moonId) async {
    final result = await dbHelper.getAllDiary(moonId);
    return result.map((e) => CardData(id: e['id'], emoji: e['emoji'], title: e['title'], description: e['description'], text: e['text'], color: Color(int.parse(e["color"].toString())))).toList();
  }
  Future addDiary(CardData cd, int moonId) async{
    dbHelper.insertDiary(cd, moonId);
  }
  Future addAllDiary(List<CardData> cd, int moonId) async{
    for (var element in cd) {
      await dbHelper.insertDiary(element, moonId);
    }
  }
  Future updateDiary(CardData cd, int moonId) async{
    await dbHelper.updateDiary(cd, moonId);
  }
}
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

  Future clearDatabase() async {
    await dbHelper.clearDatabase();
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

  Future<WishData?> getSphere(int id) async {
    final result = await dbHelper.getSphere(id);
    Map<String, dynamic> tmp = jsonDecode(result['childAims']);
    Map<String, int> chAims = tmp.map((key, value) => MapEntry(key, int.parse(value.toString())));
    return (result.isNotEmpty?(WishData(id: result["id"], parentId: result["parentId"], text: result["text"], description: result["subtext"], affirmation: result["affirmation"], color: Color(int.parse(result["color"].toString())))..childAims=chAims..photoIds=result['photosIds']..isChecked=result['isChecked']=="1"?true:false):null);
  }
  Future<List<WishItem>> getAllSpheres() async {
    final result = await dbHelper.getAllSpheres();
    List<WishItem> list =  result.map((e) => WishItem(id: e['id'], parentId: e['parentId'], text: e['text'], isChecked: e['isChecked']=="1"?true:false)).toList();
    return list.where((element) => element.parentId>1).toList();
  }
  Future<List<int>> getSpheresChildAims(int id) async {
    final result = await dbHelper.getSphere(id);
    Map<String, dynamic> tmp = jsonDecode(result['childAims']);
    Map<String, int> chAims = tmp.map((key, value) => MapEntry(key, int.parse(value.toString())));
    return chAims.values.toList();
  }
  Future addSphere(WishData wd) async{
    await dbHelper.insertSphere(wd);
  }
  Future insertORudateSphere(WishData wd) async{
    await dbHelper.insertOrUpdateSphere(wd);
  }
  Future deleteSphere(int sphereId) async{
    await dbHelper.deleteSphere(sphereId);
  }
  Future updateSphereStatus(int sphereId, bool status) async{
    await dbHelper.updateSphereStatus(sphereId, status);
  }
  Future updateSphereImages(int sphereId, String imageIds) async{
    await dbHelper.updateSphereImages(sphereId, imageIds);
  }

  Future<AimData> getAim(int id) async {
    final result = await dbHelper.getAim(id);
    return AimData(id: result['id'], parentId: result['parentId'], text: result['text'], description: result['subtext'])..isChecked=result['isChecked']=="1"?true:false..childTasks=result['childTasks'].toString().split("|").map((e) => int.parse(e)).toList();
  }
  Future<List<AimItem>> getAllAims() async {
    final result = await dbHelper.getAllAims();
    return result.map((e) => AimItem(id: e['id'], parentId: e['parentId'], text: e['text'], isChecked: e['isChecked']=="1"?true:false)).toList();
  }
  Future<List<int>> getAimsChildTasks(int id) async {
    final result = await dbHelper.getAim(id);
    return result['childTasks'].toString().split("|").map((e) => int.parse(e)).toList();
  }
  Future addAim(AimData ad) async{
    await dbHelper.insertAim(ad);
  }
  Future deleteAim(int aimId) async{
    await dbHelper.deleteAim(aimId);
  }
  Future updateAim(AimData ad) async{
    await dbHelper.updateAim(ad);
  }
  Future updateAimStatus(int aimId, bool status) async{
    await dbHelper.updateAimStatus(aimId, status);
  }

  Future<TaskData> getTask(int id) async {
    final result = await dbHelper.getTask(id);
    return TaskData(id: result['id'], parentId: result['parentId'], text: result['text'], description: result['subtext'])..isChecked=result['isChecked']=="1"?true:false;
  }
  Future<List<TaskItem>> getAllTasks() async {
    final result = await dbHelper.getAllTasks();
    return result.map((e) => TaskItem(id: e['id'], parentId: e['parentId'], text: e['text'], isChecked: e['isChecked']=='1'?true:false)).toList();
  }
  Future addTask(TaskData td) async{
    await dbHelper.insertTask(td);
  }
  Future deleteTask(int taskId) async{
    await dbHelper.deleteTask(taskId);
  }
  Future updateTask(TaskData td) async{
    await dbHelper.updateTask(td);
  }
  Future updateTaskStatus(int taskId, bool status) async{
    await dbHelper.updateTaskStatus(taskId, status);
  }

  Future<List<CardData>> getAllDiary() async {
    final result = await dbHelper.getAllDiary();
    return result.map((e) => CardData(id: e['id'], emoji: e['emoji'], title: e['title'], description: e['description'], text: e['text'], color: Color(int.parse(e["color"].toString())))).toList();
  }
  Future addDiary(CardData cd) async{
    dbHelper.insertDiary(cd);
  }
  Future addAllDiary(List<CardData> cd) async{
    for (var element in cd) {
      await dbHelper.insertDiary(element);
    }
  }
  Future updateDiary(CardData cd) async{
    await dbHelper.updateDiary(cd);
  }
}
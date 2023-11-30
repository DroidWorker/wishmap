import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
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

  Future<Uint8List> getImage(int id) async {
    final result = await dbHelper.getImage(id);
    return base64Decode(result.first['img'].toString());
  }
  Future addImage(int id, Uint8List image) async{
    dbHelper.insertImage(id, base64Encode(image));
  }
}
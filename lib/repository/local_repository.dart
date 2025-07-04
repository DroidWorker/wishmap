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
  saveCalculationString(String steps) async {
    if (_prefs == null) {
      await init();
    }
    _prefs!.setString("CircularDiagramCalculation",
        steps);
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

  Future setOnboardingShownCount(int value) async{
    if (_prefs == null) {
      await init();
    }
    _prefs!.setInt("OnboardingShownCount",value);
  }

  Future<int> getOnboardingShownCount() async{
    return _prefs!.getInt("OnboardingShownCount")??0;
  }

  Future setAnswers(String key, String answers) async{
    if (_prefs == null) {
      await init();
    }
    _prefs!.setString(key,answers);
  }

  Future<String> getAnswers(String key) async{
    return _prefs!.getString(key)??"";
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
}

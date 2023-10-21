import 'package:flutter/cupertino.dart';
import 'package:wishmap/repository/Repository.dart';
import 'package:wishmap/repository/local_repository.dart';
import 'package:dart_suncalc/suncalc.dart';

import 'data/models.dart';

class AppViewModel with ChangeNotifier {
  LocalRepository localRep = LocalRepository();
  Repository repository = Repository();

  MessageError messageError = MessageError();

  //auth/regScreen
  AuthData? authData;
  ProfileData? profileData;
  //moonListScreen
  List<MoonItem> moonItems = [];
  //mainScreen
  MainScreenState? mainScreenState;
  //MyTasksScreen
  List<TaskItem> taskItems = [];
  //MyAimsScreen
  List<AimItem> aimItems = [];
  //MyWishesScreen
  List<WishItem> wishItems = [];

  AppViewModel(){
    _init();
  }

  Future<void> _init() async {
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
        _init();
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
        _init();
      }
    }catch(ex){
      addError(ex.toString());
      throw Exception("no access #vm003");
    }
  }

  Future<void> getMoons() async{
    try {
      DateTime now = DateTime.now();
      final moonIllumination = SunCalc.getMoonIllumination(now);
      moonItems = (await repository.getMoonList())??[];
      moonItems.add(MoonItem(id: moonItems.last.id+1, filling: moonIllumination.phase, text: "Я", date: "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}"));
      repository.addMoon(moonItems.last);
    }catch(ex){
      addError(ex.toString());
    }
  }

  Future<void> startMainScreen(MoonItem mi) async{
    mainScreenState = MainScreenState(moon: mi, musicId: 0);
    try {
      mainScreenState!.allCircles = (await repository.getSpheres(mi.id)) ?? [];
    }catch(ex){
      addError(ex.toString());
    }
  }

  Future<void> startMyTasksScreen(MoonItem mi) async{
    try {
      taskItems = (await repository.getMyTasks(mi.id)) ?? [];
    }catch(ex){
      addError(ex.toString());
    }
  }
  Future<void> startMyAimsScreen(MoonItem mi) async{
    try {
      aimItems = (await repository.getMyAims(mi.id)) ?? [];
    }catch(ex){
      addError(ex.toString());
    }
  }Future<void> startMyWishesScreen(MoonItem mi) async{
    try {
      wishItems = (await repository.getMyWishs(mi.id)) ?? [];
    }catch(ex){
      addError(ex.toString());
    }
  }

  Future<void> createNewSphereWish(WishData wd) async{
    try {
      await repository.createSphereWish(wd);
    }catch(ex){
      addError(ex.toString());
    }
  }

  Future<void> createAim(AimData ad, int parentCircleId) async{
    try {
      await repository.createAim(ad, parentCircleId);
    }catch(ex){
      addError(ex.toString());
    }
  }

  Future<void> createTask(TaskData ad, int parentAimId) async{
    try {
      await repository.createTask(ad, parentAimId);
    }catch(ex){
      addError(ex.toString());
    }
  }

}
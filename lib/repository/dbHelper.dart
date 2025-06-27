import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:wishmap/data/models.dart';

class DatabaseHelper {

  Future<void> clearDatabase(int moonId) async {

  }
  Future<void> clearDatabaseFolMoons(String ids) async {
    
  }
  Future dropDatabase() async{
    
  }
  Future clearMoons()async{
    
  }

  Future<int> insertMoon(MoonItem mi) async {
    return -1;
  }
  Future updateLastMoonSync(int moonId, int timestamp) async{
    
  }

  Future<List<Map<String, dynamic>>> getMoon(int id) async {
    return List.empty();
  }

  Future deleteMoons(String ids) async {
    
  }

  Future<List<Map<String, dynamic>>> getAllMoons() async {
    return List.empty();
  }

  Future<int> insertImage(int id, String image) async {
    return -1;
  }

  Future<List<Map<String, dynamic>>> getImage(int id) async {
    return List.empty();
  }

  Future<int> getImageLastId() async {
    return 0;
  }

  Future duplicateArticles(int oldMooon, int newMoon) async {
  }

  Future<int> insertDiary(CardData cd) async {
    return 0;
  }

  Future<int> insertDiaryArticle(Article article) async {
    return -1;
  }

  Future<int> updateDiary(CardData cd) async {
    return 0;
  }

  Future updateArticle(String text, List<String> attachmentsList, int articleId) async {
    }

  Future deleteDiary(int diaryId) async{
    }

  deleteArticle(int articleId) async{
    }

  Future<List<Map<String, dynamic>>> getAllDiary() async {
    return List.empty();
  }

  Future<List<Map<String, dynamic>>> getDiaryArticles(int diaryId) async {
    return List.empty();
  }

  Future<int> insertTask(TaskData td, int moonid) async {
    return 0;
  }

  Future<int> addAllTasks(List<TaskData> tds, int moonid) async {
    return 0;
  }

  Future<int> updateTask(TaskData td, int moonid) async {
    return 0;
  }

  Future activateTask(List<int> aimIds, int moonid) async {
  }

  Future<int> updateTaskStatus(int aimId, bool status, int moonid) async {
    return 0;
  }

  Future<int> deleteTask(int id, int moonid) async {
    return 0;
  }

  Future<Map<String, dynamic>> getTask(int id, int moonid) async {
    return Map.fromIterable(List.empty());
  }

  Future<List<Map<String, dynamic>>> getAllTasks(int moonid) async {
    return List.empty();
  }

  Future<int> insertAim(AimData ad, int moonid) async {
    return 0;
  }
  Future<int> addAllAims(List<AimData> tds, int moonid) async {
    return 1;
  }

  Future<int> updateAim(AimData ad, int moonid) async {
    return 0;
  }

  Future activateAim(List<int> aimIds, int moonid) async {
      }

  Future<int> updateAimStatus(int aimId, bool status, int moonid) async {
    return 0;
  }
  Future<int> updateAimChildren(int aimId, List<int> childTasks, int moonid) async {
    return 0;
  }

  Future<int> deleteAim(int id, int moonid) async {
    return 0;
  }

  Future<Map<String, dynamic>> getAim(int id, int moonid) async {
    return Map.fromIterable(List.empty());
  }

  Future<List<Map<String, dynamic>>> getAllAims(int moonid) async {
    return List.empty();
  }

  Future insertSphere(List<WishData> wd, int moonId) async {
  }
  Future<int> insertOrUpdateSphere(WishData wd, int moonId) async {
    return 0;
  }

  Future activateSpheres(List<int> sphereIds, bool status, int moonid) async {
    
  }
  Future<int>hideSphere(int sphereId, bool isHide, int moonid) async {
    return 0;
  }
  Future<int> updateSphereStatus(int sphereId, bool status, int moonid) async {
    return 1;
  }
  Future<int> updateSphereNeighbours(int sphereId, bool isNextId, int newValue, int moonid) async {
return 0;
  }
  Future<int> updateSphereImages(int sphereId, String imageIds, int moonid) async {
    return 0;
  }
  Future<int> updateSphereShuffle(int sphereId, bool shuffle, String lastShuffle, int moonid) async {
    return 0;
  }
  Future<int> updateWishChildren(int wishId, List<int> childAims, int moonid) async {
    return 0;
  }
  Future<int> deleteSphere(int id, int moonid) async {
    return 0;
  }

  Future<Map<String, dynamic>> getSphere(int id, int moonId) async {
    return Map.fromIterable(List.empty());
  }

  Future<List<Map<String, dynamic>>> getAllSpheres(int moonId) async {
    return List.empty();
  }
  Future<List<Map<String, dynamic>>> getAllMoonSpheres(int moonId) async {
    return List.empty();
  }

  insertReminder(Reminder reminder) async {
  }

  updateReminder(Reminder reminder) async {
  }

  deleteReminder(int id) async {
  }

  Future<List<Reminder>> getReminders() async {
   
    return List.empty();
  }

  Future<List<Reminder>> getRemindersForTask(int taskId) async {
    return List.empty();
  }

  insertAlarm(Alarm alarm, String userId) async {
  }

  updateAlarm(Alarm alarm) async {
  }

  deleteAlarm(int id) async {
  }

  Future<List<Alarm>> selectAlarms(String userId) async {
    return List.empty();
  }
  Future<Alarm?> selectAlarm(int id, String userId) async {
    return null;
  }

  Future<int> addAllQuestions(Map<String,String> qs) async {
    return 0;
  }

  Future<Map<String, String>> getQuestions() async {
    return Map.fromIterable(List.empty());
  }

  Future<int> addAllStatic(Map<String,String> qs) async {
    return 0;
  }

  Future<Map<String, String>> getStatic() async {
    return Map.fromIterable(List.empty());
  }

  Future<void> addPromocode(Promocode promocode, String userId) async {
    }

  Future<Map<String, String>> getPromocodes(String userId, String? pType) async {
    return Map.fromIterable(List.empty());
  }
}
import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wishmap/data/models.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Путь к базе данных
    String path = join(await getDatabasesPath(), 'your_database.db');

    // Открытие базы данных
    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Создание таблицы, если ее нет
    await db.execute('''
      CREATE TABLE moons(
        id INTEGER PRIMARY KEY,
        lastSyncDate INTEGER,
        text TEXT,
        filling FLOAT,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE images(
        id INTEGER PRIMARY KEY,
        img TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE spheres(
        rowId INTEGER PRIMARY KEY AUTOINCREMENT,
        id INTEGER,
        prevId INTEGER,
        nextId INTEGER,
        moonId INTEGER,
        text TEXT,
        subtext TEXT,
        affirmation TEXT,
        isActive TEXT,
        isChecked Text,
        isHidden INTEGER,
        parentId INTEGER,
        photosIds TEXT,
        color INTEGER,
        childAims TEXT,
        lastShuffle TEXT,
        shuffle INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE aims(
        rowId INTEGER  PRIMARY KEY AUTOINCREMENT,
         id INTEGER,
         moonId INTEGER,
        text TEXT,
        subtext TEXT,
        parentId INTEGER,
        childTasks TEXT,
        isChecked TEXT,
        isActive TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        rowId INTEGER  PRIMARY KEY AUTOINCREMENT,
        id INTEGER,
        moonId INTEGER,
        text TEXT,
        subtext TEXT,
        parentId INTEGER,
        isChecked TEXT,
        isActive TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE diary(
        rowId INTEGER  PRIMARY KEY AUTOINCREMENT,
        id INTEGER,
        moonId INTEGER,
        title TEXT,
        description TEXT,
        text TEXT,
        emoji TEXT,
        color INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE articles(
        rowId INTEGER  PRIMARY KEY AUTOINCREMENT,
        moonId INTEGER,
        text TEXT,
        parentDiaryId INTEGER,
        date TEXT,
        time TEXT,
        attacments TEXT
      )
    ''');

    await db.execute('''
    CREATE TABLE reminders(
        id INTEGER  PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER,
        dateTime INTEGER,
        remindDays TEXT,
        music TEXT,
        remindEnabled INTEGER,
        vibration INTEGER
      )
    ''');

    await db.execute('''
    CREATE TABLE alarms(
        id INTEGER  PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER,
        userId TEXT,
        dateTime INTEGER,
        remindDays TEXT,
        music TEXT,
        remindEnabled INTEGER,
        vibration INTEGER,
        text TEXT,
        notifications TEXT,
        offMods TEXT,
        offModsParams TEXT,
        snooze TEXT
      )
    ''');

    await db.execute('''
    CREATE TABLE questions(
        q TEXT PRIMARY KEY,
        answ TEXT
      )
    ''');
  }

  Future<void> clearDatabase(int moonId) async {
    Database db = await database;

    // Удаление всех данных из таблицы spheres
    await db.delete('spheres', where: "moonId = ?", whereArgs: [moonId]);

    // Удаление всех данных из таблицы aims
    await db.delete('aims', where: "moonId = ?", whereArgs: [moonId]);

    // Удаление всех данных из таблицы tasks
    await db.delete('tasks', where: "moonId = ?", whereArgs: [moonId]);

    // Удаление всех данных из таблицы diary
    await db.delete('diary', where: "moonId = ?", whereArgs: [moonId]);
  }
  Future dropDatabase() async{
    Database db = await database;
    await db.delete("spheres");
    await db.delete("aims");
    await db.delete("tasks");
    await db.delete("diary");
    await db.delete("moons");
  }
  Future clearMoons()async{
    Database db = await database;
    await db.delete('moons');
  }

  Future<int> insertMoon(MoonItem mi) async {
    Database db = await database;
    return await db.insert('moons', {'id': mi.id, 'lastSyncDate': -1, 'text': mi.text, 'filling': mi.filling, 'date': mi.date});
  }
  Future updateLastMoonSync(int moonId, int timestamp) async{
    Database db = await database;
    await db.update("moons", {'lastSyncDate': timestamp}, where: 'id = ?', whereArgs: [moonId]);
  }

  Future<List<Map<String, dynamic>>> getMoon(int id) async {
    Database db = await database;
    return await db.query('moons', where: "id = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllMoons() async {
    Database db = await database;
    return await db.query('moons');
  }

  Future<int> insertImage(int id, String image) async {
    Database db = await database;
    return await db.insert('images', {'id': id, 'img': image});
  }

  Future<List<Map<String, dynamic>>> getImage(int id) async {
    Database db = await database;
    return await db.query('images', where: "id = ?", whereArgs: [id]);
  }

  Future<int> getImageLastId() async {
    Database db = await database;

    List<Map<String, dynamic>> result = await db.query(
      'images',
      orderBy: 'id DESC',
      limit: 1,
    );

    // Check if there is any result
    if (result.isNotEmpty) {
      // Extract the 'id' value from the result
      int lastId = result.first['id'];
      return lastId;
    } else {
      // Return a default value (you can choose your own default value)
      return -1;
    }
  }

  Future<int> insertDiary(CardData cd, int moonid) async {
    Database db = await database;
    return await db.insert('diary', {'id': cd.id, 'moonId':moonid,  'title': cd.title, 'description': cd.description, 'text': cd.text, 'emoji': cd.emoji, 'color': cd.color.value});
  }

  Future<int> insertDiaryArticle(Article article, int moonId) async {
    Database db = await database;
    await db.insert('articles', {'moonId':moonId,  'text': article.text, 'parentDiaryId': article.parentId, 'date': article.date, 'time': article.time, 'attacments': article.attachments.join("|")});
    return (await db.query('articles', where: "time = ?", whereArgs: [article.time])).firstOrNull?['rowId'] as int;
  }

  Future<int> updateDiary(CardData cd, int moonId) async {
    Database db = await database;
    return await db.update("diary", {'title': cd.title, 'description': cd.description, 'text': cd.text, 'emoji': cd.emoji, 'color': cd.color.value}, where: "id = ? AND moonId = ?", whereArgs: [cd.id, moonId]);
  }

  Future updateArticle(String text, List<String> attachmentsList, int articleId, int moonId) async {
    Database db = await database;
    await db.update("articles", {'text': text, 'attacments': attachmentsList.join('|')}, where: "moonId == ? AND rowId == ?", whereArgs: [moonId, articleId]);
  }

  Future deleteDiary(int diaryId, int moonId) async{
    Database db = await database;
    await db.delete("diary", where: "id = ? AND moonId = ?", whereArgs: [diaryId,moonId]);
  }

  deleteArticle(int articleId, int moonId) async{
    Database db = await database;
    await db.delete("articles", where: "rowId = ? AND moonId = ?", whereArgs: [articleId,moonId]);
  }

  Future<List<Map<String, dynamic>>> getAllDiary(int moonid) async {
    Database db = await database;
    return await db.query('diary', where: "moonId = ?", whereArgs: [moonid]);
  }

  Future<List<Map<String, dynamic>>> getDiaryArticles(int diaryId, int moonId) async {
    Database db = await database;
    return await db.query('articles', where: "moonId = ? AND parentDiaryId = ?", whereArgs: [moonId, diaryId]);
  }

  Future<int> insertTask(TaskData td, int moonid) async {
    Database db = await database;
    final parentAim = await getAim(td.parentId, moonid);
    String childTasks = parentAim["childTasks"]!=null?parentAim["childTasks"].toString():"";
    childTasks==""?childTasks=td.id.toString():childTasks+="|${td.id}";
    await db.update("aims", {"childTasks": childTasks}, where: "id = ? AND moonId = ?", whereArgs: [td.parentId, moonid]);
    return await db.insert('tasks', {'id': td.id, 'moonId':moonid, 'text': td.text, 'subtext': td.description, 'parentId': td.parentId, 'isChecked': td.isChecked?1:0, 'isActive': td.isActive?1:0});
  }

  Future<int> addAllTasks(List<TaskData> tds, int moonid) async {
    Database db = await database;
    var batch = db.batch();
    tds.forEach((td) {
      batch.insert('tasks', {'id': td.id, 'moonId':moonid, 'text': td.text, 'subtext': td.description, 'parentId': td.parentId, 'isChecked': td.isChecked?1:0, 'isActive': td.isActive?1:0});
    });
    await batch.commit();
    return 1;
  }

  Future<int> updateTask(TaskData td, int moonid) async {
    Database db = await database;
    return await db.update("tasks", {'id': td.id, 'text': td.text, 'subtext': td.description, 'parentId': td.parentId, 'isChecked': td.isChecked?1:0}, where: "id = ? AND moonId = ?", whereArgs: [td.id, moonid]);
  }

  Future activateTask(List<int> aimIds, int moonid) async {
    Database db = await database;
    var batch = db.batch();
    aimIds.forEach((aimId) {
      batch.update("tasks", {'isActive': 1}, where: "id = ? AND moonId = ?", whereArgs: [aimId, moonid]);
    });
    await batch.commit();
  }

  Future<int> updateTaskStatus(int aimId, bool status, int moonid) async {
    Database db = await database;
    return await db.update("tasks", {'isChecked': status?1:0, 'isActive': 1}, where: "id = ? AND moonId = ?", whereArgs: [aimId, moonid]);
  }

  Future<int> deleteTask(int id, int moonid) async {
    Database db = await database;
    return await db.delete("tasks", where: "id = ? AND moonId = ?", whereArgs: [id, moonid]);
  }

  Future<Map<String, dynamic>> getTask(int id, int moonid) async {
    Database db = await database;
    return (await db.query('tasks', where: "id = ? AND moonId = ?", whereArgs: [id, moonid])).firstOrNull??{};
  }

  Future<List<Map<String, dynamic>>> getAllTasks(int moonid) async {
    Database db = await database;
    return await db.query('tasks', where: "moonId = ?", whereArgs: [moonid]);
  }

  Future<int> insertAim(AimData ad, int moonid) async {
    Database db = await database;
    print("chitasks   ${ad.childTasks}");
    String chTasks = "";//ad.childTasks.join("|");
    print("-> chtasks  ${chTasks}");
    final sphere = await getSphere(ad.parentId, moonid);
    Map<String, int> chAims = {};
    if(sphere['childAims']!=null) {
      Map<String, dynamic> tmp = jsonDecode(sphere['childAims']);
      chAims = tmp.map((key, value) =>
          MapEntry(key, int.parse(value.toString())));
      chAims["${ad.id}nvjvdjh"] = ad.id;
    }
    if(chAims.isNotEmpty)await db.update("spheres", {"childAims": jsonEncode(chAims)}, where: "id = ? AND moonId = ?", whereArgs: [ad.parentId, moonid]);
    return await db.insert("aims", {'id': ad.id, 'moonId':moonid, 'text': ad.text, 'subtext': ad.description, 'parentId': ad.parentId, 'childTasks':chTasks, 'isChecked': ad.isChecked?1:0,  'isActive': ad.isActive?1:0});
  }
  Future<int> addAllAims(List<AimData> tds, int moonid) async {
    Database db = await database;
    var batch = db.batch();
    tds.forEach((ad) {
      String chTasks = ad.childTasks.join("|");
      batch.insert("aims", {'id': ad.id, 'moonId':moonid, 'text': ad.text, 'subtext': ad.description, 'parentId': ad.parentId, 'childTasks':chTasks, 'isChecked': ad.isChecked?1:0,  'isActive': ad.isActive?1:0});
    });
    await batch.commit();
    return 1;
  }

  Future<int> updateAim(AimData ad, int moonid) async {
    Database db = await database;
    String chTasks = ad.childTasks.join("|");
    return await db.update("aims", {'text': ad.text, 'subtext': ad.description, 'parentId': ad.parentId, 'childTasks':chTasks, 'isChecked': ad.isChecked?1:0}, where: "id = ? AND moonId = ?", whereArgs: [ad.id, moonid]);
  }

  Future activateAim(List<int> aimIds, int moonid) async {
    Database db = await database;
    var batch = db.batch();
    aimIds.forEach((aimId) {
      batch.update("aims", {'isActive': 1,}, where: "id = ? AND moonId = ?", whereArgs: [aimId, moonid]);
    });
    await batch.commit();
  }

  Future<int> updateAimStatus(int aimId, bool status, int moonid) async {
    Database db = await database;
    return await db.update("aims", {'isChecked': status?1:0, 'isActive': 1}, where: "id = ? AND moonId = ?", whereArgs: [aimId, moonid]);
  }
  Future<int> updateAimChildren(int aimId, List<int> childTasks, int moonid) async {
    Database db = await database;
    return await db.update("aims", {'childTasks': childTasks.join("|"),}, where: "id = ? AND moonId = ?", whereArgs: [aimId, moonid]);
  }

  Future<int> deleteAim(int id, int moonid) async {
    Database db = await database;
    return await db.delete("aims", where: "id = ? AND moonId = ?", whereArgs: [id, moonid]);
  }

  Future<Map<String, dynamic>> getAim(int id, int moonid) async {
    Database db = await database;
    return (await db.query('aims', where: "id = ? AND moonId = ?", whereArgs: [id, moonid])).firstOrNull??{};
  }

  Future<List<Map<String, dynamic>>> getAllAims(int moonid) async {
    Database db = await database;
    return await db.query('aims', where: "moonId = ?", whereArgs: [moonid]);
  }

  Future insertSphere(List<WishData> wd, int moonId) async {
    Database db = await database;
    var batch = db.batch();
    wd.forEach((wdItem) {
      String chAims = jsonEncode(wdItem.childAims);
      batch.insert("spheres", {'id': wdItem.id, 'prevId': wdItem.prevId, 'nextId': wdItem.nextId, 'moonId':moonId, 'text': wdItem.text, 'subtext': wdItem.description, 'affirmation': wdItem.affirmation, 'isActive':wdItem.isActive?1:0, 'isChecked': wdItem.isChecked?1:0, 'isHidden': wdItem.isHidden?1:0, 'parentId': wdItem.parentId, 'photosIds': wdItem.photoIds, 'color': wdItem.color.value, 'childAims': chAims, 'shuffle': 1, 'lastShuffle': wdItem.lastShuffle});
    });
    await batch.commit();
  }
  Future<int> insertOrUpdateSphere(WishData wd, int moonId) async {
    Database db = await database;
    String chAims = jsonEncode(wd.childAims);
    int result = await db.update(
      "spheres",
      {
        'id': wd.id,
        'prevId': wd.prevId,
        'nextId': wd.nextId,
        'moonId': moonId,
        'text': wd.text,
        'subtext': wd.description,
        'affirmation': wd.affirmation,
        'isActive': wd.isActive?1:0,
        'isChecked': wd.isChecked?1:0,
        'isHidden': wd.isHidden?1:0,
        'parentId': wd.parentId,
        'photosIds': wd.photoIds,
        'color': wd.color.value,
        'childAims': chAims,
        'shuffle': wd.shuffle?1:0,
        'lastShuffle': wd.lastShuffle
      },
      where: "id = ? AND moonId = ?",
      whereArgs: [wd.id, moonId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if(result==0){
      result = await db.insert(
        "spheres",
        {
          'id': wd.id,
          'prevId': wd.prevId,
          'nextId': wd.nextId,
          'moonId': moonId,
          'text': wd.text,
          'subtext': wd.description,
          'affirmation': wd.affirmation,
          'isActive': wd.isActive?1:0,
          'isChecked': wd.isChecked?1:0,
          'isHidden': wd.isHidden?1:0,
          'parentId': wd.parentId,
          'photosIds': wd.photoIds,
          'color': wd.color.value,
          'childAims': chAims,
          'shuffle': 1,
          'lastShuffle': ""
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return result;
  }

  /*Future<int> updateSphere(WishData wd, int moonid) async {
    Database db = await database;
    String chAims = wd.childAims.values.join("|");
    return await db.update("spheres", {'text': wd.text, 'prevId': wd.prevId, 'nextId': wd.nextId, 'subtext': wd.description, 'affirmation': wd.affirmation, 'isActive':wd.isActive?1:0, 'isChecked': wd.isChecked?1:0, 'isHidden': wd.isHidden?1:0, 'parentId': wd.parentId, 'photosIds': wd.photoIds, 'color': wd.color.value, 'childAims': chAims}, where: "id = ? AND moonId = ?", whereArgs: [wd.id, moonid]);
  }*/
  Future activateSpheres(List<int> sphereIds, bool status, int moonid) async {
    Database db = await database;
    var batch = db.batch();
    sphereIds.forEach((sphereId) {
      batch.update("spheres", {'isActive': 1,}, where: "id = ? AND moonId = ?", whereArgs: [sphereId, moonid]);
    });
    await batch.commit();
  }
  Future<int>hideSphere(int sphereId, bool isHide, int moonid) async {
    Database db = await database;
    return await db.update("spheres", {'isHidden': isHide?1:0,}, where: "id = ? AND moonId = ?", whereArgs: [sphereId, moonid]);
  }
  Future<int> updateSphereStatus(int sphereId, bool status, int moonid) async {
    Database db = await database;
    return await db.update("spheres", {'isChecked': status?1:0, 'isActive': 1}, where: "id = ? AND moonId = ?", whereArgs: [sphereId, moonid]);
  }
  Future<int> updateSphereNeighbours(int sphereId, bool isNextId, int newValue, int moonid) async {
    Database db = await database;
    return isNextId? await db.update("spheres", {'nextId': newValue,}, where: "id = ? AND moonId = ?", whereArgs: [sphereId, moonid]):
    await db.update("spheres", {'prevId': newValue,}, where: "id = ? AND moonId = ?", whereArgs: [sphereId, moonid]);
  }
  Future<int> updateSphereImages(int sphereId, String imageIds, int moonid) async {
    Database db = await database;
    final res = db.update("spheres", {'photosIds': imageIds,}, where: "id = ? AND moonId = ?", whereArgs: [sphereId, moonid]);
    return res;
  }
  Future<int> updateSphereShuffle(int sphereId, bool shuffle, String lastShuffle, int moonid) async {
    Database db = await database;
    final res = db.update("spheres", {'shuffle': shuffle?"1":"0", 'lastShuffle': lastShuffle}, where: "id = ? AND moonId = ?", whereArgs: [sphereId, moonid]);
    return res;
  }
  Future<int> updateWishChildren(int wishId, List<int> childAims, int moonid) async {
    Database db = await database;
    return await db.update("spheres", {'childAims': jsonEncode(childAims.asMap()),}, where: "id = ? AND moonId = ?", whereArgs: [wishId, moonid]);
  }
  Future<int> deleteSphere(int id, int moonid) async {
    Database db = await database;
    return await db.delete("spheres", where: "id = ? AND moonId = ?", whereArgs: [id, moonid]);
  }

  Future<Map<String, dynamic>> getSphere(int id, int moonId) async {
    Database db = await database;
    return (await db.query('spheres', where: "id = ? AND moonId = ?", whereArgs: [id, moonId])).firstOrNull??{};
  }

  Future<List<Map<String, dynamic>>> getAllSpheres(int moonId) async {
    Database db = await database;
    return await db.query('spheres', where: "moonId = ?", whereArgs: [moonId]);
  }
  Future<List<Map<String, dynamic>>> getAllMoonSpheres(int moonId) async {
    Database db = await database;
    return await db.query('spheres', where: "moonId = ?", whereArgs: [moonId]);
  }

  insertReminder(Reminder reminder) async {
    Database db = await database;
    await db.insert("reminders", {'taskId':reminder.TaskId, 'dateTime': reminder.dateTime.toString(), 'remindDays': reminder.remindDays.join("|"), 'music': reminder.music, 'remindEnabled': reminder.remindEnabled?1:0, 'vibration': reminder.vibration?1:0}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  updateReminder(Reminder reminder) async {
    Database db = await database;
    await db.update("reminders", {'taskId':reminder.TaskId, 'dateTime': reminder.dateTime.toString(), 'remindDays': reminder.remindDays.join("|"), 'music': reminder.music, 'remindEnabled': reminder.remindEnabled?1:0, 'vibration': reminder.vibration?1:0}, where: "id = ?", whereArgs: [reminder.id], conflictAlgorithm: ConflictAlgorithm.replace);
  }

  deleteReminder(int id) async {
    Database db = await database;
    await db.delete("reminders", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Reminder>> getReminders() async {
    Database db = await database;
    List<Map<String, dynamic>> reqResult = await db.query('reminders');

    return reqResult.map((e)=>Reminder(e['id'], e['taskId'],DateTime.parse(e['dateTime']), e['remindDays'].toString().split("|").toList(), e['music'], e['remindEnabled']==1?true:false, vibration: e['vibration']==1?true:false)).toList();
  }

  Future<List<Reminder>> getRemindersForTask(int taskId) async {
    Database db = await database;
    List<Map<String, dynamic>> reqResult = await db.query('reminders', where: "taskId = ?", whereArgs: [taskId]);

    return reqResult.map((e)=>Reminder(e['id'], e['taskId'], DateTime.parse(e['dateTime']), e['remindDays'].toString().split("|").toList(), e['music'], e['remindEnabled']==1?true:false, vibration: e['vibration']==1?true:false)).toList();
  }

  insertAlarm(Alarm alarm, String userId) async {
    Database db = await database;
    await db.insert("alarms", {'taskId': -1, 'userId': userId,'dateTime': alarm.dateTime.toString(), 'remindDays': alarm.remindDays.join("|"), 'music': alarm.music, 'remindEnabled': alarm.remindEnabled?1:0, 'text': alarm.text,'vibration': alarm.vibration?1:0, 'notifications': alarm.notificationIds.join("|"), 'offMods': alarm.offMods.join("|"), 'offModsParams': json.encode(alarm.offModsParams), 'snooze': alarm.snooze}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  updateAlarm(Alarm alarm) async {
    Database db = await database;
    await db.update("alarms", {'dateTime': alarm.dateTime.toString(), 'remindDays': alarm.remindDays.join("|"), 'music': alarm.music, 'remindEnabled': alarm.remindEnabled?1:0, 'text': alarm.text, 'vibration': alarm.vibration?1:0, 'notifications': alarm.notificationIds.join("|"),'offMods': alarm.offMods.join("|"), 'offModsParams': json.encode(alarm.offModsParams), 'snooze': alarm.snooze}, where: "id = ?", whereArgs: [alarm.id], conflictAlgorithm: ConflictAlgorithm.replace);
  }

  deleteAlarm(int id) async {
    Database db = await database;
    await db.delete("alarms", where: "id = ?", whereArgs: [id]);

    int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM alarms')) ?? 0;
    if (count == 0) {
      // Таблица пуста, сбрасываем автоинкремент
      await db.rawQuery('DELETE FROM sqlite_sequence WHERE name = ?', ["alarms"]);
    }
  }

  Future<List<Alarm>> selectAlarms(String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> reqResult = await db.query('alarms', where: "userId = ?", whereArgs: [userId]);

    return reqResult.map((e) {
        Map<String, dynamic> tmp = json.decode(e['offModsParams']);
        Map<String, String> omp = {};
        tmp.keys.toList().forEach((e){
          omp[e] = tmp[e].toString();
        });
        return Alarm(e['id'], e['taskId'],DateTime.parse(e['dateTime']), e['remindDays'].toString().isNotEmpty?e['remindDays'].toString().split("|").toList():[], e['music'], e['remindEnabled']==1?true:false, e['text'], vibration: e['vibration']==1?true:false, notificationIds: e['notifications'].toString().split("|").map((e)=>int.parse(e)).toList(), offMods: e['offMods'].toString().isNotEmpty?e['offMods'].toString().split("|").map((e)=>int.parse(e)).toList():[], offModsParams: omp, snooze: e["snooze"]);
    }).toList();
  }
  Future<Alarm?> selectAlarm(int id, String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> reqResult = await db.query('alarms', where: "id = ? AND userId = ?", whereArgs: [id, userId]);

    return reqResult.map((e) {
      Map<String, dynamic> tmp = json.decode(e['offModsParams']);
      Map<String, String> omp = {};
      tmp.keys.toList().forEach((e){
        omp[e] = tmp[e].toString();
      });
      return Alarm(e['id'], e['taskId'],DateTime.parse(e['dateTime']), e['remindDays'].toString().isNotEmpty?e['remindDays'].toString().split("|").toList():[], e['music'], e['remindEnabled']==1?true:false, e['text'], vibration: e['vibration']==1?true:false, notificationIds: e['notifications'].toString().split("|").map((e)=>int.parse(e)).toList(), offMods: e['offMods'].toString().isNotEmpty?e['offMods'].toString().split("|").map((e)=>int.parse(e)).toList():[], offModsParams: omp, snooze: e['snooze']);
    }).firstOrNull;
  }

  Future<int> addAllQuestions(Map<String,String> qs) async {
    Database db = await database;
    var batch = db.batch();
    for (var q in qs.entries) {
      batch.insert('questions', {'q': q.key, 'answ':q.value});
    }
    await batch.commit();
    return 1;
  }

  Future<Map<String, String>> getQuestions() async {
    try {
      Database db = await database;
      List<Map<String, dynamic>> result = await db.query('questions');
      return Map<String, String>.fromEntries(result.firstOrNull?.entries.map((item)=>MapEntry(item.key, item.value))??[]);
    } on Exception catch (ex) {
      print("error 54267 $ex");
      return {};
    }
  }
}
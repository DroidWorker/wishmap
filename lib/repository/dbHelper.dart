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
        lastShuffle INTEGER
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
        isChecked TEXT
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

  Future<int> updateDiary(CardData cd, int moonId) async {
    Database db = await database;
    return await db.update("diary", {'title': cd.title, 'description': cd.description, 'text': cd.text, 'emoji': cd.emoji, 'color': cd.color.value}, where: "id = ? AND moonId = ?", whereArgs: [cd.id, moonId]);
  }

  Future<List<Map<String, dynamic>>> getAllDiary(int moonid) async {
    Database db = await database;
    return await db.query('diary', where: "moonId = ?", whereArgs: [moonid]);
  }

  Future<int> insertTask(TaskData td, int moonid) async {
    Database db = await database;
    final parentAim = await getAim(td.parentId, moonid);
    String childTasks = parentAim["childTasks"].toString();
    childTasks==""?childTasks=td.id.toString():childTasks+="|${td.id}";
    await db.update("aims", {"childTasks": childTasks}, where: "id = ? AND moonId = ?", whereArgs: [td.parentId, moonid]);
    return await db.insert('tasks', {'id': td.id, 'moonId':moonid, 'text': td.text, 'subtext': td.description, 'parentId': td.parentId, 'isChecked': td.isChecked?1:0, 'isActive': td.isActive});
  }

  Future<int> updateTask(TaskData td, int moonid) async {
    Database db = await database;
    return await db.update("tasks", {'id': td.id, 'text': td.text, 'subtext': td.description, 'parentId': td.parentId, 'isChecked': td.isChecked?1:0}, where: "id = ? AND moonId = ?", whereArgs: [td.id, moonid]);
  }

  Future<int> activateTask(int aimId, int moonid) async {
    Database db = await database;
    return await db.update("tasks", {'isActive': 1,}, where: "id = ? AND moonId = ?", whereArgs: [aimId, moonid]);
  }

  Future<int> updateTaskStatus(int aimId, bool status, int moonid) async {
    Database db = await database;
    return await db.update("tasks", {'isChecked': status,}, where: "id = ? AND moonId = ?", whereArgs: [aimId, moonid]);
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
    String chTasks = ad.childTasks.join("|");
    final sphere = await getSphere(ad.parentId, moonid);
    Map<String, dynamic> tmp = jsonDecode(sphere['childAims']);
    Map<String, int> chAims = tmp.map((key, value) => MapEntry(key, int.parse(value.toString())));
    chAims["${ad.id}nvjvdjh"] = ad.id;
    await db.update("spheres", {"childAims": jsonEncode(chAims)}, where: "id = ? AND moonId = ?", whereArgs: [ad.parentId, moonid]);
    return await db.insert("aims", {'id': ad.id, 'moonId':moonid, 'text': ad.text, 'subtext': ad.description, 'parentId': ad.parentId, 'childTasks':chTasks, 'isChecked': ad.isChecked?1:0,  'isActive': ad.isActive});
  }

  Future<int> updateAim(AimData ad, int moonid) async {
    Database db = await database;
    String chTasks = ad.childTasks.join("|");
    return await db.update("aims", {'text': ad.text, 'subtext': ad.description, 'parentId': ad.parentId, 'childTasks':chTasks, 'isChecked': ad.isChecked?1:0}, where: "id = ? AND moonId = ?", whereArgs: [ad.id, moonid]);
  }

  Future<int> activateAim(int aimId, int moonid) async {
    Database db = await database;
    return await db.update("aims", {'isActive': 1,}, where: "id = ? AND moonId = ?", whereArgs: [aimId, moonid]);
  }

  Future<int> updateAimStatus(int aimId, bool status, int moonid) async {
    Database db = await database;
    return await db.update("aims", {'isChecked': status,}, where: "id = ? AND moonId = ?", whereArgs: [aimId, moonid]);
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

  Future<int> insertSphere(WishData wd, int moonId) async {
    Database db = await database;
    String chAims = jsonEncode(wd.childAims);
    return await db.insert("spheres", {'id': wd.id, 'moonId':moonId, 'text': wd.text, 'subtext': wd.description, 'affirmation': wd.affirmation, 'isActive':wd.isActive?1:0, 'isChecked': wd.isChecked?1:0, 'isHidden': wd.isHidden?1:0, 'parentId': wd.parentId, 'photosIds': wd.photoIds, 'color': wd.color.value, 'childAims': chAims, 'shuffle': 1, 'lastShuffle': ""});
  }
  Future<int> insertOrUpdateSphere(WishData wd, int moonId) async {
    Database db = await database;
    String chAims = jsonEncode(wd.childAims);

    int result = await db.update(
      "spheres",
      {
        'id': wd.id,
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

  Future<int> updateSphere(WishData wd, int moonid) async {
    Database db = await database;
    String chAims = wd.childAims.values.join("|");
    return await db.update("spheres", {'text': wd.text, 'subtext': wd.description, 'affirmation': wd.affirmation, 'isActive':wd.isActive?1:0, 'isChecked': wd.isChecked?1:0, 'isHidden': wd.isHidden?1:0, 'parentId': wd.parentId, 'photosIds': wd.photoIds, 'color': wd.color.value, 'childAims': chAims}, where: "id = ? AND moonId = ?", whereArgs: [wd.id, moonid]);
  }
  Future<int>activateSphere(int sphereId, bool status, int moonid) async {
    Database db = await database;
    return await db.update("spheres", {'isActive': 1,}, where: "id = ? AND moonId = ?", whereArgs: [sphereId, moonid]);
  }
  Future<int>hideSphere(int sphereId, bool isHide, int moonid) async {
    Database db = await database;
    return await db.update("spheres", {'isHidden': isHide?1:0,}, where: "id = ? AND moonId = ?", whereArgs: [sphereId, moonid]);
  }
  Future<int> updateSphereStatus(int sphereId, bool status, int moonid) async {
    Database db = await database;
    return await db.update("spheres", {'isChecked': status,}, where: "id = ? AND moonId = ?", whereArgs: [sphereId, moonid]);
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
}

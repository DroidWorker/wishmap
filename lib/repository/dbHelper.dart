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
      CREATE TABLE images(
        id INTEGER PRIMARY KEY,
        img TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE spheres(
        id INTEGER PRIMARY KEY,
        text TEXT,
        subtext TEXT,
        affirmation TEXT,
        isActive TEXT,
        isChecked Text,
        parentId INTEGER,
        photosIds TEXT,
        color INTEGER,
        childAims TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE aims(
         id INTEGER PRIMARY KEY,
        text TEXT,
        subtext TEXT,
        parentId INTEGER,
        childTasks TEXT,
        isChecked TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY,
        text TEXT,
        subtext TEXT,
        parentId INTEGER,
        isChecked TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE diary(
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT,
        text TEXT,
        emoji TEXT,
        color INTEGER
      )
    ''');
  }

  Future<int> insertImage(int id, String image) async {
    Database db = await database;
    return await db.insert('images', {'id': id, 'img': image});
  }

  Future<List<Map<String, dynamic>>> getImage(int id) async {
    Database db = await database;
    return await db.query('images', where: "id = ?", whereArgs: [id]);
  }

  Future<int> insertDiary(CardData cd) async {
    Database db = await database;
    return await db.insert('diary', {'id': cd.id, 'title': cd.title, 'description': cd.description, 'text': cd.text, 'emoji': cd.emoji, 'color': cd.color});
  }

  Future<int> updateDiary(CardData cd) async {
    Database db = await database;
    return await db.update("diary", {'title': cd.title, 'description': cd.description, 'text': cd.text, 'emoji': cd.emoji, 'color': cd.color}, where: "id = ?", whereArgs: [cd.id]);
  }

  Future<List<Map<String, dynamic>>> getAllDiary() async {
    Database db = await database;
    return await db.query('diary');
  }

  Future<int> insertTask(TaskData td) async {
    Database db = await database;
    return await db.insert('tasks', {'id': td.id, 'text': td.text, 'subtext': td.description, 'parentId': td.parentId, 'isChecked': td.isChecked});
  }

  Future<int> updateTask(TaskData td) async {
    Database db = await database;
    return await db.update("tasks", {'id': td.id, 'text': td.text, 'subtext': td.description, 'parentId': td.parentId, 'isChecked': td.isChecked}, where: "id = ?", whereArgs: [td.id]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete("tasks", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    Database db = await database;
    return await db.query('aims');
  }

  Future<int> insertAim(AimData ad) async {
    Database db = await database;
    String chTasks = ad.childTasks.join("|");
    return await db.update("aims", {'text': ad.text, 'subtext': ad.description, 'parentId': ad.parentId, 'childTasks':chTasks, 'isChecked': ad.isChecked}, where: "id = ?", whereArgs: [ad.id]);
  }

  Future<int> updateAim(AimData ad) async {
    Database db = await database;
    String chTasks = ad.childTasks.join("|");
    return await db.update("aims", {'text': ad.text, 'subtext': ad.description, 'parentId': ad.parentId, 'childTasks':chTasks, 'isChecked': ad.isChecked}, where: "id = ?", whereArgs: [ad.id]);
  }

  Future<int> deleteAim(int id) async {
    Database db = await database;
    return await db.delete("aims", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllAims() async {
    Database db = await database;
    return await db.query('aims');
  }

  Future<int> insertSphere(WishData wd) async {
    Database db = await database;
    String chAims = wd.childAims.values.join("|");
    return await db.update("spheres", {'text': wd.text, 'subtext': wd.description, 'affirmation': wd.affirmation, 'isActive':wd.isActive, 'isChecked': wd.isChecked, 'parentId': wd.parentId, 'photosIds': wd.photoIds, 'color': wd.color, 'childAims': chAims}, where: "id = ?", whereArgs: [wd.id]);
  }

  Future<int> updateSphere(WishData wd) async {
    Database db = await database;
    String chAims = wd.childAims.values.join("|");
    return await db.update("spheres", {'text': wd.text, 'subtext': wd.description, 'affirmation': wd.affirmation, 'isActive':wd.isActive, 'isChecked': wd.isChecked, 'parentId': wd.parentId, 'photosIds': wd.photoIds, 'color': wd.color, 'childAims': chAims}, where: "id = ?", whereArgs: [wd.id]);
  }

  Future<int> deleteSphere(int id) async {
    Database db = await database;
    return await db.delete("spheres", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllSpheres() async {
    Database db = await database;
    return await db.query('spheres');
  }
}

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GroceryModel {
  int? id;
  static final DBhelper instance = DBhelper();
  String? title;

  GroceryModel({this.id, this.title});

  GroceryModel.fromMap(Map<String, dynamic> res)
      : id = res['id'],
        title = res['title'];

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title};
  }

  GroceryModel copyWith({int? id, String? title}) {
    return GroceryModel(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}

class DBhelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'groceries.db');
    var db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
    return db;
  }

  void _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE groceries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
      )
    ''');
  }

  Future<GroceryModel> insert(GroceryModel groceryModel) async {
    var dbClient = await database;
    await dbClient.insert('groceries', groceryModel.toMap());
    return groceryModel;
  }

  Future<List<GroceryModel>> getDataList() async {
    final Database db = await database;
    final List<Map<String, dynamic>> queryResult =
        await db.rawQuery('SELECT * FROM groceries');
    return queryResult.map((e) => GroceryModel.fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    final Database dbClient = await database;
    return await dbClient.delete('groceries', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(GroceryModel groceryModel) async {
    final Database dbClient = await database;
    return await dbClient.update('groceries', groceryModel.toMap(),
        where: 'id = ?', whereArgs: [groceryModel.id]);
  }
}

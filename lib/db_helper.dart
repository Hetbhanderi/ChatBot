import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  Database? Db;
  DbHelper._();
  static final _instance = DbHelper._();

  static DbHelper getDbinstance() {
    return _instance;
  }

  Future<Database> opendb() async {
    if (Db != null) {
      print("Db Exists");
      return Db!;
    } else {
      print("Create Db");
      return await createdb();
    }
  }

  Future<Database> createdb() async {
    try {
      if (Db == null) {
        final dbdir = await getDatabasesPath();
        final path = join(dbdir, "Chatbot.db");
        Db = await openDatabase(
          path,
          onCreate: (Database db, int version) async {
            await db.execute('''
                    CREATE TABLE IF NOT EXISTS conversations (
                      id INTEGER PRIMARY KEY AUTOINCREMENT,
                      table_name TEXT UNIQUE,
                      last_updated INTEGER
                    )
                  ''');
          },
          version: 1,
        );
        return Db!;
      }
    } catch (e) {
      print(e);
    }
    return Db!;
  }

  Future<void> createTable({required String TableName}) async {
    if (Db == null) {
      opendb();
    } else {
      String DbTableName = TableName.replaceAll(" ", "_");
      try {
        await Db!.execute("""
          CREATE TABLE $DbTableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            role TEXT,
            text TEXT
          )
        """);

        print("Table $DbTableName created");

        await Db!.insert("conversations", {
          "table_name": DbTableName,
          "last_updated": DateTime.now().millisecondsSinceEpoch,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> saveMessage({
    required String role,
    required String text,
    required String TableName,
  }) async {
    try {
      if (Db == null) {
        await opendb();
      }
      int row = await Db!.insert(TableName, {
        "role": role.toString(),
        "text": text.toString(),
      });
      if (row > 0) {
        print("Data Inserted");
        await Db!.update(
          "conversations",
          {"last_updated": DateTime.now().millisecondsSinceEpoch},
          where: "table_name = ?",
          whereArgs: [TableName],
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List<Map<String, dynamic>>> getmessages({
    required String TableName,
  }) async {
    if (Db == null) {
      await opendb();
    }
    List<Map<String, dynamic>> alldata = await Db!.query(
      TableName,
      orderBy: "id ASC",
    );
    return await alldata;
  }

  Future<List<Map<String, dynamic>>> getAllConversations() async {
    if (Db == null) {
      await opendb();
    }
    List<Map<String, dynamic>> AllConversations = await Db!.query(
      "conversations",
      orderBy: "last_updated DESC", // latest first
    );
    return await AllConversations;
  }

  Future<void> DeleteConversation({required String dbTableName}) async {
    try {
      if (Db == null) {
        await opendb();
      }
      await Db!.execute("DROP TABLE IF EXISTS $dbTableName");
      print("Table $dbTableName dropped successfully");

      await Db!.delete(
        "conversations",
        where: "table_name = ?",
        whereArgs: [dbTableName],
      );
      print("Conversation entry removed");
    } catch (e) {
      print("Error in Delete Conversition : $e");
    }
  }
}

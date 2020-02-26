import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
//书籍信息
final String bookInfo = 'bookinfo';
final String colId = '_id';
final String colName = 'name';
final String colAuther = 'auther';
final String colTranslator = 'translator';
final String colPub = 'pub';
final String colPagetotal = 'page_total';
final String colPagecurrent = 'page_current';
final String colCreatetime = 'create_time';
final String colFinishtime = 'finish_time';
class BookInfo {
  int id; //id
  String name; //名字
  String auther; //作者
  String translator; //译者
  String pub; //出版社
  int page_total; //总页数
  int page_current; //当前页数
  String create_time;//加入书架的时间
  String finish_time;//书籍读完时间
  //利用page来控制书籍的状态，为0就是未读，[1,max)就是在读，max就是读完了
  //映射为dynamic
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
    };
    map[colId] = id;
    map[colName] = name;
    map[colAuther] = auther;
    map[colTranslator] = translator;
    map[colPub] = pub;
    map[colPagetotal] = page_total;
    map[colPagecurrent] = page_current;
    map[colCreatetime] = create_time;
    map[colFinishtime] = finish_time;
    return map;
  }

  BookInfo();

  BookInfo.fromMap(Map<String, dynamic> map){
    id = map[colId];
    name = map[colName];
    auther = map[colAuther];
    translator = map[colTranslator];
    pub = map[colPub];
    page_total = map[colPagetotal];
    page_current = map[colPagecurrent];
    create_time = map[colCreatetime];
    finish_time = map[colFinishtime];
  }
}
//数据库操作
class BookDb{
  Database db;
  Future open() async {
    var databasepath = await getDatabasesPath();
    String path = join(databasepath, 'mybook.db');
    db = await openDatabase(path, version: 1,
    onCreate: (Database db, int version) async{
      await db.execute('''
      create table $bookInfo(
      $colId integer primary key autoincrement,
      $colName text not null,
      $colAuther text not null,
      $colTranslator text,
      $colPub text not null,
      $colPagetotal int not null,
      $colPagecurrent int not null,
      $colCreatetime text not null,
      $colFinishtime text)
      ''');
    });
  }
  Future<BookInfo> insert(BookInfo bookinfo) async {
    bookinfo.id = await db.insert(bookInfo, bookinfo.toMap());
    return bookinfo;
  }
  //model 0:所有的书；1：未读的书；2：在读的书；3：读完的书
  Future<List<Map>> getbooks(int model) async{
    String where_query;
    switch(model){
      case 0:
        where_query = '$colPagecurrent >= 0';
        break;
      case 1:
        where_query = '$colPagecurrent = 0';
        break;
      case 2:
        where_query = '$colPagecurrent > 0 and $colPagecurrent < $colPagetotal';
        break;
      default:
        where_query = '$colPagecurrent = $colPagetotal';
    }
    List<Map> maps = await db.query(bookInfo,
    columns: [colId, colName, colAuther, colTranslator, colPub, colPagetotal, colPagecurrent, colCreatetime, colFinishtime],
      where: where_query);
    if (maps.length > 0){
      return maps;
    }
    return null;
  }

  Future<int> delete(int id) async{
    return await db.delete(bookInfo, where:'$colId = ?', whereArgs: [id]);
  }

  Future<int> update(BookInfo bookinfo) async{
    return await db.update(bookInfo, bookinfo.toMap(), where:'$colId = ?', whereArgs: [bookinfo.id]);
  }

  Future close() async => db.close();
}



import 'package:flutter/material.dart';
import 'package:ink_book/Pages.dart';
import 'package:ink_book/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

void main() => runApp(new Inker());

class Inker extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    for (var i = 0; i < 4; i ++)
      bookpage_flags[i] = false;
    return new MaterialApp(
      home: new DefaultTabController(
          length: (choices.length),
          child: new Scaffold(
            appBar: new AppBar(
              title: const Text('墨客 Inker'),
              bottom: new TabBar(
                isScrollable: true,
                tabs: choices.map((Choice choice) {
                  return new Tab(
                    text: choice.title,
                    icon: new Icon(choice.icon),
                  );
                }).toList(),
              ),
            ),
          body: new TabBarView(
              children: choices.map((Choice choice){
                return new Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: new ChoiceCard(choice: choice),
                );
              }).toList(),
          ),
            floatingActionButton: FloatingActionButton(
                onPressed: (){
                  //刷新页面
                  for (var i = 0; i < 4; i ++)
                    bookpage_flags[i] = false;
            },
                child: Icon(Icons.refresh),
            backgroundColor: Colors.green,),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          )
      ),
    );
  }
}

class Choice{
  const Choice({ this.title, this.icon, this.page });
  final String title;//分页标题
  final IconData icon;//分页图标
  final int page;//分页标识，0:所有的书；1：未读的书；2：在读的书；3：读完的书
}

const List<Choice> choices = const <Choice>[
  const Choice(title: '所有书目', icon: Icons.library_books, page: 0),
  const Choice(title: '准备读', icon: Icons.bookmark_border, page: 1),
  const Choice(title: '正在读', icon: Icons.book, page: 2),
  const Choice(title: '已读完', icon: Icons.bookmark, page: 3)
];



class ChoiceCard extends StatelessWidget{
  const ChoiceCard({ Key key, this.choice }) : super(key: key);
  final Choice choice;
  @override
  Widget build(BuildContext context){
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    switch(choice.page){
      case 0:
        if (!bookpage_flags[0]) {
          get_All_books(0);
          bookpage_flags[0] = true;
        }
        if (books_all.length > 0)
          {
        return new Scaffold(
          body:Center(
            child:
            new ListView.builder(
              itemBuilder: (context, index)=>new BookRow(books_all[index]),
              itemCount: books_all.length,
            )
          ),

          floatingActionButton: FloatingActionButton.extended(
            heroTag: "btn0",
              onPressed: (){
                Navigator.push(context, new MaterialPageRoute(builder: (context) => NewBook()),);
              },
              label: Text('新增书籍'),
              icon: Icon(Icons.add_box),
            backgroundColor: Colors.green,
          ),

        );}
        else{
          return new Scaffold(
            body: Center(
              child: new Text('你还没有添加过书籍，快添加吧'),
            ),
            floatingActionButton: FloatingActionButton.extended(
              heroTag: "btn1",
              onPressed: (){
                Navigator.push(context, new MaterialPageRoute(builder: (context) => NewBook()),);
              },
              label: Text('新增书籍'),
              icon: Icon(Icons.add_box),
              backgroundColor: Colors.green,
            ),
          );
        }
      break;
      case 1:
        if (!bookpage_flags[1]) {
          get_All_books(1);
          bookpage_flags[1] = true;
        }
        if(books_ready.length > 0){
        return new Container(
            child: new Column(
              children: <Widget>[
                Expanded(
                    child:
                    new ListView.builder(
                      itemBuilder: (context, index) => new BookRow(books_ready[index]),
                      itemCount: books_ready.length,
                    )),
              ],
            )
        );}
        else
          {
            return new Scaffold(
              body: Center(
                child: new Text('你还没有准备阅读的书籍'),
              ),
            );
          }
      break;
      case 2:
        if (!bookpage_flags[2]) {
          get_All_books(2);
          bookpage_flags[2] = true;
        }
        if (books_reading.length > 0){
        return new Container(
            child: new Column(
              children: <Widget>[
                Expanded(
                    child:
                    new ListView.builder(
                      itemBuilder: (context, index) => new BookRow(books_reading[index]),
                      itemCount: books_reading.length,
                    )),
              ],
            )
        );}
        else{
          return new Scaffold(
            body: Center(
              child: new Text('你还没有正在阅读的书籍'),
            ),
          );
        }
        break;
      default:
        if (!bookpage_flags[3]) {
          get_All_books(3);
          bookpage_flags[3] = true;
        }
        if(books_readed.length>0){
        return new Container(
            child: new Column(
              children: <Widget>[
                Expanded(
                    child:
                    new ListView.builder(
                      itemBuilder: (context, index) => new BookRow(books_readed[index]),
                      itemCount: books_readed.length,
                    )),
              ],
            )
        );}
        else{
          return new Scaffold(
            body: Center(
              child: new Text('你还没有阅读完的书籍'),
            ),
          );
        }
    }
  }
}


//每个book的行表示
class BookRow extends StatelessWidget{
  final BookInfo bookinfo;
  BookRow(this.bookinfo);
  @override
  Widget build(BuildContext context){
    return new Container(
      height: 80.0,
      margin: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 24.0,
      ),
    child: new Column(
      children: <Widget>[
        new BookCard(bookinfo: bookinfo,),
      ],
    ),
    );
  }
}


//得到所有书目信息
List<BookInfo> books_all = new List();
//准备读的书
List<BookInfo> books_ready = new List();
//正在读的书
List<BookInfo> books_reading = new List();
//已经读的书
List<BookInfo> books_readed = new List();
get_All_books(int model) async {
  List<Map> listmap;
  var db = new BookDb();
    await db.open();
    switch(model){
      case 0:
        books_all = new List();
        listmap = await db.getbooks(0);
      break;
      case 1:
        books_ready = new List();
        listmap = await db.getbooks(1);
      break;
      case 2:
        books_reading = new List();
        listmap = await db.getbooks(2);
      break;
      default:
        books_readed = new List();
        listmap = await db.getbooks(3);
    }
     if (listmap != null) {
       for (var m in listmap) {
         var book = new BookInfo();
         book.id = m[colId];
         book.name = m[colName];
         book.auther = m[colAuther];
         book.translator = m[colTranslator];
         book.pub = m[colPub];
         book.page_total = m[colPagetotal];
         book.page_current = m[colPagecurrent];
         book.create_time = m[colCreatetime];
         book.finish_time = m[colFinishtime];
         switch (model) {
           case 0:
             books_all.add(book);
             break;
           case 1:
             books_ready.add(book);
             break;
           case 2:
             books_reading.add(book);
             break;
           default:
             books_readed.add(book);
         }
       }
     }
}
//用来判断是否已经生成过读书，不必要重复生成
List<bool> bookpage_flags = [false, false, false, false];

//每一条书籍信息的卡片
class BookCard extends StatelessWidget{
  const BookCard({ Key key, this.bookinfo }) : super(key: key);
  final BookInfo bookinfo;
  @override
  Widget build(BuildContext context){
    return new Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.book, size: 50,color: Colors.brown),
              title: Text(bookinfo.name),
              subtitle: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(bookinfo.auther)
                  ),
                  Expanded(
                    child: Text('进度' + bookinfo.page_current.toString() + '/' + bookinfo.page_total.toString())
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.arrow_right, color: Colors.green),
                onPressed: (){
                  //Navigator.push(context, new MaterialPageRoute(builder: (context) => new BookDetail(bookinfo: bookinfo)),);//转移到书籍详情页面
                  Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(builder: (context) => BookDetail(bookinfo: bookinfo,)),(route)=>route==null);
                },
                )
            ),
          ],
        )
    );
  }
}
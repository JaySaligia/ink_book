import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ink_book/database.dart';
import 'package:ink_book/main.dart';
import 'package:intl/intl.dart';
//管理页面状态
//新建一条书籍数据
class NewBook extends StatefulWidget{
  NewBook({ Key key}) : super (key: key);
  @override
  _NewBookState createState() => new _NewBookState();
}

class _NewBookState extends State<NewBook>{
  final TextEditingController _controllerName = new TextEditingController();
  final TextEditingController _controllerAuthor = new TextEditingController();
  final TextEditingController _controllerTranslator = new TextEditingController();
  final TextEditingController _controllerPub = new TextEditingController();
  final TextEditingController _controllerTotalPage = new TextEditingController();

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      body:new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text('手动录入'),
          new TextField(//书的名字
            keyboardType: TextInputType.text,
            controller: _controllerName,
            decoration: new InputDecoration(
              hintText: '输入想读的书名',
            ),
          ),
          new TextField(//书的作者
            keyboardType: TextInputType.text,
            controller: _controllerAuthor,
            decoration: new InputDecoration(
              hintText: '输入作者',
            ),
          ),
          new TextField(//书的译者
            keyboardType: TextInputType.text,
            controller: _controllerTranslator,
            decoration: new InputDecoration(
                hintText: '输入译者'
            ),
          ),
          new TextField(//书的出版社
            keyboardType: TextInputType.text,
            controller: _controllerPub,
            decoration: new InputDecoration(
                hintText: '输入出版社'
            ),
          ),
          new TextField(//书的总页数
            keyboardType: TextInputType.number,
            controller: _controllerTotalPage,
            decoration: new InputDecoration(
                hintText: '输入总页数'
            ),
          ),
          new RaisedButton(onPressed: (){//返回主页
            Navigator.push(context, new MaterialPageRoute(builder: (context) => new Inker()),
            );
          },
          child: new Text('返回'),
            shape: new RoundedRectangleBorder(),
          ),
          new RaisedButton(//创建书籍
            onPressed: () async {
              switch(checkInput()){
                case 0://输入数据合法
                  BookInfo bookinfo = new BookInfo();
                  bookinfo.name = _controllerName.text;
                  bookinfo.auther = _controllerAuthor.text;
                  bookinfo.translator = _controllerTranslator.text;
                  bookinfo.pub = _controllerPub.text;
                  bookinfo.page_total = int.parse(_controllerTotalPage.text);
                  bookinfo.page_current = 0;
                  bookinfo.create_time = DateFormat('yyyy-MM-dd kk:mm').format(DateTime.now());
                  var db = new BookDb();
                  await db.open();
                  await db.insert(bookinfo);
                  await db.close();
                  Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(builder: (context) => Inker()),(route)=>route==null);
                  break;
                default:
                  break;
              }
            },
            child: new Text('创建'),
            shape: new RoundedRectangleBorder(),
          )
        ],
      )
    );
  }
}
//检测数据输入是否合法
int checkInput(){
  return 0;
}

//每本书的详情页面
class BookDetail extends StatefulWidget{
  BookDetail({Key key, this.bookinfo}) :super (key: key);
  final BookInfo bookinfo;
  @override
  _BookDetailPage createState() => new _BookDetailPage();
}

class _BookDetailPage extends State<BookDetail>{
  final TextEditingController _controllerPage = new TextEditingController();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('墨客Inker'),
        leading: IconButton(
            icon: Icon(Icons.subdirectory_arrow_left),
            onPressed: (){
              Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(builder: (context) => Inker()),(route)=>route==null);
            }),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            leading:
            Column(
            children: <Widget>[
              Expanded(
                child: Icon(Icons.book, color: Colors.brown, size: 120.0),
              ),
            ],
      ),

            title: Text(widget.bookinfo.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('作者: ' + widget.bookinfo.auther),
                Text(widget.bookinfo.translator != null?'译者: ' + widget.bookinfo.translator:'译者: 无'),
                Text(widget.bookinfo.pub != null?'出版社: ' + widget.bookinfo.pub:'出版社: 无'),
                Text('总页数: ' + widget.bookinfo.page_total.toString()),
                Text('创建日期:' + widget.bookinfo.create_time),
                Text(widget.bookinfo.finish_time != null?'阅读完成时间: ' + widget.bookinfo.finish_time:'当前阅读进度: ' + widget.bookinfo.page_current.toString() + '页 (' + (widget.bookinfo.page_current / widget.bookinfo.page_total * 100).toStringAsFixed(2) + '%)'),
                RaisedButton.icon(
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text('删除这本书',style: TextStyle(color: Colors.red),),
                  color: Colors.lime,
                  onPressed: (){
                    showDialog<Null>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text('确认删除？'),
                          actions: <Widget>[
                            new FlatButton(onPressed: () async{
                              var db = new BookDb();
                              await db.open();
                              await db.delete(widget.bookinfo.id);
                              await db.close();
                              Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(builder: (context) => Inker()),(route)=>route==null);
                              //Navigator.push(context, new MaterialPageRoute(builder: (context) => BookDetail(bookinfo: widget.bookinfo,)),);
                            }, child: Text('确定')),
                            new FlatButton(onPressed: (){Navigator.of(context).pop();}, child: Text('取消'))
                          ],
                        );
                      },
                    );
                  },
                )
              ],
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            showDialog<Null>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context){
                return AlertDialog(
                  title: Text('修改页数(总页数: ' + widget.bookinfo.page_total.toString() + ')' ),
                  content: TextField(
                    keyboardType: TextInputType.number,
                    controller: _controllerPage,
                    decoration: new InputDecoration(
                        hintText: '输入已读页数'
                    ),
                  ),
                  actions: <Widget>[
                    new FlatButton(onPressed: () async{
                      //检测输入合法
                      //
                      widget.bookinfo.page_current = int.parse(_controllerPage.text);
                      if (widget.bookinfo.page_current == widget.bookinfo.page_total){
                        //如果书已经读完了，记录下当前时间
                        widget.bookinfo.finish_time = DateFormat('yyyy-MM-dd kk:mm').format(DateTime.now());
                      }
                      var db = new BookDb();
                      await db.open();
                      await db.update(widget.bookinfo);
                      await db.close();
                      Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(builder: (context) => BookDetail(bookinfo: widget.bookinfo,)),(route)=>route==null);
                    //Navigator.push(context, new MaterialPageRoute(builder: (context) => BookDetail(bookinfo: widget.bookinfo,)),);
                    }, child: Text('确定')),
                    new FlatButton(onPressed: (){Navigator.of(context).pop();}, child: Text('取消'))
                  ],
                );
              },
            );
          },
          label: Text('修改页数'),
          icon: Icon(Icons.edit),
          backgroundColor: Colors.green,
      ),

    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(new FriendlychatApp());
}

class FriendlychatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Friendlychat",
      home: new ChatScreen(),
    );
  }
}

/*
   如果要在窗口小部件中直观地显示有状态数据，则应将此数据封装在State对象中。
   然后，您可以将State对象与扩展StatefulWidget该类的窗口小部件相关联。 
*/
class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  // TextEditingController读取输入字段的内容，并在发送文本消息后清除字段
  final TextEditingController _textController = new TextEditingController();
  void _handleSubmitted(String text) {
    _textController.clear();
  }

  @override
  // 每个小部件都有自己的小部件BuildContext，它们成为StatelessWidget.buildor State.build函数返回的小部件的父级
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Friendlychat"),
      ),
      body: _buildTextComposer(),
    );
  }

  Widget _buildTextComposer() {
    // 图标从小IconTheme部件继承其颜色，不透明度和大小，小部件使用IconThemeData对象来定义这些特征。
    // IconTheme的data属性指定当前主题的对象
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              // Flexible告诉Row自动调整文本字段的大小以使用按钮未使用的剩余空间
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmitted,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
                ),
              ),
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              )
            ],
          )),
    );
  }
}

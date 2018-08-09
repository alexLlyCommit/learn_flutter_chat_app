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

/*
* Flutter中动画被封装为Animation：包含类型值和状态（例如前进，后退，完成和解除）的对象。
* 基于对动画对象属性的更改，框架可以修改窗口小部件的显示方式并重建窗口小部件树。
* 动画控制器AnimationController指定动画的运行方式，可以定义动画的重要特征
* 创建AnimationController时需要将vsync参数传递给它，改参数可以防止动画在屏幕之外消耗不必要的资源
* 如果要使用ChatScreenState的vsync，需要在ChatScreenState类定义中包含TickerProviderStateMixin的mixin
*/
class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  // 每个列表项都是一个ChatMessage的实例，初始化列表为空
  final List<ChatMessage> _messages = <ChatMessage>[];
  // TextEditingController读取输入字段的内容，并在发送文本消息后清除字段
  final TextEditingController _textController = new TextEditingController();
  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = new ChatMessage(
        text: text,
        // 实例化一个AnimationController对象并将动画的运行时间指定为700毫秒。
        animationController: new AnimationController(
          duration: new Duration(milliseconds: 700),
          vsync: this,
        ));
    // setState是一个同步操作
    // 通常，setState()在此方法调用之外更改某些私有数据后，可以使用空闭包进行调用。但是，更新内部setState()闭包中的数据是首选，因此您不必忘记之后调用它。
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }

  @override
  // 重写dispose返回，达到处动画理控制器时候不在需要释放资源，担忧多个屏幕的时候
  void dispose() {
    for (ChatMessage message in _messages)
      message.animationController.dispose();
    super.dispose();
  }

  @override
  // 每个小部件都有自己的小部件BuildContext，它们成为StatelessWidget.buildor State.build函数返回的小部件的父级
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Friendlychat"),
        ),
        body: new Column(
          children: <Widget>[
            new Flexible(
              /*
             * ListView用于滚动列表
             * ListView为消息列表添加一个小部件。我们选择ListView.builder构造函数，因为默认构造函数不会自动检测其children参数的突变
             * 将参数传递给ListView.builder构造函数以自定义列表内容和外观： reverse使ListView开始从屏幕底部, itemCount 指定列表中的消息数
             * itemBuilder用于构建每个小部件的函数[index]。由于我们不需要当前的构建上下文，我们可以忽略第一个参数IndexedWidgetBuilder。命名参数_（下划线）是一种约定，表示不会使用它。
             */
              child: new ListView.builder(
                padding: new EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, int index) => _messages[index],
                itemCount: _messages.length,
              ),
            ),
            // 在用于显示消息的UI和用于撰写消息的文本输入字段之间绘制水平规则
            new Divider(height: 1.0),
            // 可用于定义背景图像，填充，边距和其他常见布局细节。
            new Container(
              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            )
          ],
        ));
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

const String _name = "Your name";

// 聊甜消息的小部件需要嵌套在父的可滚动列表中
class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.animationController});
  final String text;
  // 变量用于存储动画控制器
  final AnimationController animationController;
  @override
  Widget build(BuildContext context) {
    // 返回SizeTransition包装Container对子窗口小部件提供动画进出的效果
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        /*
        * 对于头像，父级是一个Row小部件，其主轴是水平的，因此CrossAxisAlignment.start沿垂直轴给出最高位置。
        * 对于消息，父级是一个Column小部件，其主轴是垂直的，因此CrossAxisAlignment.start沿着水平轴将文本对齐在最左边的位置。
        */
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(child: new Text(_name[0])),
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(_name, style: Theme.of(context).textTheme.subhead),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new Text(text),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

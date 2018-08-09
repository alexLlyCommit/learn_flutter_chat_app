import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(new FriendlychatApp());
}

// 为Android和IOS定义不同的主题色
final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = new ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

class FriendlychatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Friendlychat",
      // theme属性控制主题样式
      // 使用顶级defaultTargetPlatform属性和条件运算符构建用于选择主题的表达式。
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? kIOSTheme
          : kDefaultTheme,
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
  // 控制按钮样式
  bool _isComposing = false;
  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
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
          elevation: // 定义appBar阴影
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        // 将小平面包裹Column在Container小部件中，使其上边缘呈现浅灰色边框。
        body: new Container(
          child: new Column(
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
                decoration: Theme.of(context).platform == TargetPlatform.iOS
                    ? new BoxDecoration(
                        border: new Border(
                          top: new BorderSide(color: Colors.grey[200]),
                        ),
                      )
                    : null,
                child: _buildTextComposer(),
              )
            ],
          ),
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
                  onChanged: (String text) {
                    setState(() {
                      _isComposing = text.length > 0;
                    });
                  },
                  onSubmitted: _handleSubmitted,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
                ),
              ),
              new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 4.0),
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new CupertinoButton(
                          child: new Text("Send"),
                          onPressed: _isComposing
                              ? () => _handleSubmitted(_textController.text)
                              : null,
                        )
                      : new IconButton(
                          icon: new Icon(Icons.send),
                          /*
                    * 如果用户在文本字段中输入字符串，_isComposing是true和按钮的颜色设置为Theme.of(context).accentColor。当用户按下按钮时，系统调用_handleSubmitted()。
                    * 如果用户没有任何类型的文本字段，_isComposing是false和小部件的onPressed属性设置为null，禁用发送按钮。框架会自动将按钮的颜色更改为Theme.of(context).disabledColor。
                    */
                          onPressed: _isComposing
                              ? () => _handleSubmitted(_textController.text)
                              : null,
                        ))
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
            // Expanded部件可以在当信息长度超过ui宽度的时候进行换行显示整个消息
            new Expanded(
                child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(_name, style: Theme.of(context).textTheme.subhead),
                new Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: new Text(text),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}

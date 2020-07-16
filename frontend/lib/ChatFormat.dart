import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import './MultimediaHandeling.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

List<ChatMessage> messages = <ChatMessage>[];
int mailAlert = 0;

class HomePageDialogflow extends StatefulWidget {
  HomePageDialogflow({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageDialogflow createState() => new _HomePageDialogflow();
}

class _HomePageDialogflow extends State<HomePageDialogflow> {
  final TextEditingController _textController = new TextEditingController();
  Widget _buildTextComposer() {
    print(mailAlert);
    return new IconTheme(
      data: new IconThemeData(color: Colors.green[400]),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            mailAlert == 1
                ? new Flexible(
                    child: new TextField(
                      enabled: false,
                      controller: _textController,
                      onSubmitted: handleSubmitted,
                      decoration: new InputDecoration.collapsed(
                          hintText:
                              "Thanks our team will reach to you very soon"),
                    ),
                  )
                : new Flexible(
                    child: new TextField(
                      controller: _textController,
                      onSubmitted: handleSubmitted,
                      decoration: new InputDecoration.collapsed(
                          hintText:
                              "Say Hey or greet to start/Restart conversation"),
                    ),
                  ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => handleSubmitted(_textController.text)),
            ),
          ],
        ),
      ),
    );
  }

  Future<http.Response> addMail(String email) async {
    String url = "http://c4849648e605.ngrok.io";
    String uri = Uri.encodeFull(url + "/getmail");
    var bodyEncoded = json.encode({
      "email": email,
    });
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    var response;
    response = await http.post(uri, headers: headers, body: bodyEncoded);
    print(response.body);
    return (response);
  }

  //Checking valid email address
  void Response(query) async {
    RegExp regExp = new RegExp(
      r"^[\w+?\.]+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$",
    );
    // print('Here');
    if (regExp.hasMatch(query) == true) {
      mailAlert = 1;
      print('matched');
      await addMail(query); // call to backend to store email address
      // call Api to add mail in backend.
    }
    _textController.clear();
    //for Dialogflow
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/credentials.json").build();
    Dialogflow dialogflow =
        Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse response = await dialogflow.detectIntent(query);
    var botsuggestion = BotSuggestions(response.getListMessage());
    var botimages = BotImages(response.getListMessage());
    var botinformation = BotInfo(response.getListMessage());
    // print(botsuggestion.suggestions);
    // print(botimages.images);
    // print(botinformation.info);
    ChatMessage message = new ChatMessage(
      text: response.getMessage() ??
          new CardDialogflow(response.getListMessage()[0]).title,
      name: "Billy",
      type: false,
      options: botsuggestion.suggestions,
      imageOptions: botimages.images,
      botInfo: botinformation.info,
    );
    setState(() {
      messages.insert(0, message);
    });
  }

  // to handle text submitted by user.
  void handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = new ChatMessage(
      text: text,
      name: "User",
      type: true,
    );
    // again ans again building the pge
    // to show the message from bot and user
    setState(() {
      messages.insert(0, message);
    });
    Response(text);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.green[400],
        centerTitle: true,
        title: Row(
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(
                child: new Image.asset(
                  // images are being saved on machine fetching it from networks takes time.
                  "assets/images/bot.jpg",
                  width: 29,
                  height: 29,
                ),
                backgroundColor: Colors.white,
              ),
            ),
            new Text(
              "Hi! This is your assistant bot Billy",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
          padding: new EdgeInsets.all(8.0),
          reverse: true,
          itemBuilder: (_, int index) => messages[index],
          itemCount: messages.length,
        )),
        new Divider(height: 1.0),
        new Container(
          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
          child: _buildTextComposer(),
        ),
      ]),
    );
  }
}

// defines format of display of chat messages
class ChatMessage extends StatefulWidget {
  ChatMessage(
      {this.text,
      this.name,
      this.type,
      this.options,
      this.imageOptions,
      this.botInfo,
      this.botLink});

  final String text;
  final String name;
  final bool type;
  final List options;
  final List imageOptions;
  final List botInfo;
  final List botLink;
  @override
  _ChatMessageState createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  // handle submission by clicked on the option buttons given.
  void handleSubmitted(String text) async {
    print(text);
    ChatMessage message = new ChatMessage(
      text: text,
      name: "User",
      type: true,
    );
    messages.insert(0, message);
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/credentials.json")
            .build(); // crenditial auth
    Dialogflow dialogflow =
        Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse response =
        await dialogflow.detectIntent(text); // Api call to dialogflow
    var botsuggestion = BotSuggestions(
        response.getListMessage()); //get list of options user can have
    var botimages = BotImages(response.getListMessage()); // get list of images
    var botinformation = BotInfo(response
        .getListMessage()); // get list of additonal text apart from response
    var botlink = BotLink(response.getListMessage());
    print(response.getListMessage());
    print(botinformation.info);
    print(botlink.links);
    ChatMessage message1 = new ChatMessage(
      text: response.getMessage() ??
          new CardDialogflow(response.getListMessage()[0]).title,
      name: "Bot",
      type: false,
      options: botsuggestion.suggestions,
      imageOptions: botimages.images,
      botInfo: botinformation.info,
      botLink: botlink.links,
    );
    messages.insert(0, message1);
  }

// handels formating of bots message.
  List<Widget> otherMessage(context) {
    print("botlink");
    print(widget.botLink);
    return <Widget>[
      new Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: new CircleAvatar(
          child: new Image.asset(
            // images are being saved on machine fetching it from networks takes time.
            "assets/images/bot.jpg",
            width: 31,
            height: 31,
          ),
          backgroundColor: Colors.white,
        ),
      ),
      // Bot's response
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Card(
              color: Colors.grey[100],
              margin: EdgeInsets.fromLTRB(0, 5, 10, 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(
                  this.widget.text,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
            // images if any
            widget.imageOptions != null
                ? new ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: widget.imageOptions.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        width: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        alignment: Alignment.topLeft,
                        child: new Image.asset(
                          "assets/images/" + widget.imageOptions[index],
                        ),
                      );
                    },
                  )
                : null,
            // additional information if any in form of list
            widget.botInfo != null
                ? new ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: widget.botInfo.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        alignment: Alignment.topLeft,
                        child: new Card(
                          color: Colors.grey[100],
                          margin: EdgeInsets.fromLTRB(0, 5, 10, 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text(
                              widget.botInfo[index],
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : null,
            widget.botLink != null
                ? new ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: widget.botLink.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new Card(
                        color: Colors.grey[100],
                        margin: EdgeInsets.fromLTRB(0, 5, 10, 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            child: new Text(
                              'Sales Channel automation', // Sorry for hardcode since we have one link in whole
                              style: TextStyle(
                                  // bot hence i didn't bother to create a handeler for link name
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[400]),
                            ),
                            onTap: () => launch(widget.botLink[index]),
                          ),
                        ),
                      );
                    },
                  )
                : SizedBox(
                    height: 1,
                  ),
            // option buttons for the user.
            widget.options != null
                ? new ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: widget.options.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new InkWell(
                        onTap: () async {
                          // making function to wait untill it completes the response of particular phrase
                          // so that screen doesnt refresh without a response.
                          await handleSubmitted(widget.options[index]);
                          // building the page again after the response has been fetche
                          // building here will just change the pixels which are rest page remains same.
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePageDialogflow()),
                              (route) => false);
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 3),
                          child: Material(
                            borderRadius: BorderRadius.circular(20.0),
                            shadowColor: Colors.greenAccent,
                            color: Colors.green,
                            elevation: 7.0,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Center(
                                child: Text(
                                  widget.options[index].toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : null,
          ],
        ),
      ),
    ];
  }

// formatting of user's message
  List<Widget> myMessage(context) {
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Card(
              color: Colors.blue[100],
              margin: EdgeInsets.fromLTRB(0, 5, 10, 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(
                  this.widget.text,
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
      new Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: new CircleAvatar(
            backgroundColor: Colors.green[400],
            child: new Text(
              this.widget.name[0],
              style: new TextStyle(fontWeight: FontWeight.bold),
            )),
      ),
    ];
  }

// Creating flow of user's message and bot's reply.
  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.widget.type ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}

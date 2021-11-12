import 'dart:io';
import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/widget/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Chat extends StatefulWidget {
  final String chatRoomId;

  Chat({this.chatRoomId});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  var isHidden = false;
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot){
        return snapshot.hasData ?  ListView.builder(
          itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index){
              if(index > 10) {
                isHidden = true;
              }
              return MessageTile(
                message: snapshot.data.documents[index].data["message"],
                sendByMe: Constants.myName == snapshot.data.documents[index].data["sendBy"],
                type: snapshot.data.documents[index].data["type"],
              );
            }) : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "message": messageEditingController.text,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
        "type": Constants.MESSAGE_TEXT_TYPE
      };

      DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  addImageMessage() async {
    final ImagePicker _picker = ImagePicker();
    var image = await _picker.getImage(source: ImageSource.gallery);
    FirebaseStorage storage = FirebaseStorage.instance;
    File selectedImage = File(image.path);
    var ref = storage.ref().child("image1" + DateTime.now().toString());
    var uploadTask = ref.putFile(selectedImage);
    var snapshot = await uploadTask.onComplete;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    print(downloadUrl);

    Map<String, dynamic> chatMessageMap = {
      "sendBy": Constants.myName,
      "message": downloadUrl,
      'time': DateTime
          .now()
          .millisecondsSinceEpoch,
      "type": Constants.MESSAGE_IMAGE_TYPE
    };
    DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);
  }

  @override
  void initState() {
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyText2,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[

                      Expanded(
                        // A flexible child that will grow to fit the viewport but
                        // still be at least as big as necessary to fit its contents.
                        child: Container(
                          color: Color(0xff1c1b1b), // Red
                          height: 120.0,
                          alignment: Alignment.center,
                          child: chatMessages(),
                        ),
                      ),
                      Container(
                        // A fixed-height child.
                        color: Color(0xffeeee00), // Yellow
                        height: 60.0,
                        alignment: Alignment.center,
                        child: Container(alignment: Alignment.bottomCenter,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                            color: Colors.black,
                            child: Row(
                              children: [
                                Expanded(
                                    child: TextField(
                                      controller: messageEditingController,
                                      style: simpleTextStyle(),
                                      decoration: InputDecoration(
                                          hintText: "Message ...",
                                          hintStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                          border: InputBorder.none
                                      ),
                                    )),
                                SizedBox(width: 16,),
                                GestureDetector(
                                  onTap: () {
                                    addMessage();
                                  },
                                  child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                const Color(0x36FFFFFF),
                                                const Color(0x0FFFFFFF)
                                              ],
                                              begin: FractionalOffset.topLeft,
                                              end: FractionalOffset.bottomRight
                                          ),
                                          borderRadius: BorderRadius.circular(50)
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Image.asset("assets/images/send.png",
                                        height: 30, width: 30,)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    addImageMessage();
                                  },
                                  child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                const Color(0xDA002072),
                                                const Color(0x0FFFFFFF)
                                              ],
                                              begin: FractionalOffset.topLeft,
                                              end: FractionalOffset.bottomRight
                                          ),
                                          borderRadius: BorderRadius.circular(50)
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Image.asset("assets/images/gallery.jpg",
                                        height: 30, width: 30,)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () {
  //       enableSend();
  //     },
  //     child: Scaffold(
  //       appBar: appBarMain(context),
  //       body: Container(
  //         child: Stack(
  //           children: [
  //             Container(
  //               child:chatMessages(),
  //             ),
  //             Container(alignment: Alignment.bottomCenter,
  //               width: MediaQuery
  //                   .of(context)
  //                   .size
  //                   .width,
  //               child: Container(
  //                 padding: EdgeInsets.symmetric(horizontal: 9, vertical: 9),
  //                 color: Colors.black,
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                         child: TextField(
  //                           controller: messageEditingController,
  //                           style: simpleTextStyle(),
  //                           decoration: InputDecoration(
  //                               hintText: "Message ...",
  //                               hintStyle: TextStyle(
  //                                 color: Colors.white,
  //                                 fontSize: 16,
  //                               ),
  //                               border: InputBorder.none
  //                           ),
  //                         )),
  //                     SizedBox(width: 16,),
  //                     GestureDetector(
  //                       onTap: () {
  //                         addMessage();
  //                       },
  //                       child: Container(
  //                           height: 40,
  //                           width: 40,
  //                           decoration: BoxDecoration(
  //                               gradient: LinearGradient(
  //                                   colors: [
  //                                     const Color(0x36FFFFFF),
  //                                     const Color(0x0FFFFFFF)
  //                                   ],
  //                                   begin: FractionalOffset.topLeft,
  //                                   end: FractionalOffset.bottomRight
  //                               ),
  //                               borderRadius: BorderRadius.circular(50)
  //                           ),
  //                           padding: EdgeInsets.all(12),
  //                           child: Image.asset("assets/images/send.png",
  //                             height: 30, width: 30,)),
  //                     ),
  //                     GestureDetector(
  //                       onTap: () {
  //                         addImageMessage();
  //                       },
  //                       child: Container(
  //                           height: 40,
  //                           width: 40,
  //                           decoration: BoxDecoration(
  //                               gradient: LinearGradient(
  //                                   colors: [
  //                                     const Color(0xDA002072),
  //                                     const Color(0x0FFFFFFF)
  //                                   ],
  //                                   begin: FractionalOffset.topLeft,
  //                                   end: FractionalOffset.bottomRight
  //                               ),
  //                               borderRadius: BorderRadius.circular(50)
  //                           ),
  //                           padding: EdgeInsets.all(12),
  //                           child: Image.asset("assets/images/gallery.jpg",
  //                             height: 30, width: 30,)),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             )
  //           ],
  //         ),
  //       ),///a
  //     ),
  //   );
  // }
  //
  // void enableSend() {
  //   print("Hello");
  //   isHidden = false;
  // }

}

class MessageTile extends StatelessWidget {
  final String message;
  final String type;
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe, @required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: sendByMe ? 0 : 24,
          right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        padding: type == Constants.MESSAGE_TEXT_TYPE ? EdgeInsets.only(
            top: 10, bottom: 10, left: 20, right: 20) : EdgeInsets.only(
            top: 0, bottom: 0, left: 0, right: 0),
        decoration: BoxDecoration(
            borderRadius: sendByMe ? BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomLeft: Radius.circular(23)
            ) :
            BorderRadius.only(
        topLeft: Radius.circular(23),
          topRight: Radius.circular(23),
          bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe ? [
                const Color(0xff007EF4),
                const Color(0xff2A75BC)
              ]
                  : [
                const Color(0x1AFFFFFF),
                const Color(0x1AFFFFFF)
              ],
            )
        ),
        child: type == Constants.MESSAGE_TEXT_TYPE ? Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'OverpassRegular',
            fontWeight: FontWeight.w300)) : Image.network(message, width: 280,),
      ),
    );
  }
}



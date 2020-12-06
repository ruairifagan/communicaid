import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communicaid/features/login/data/models/user_model.dart';
import 'package:communicaid/injection_container.dart';
import 'package:communicaid/src/models/diary.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryEntryPage extends StatefulWidget {
  static const String routeName = '/diary-entry-page';

  final String collectionName;

  const DiaryEntryPage(
      {@required this.collectionName});

  @override
  _DiaryEntryPageState createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  String currentUserId;
  String currentCategory;
  String title, desc;
  String boxColor = "green";
  bool _isLoading = false;
  bool _low = true;
  bool _medium = false;
  bool _high = false;

  @override
  void initState() {
    final userJsonString =
    serviceLocator<SharedPreferences>().getString('user');
    if (userJsonString != null) {
      final user = UserModel.fromJson(json.decode(userJsonString));
      currentUserId = user.id;
    }
    super.initState();
  }

  void _onLowChanged(_low) => setState(() {
    _low = true;
    _medium = false;
    _high = false;
    boxColor = "green";
  });
  void _onMediumChanged(_medium) => setState(() {
    _low = false;
    _medium = true;
    _high = false;
    boxColor = "yellow";
  });
  void _onHighChanged(_high) => setState(() {
    _low = false;
    _medium = false;
    _high = true;
    boxColor = "red";
  });

  Future<void> addData(diaryData) async {
    final documentReference = Firestore.instance
        .collection('diary')
        .document(currentUserId)
        .collection(widget.collectionName)
        .document(diaryData.timestamp);

    Firestore.instance.runTransaction((transaction) async {
      final documentSnapshot = await transaction.get(documentReference);
      await transaction.set(documentSnapshot.reference, diaryData.toMap());
    });
  }

  getData() async {
    return await Firestore.instance.collection("diary").document(currentUserId).collection(widget.collectionName).snapshots();
  }


  uploadDiary() async {
    setState(() {
      _isLoading = true;
    });

    final diaryEntry = Diary(
      color: boxColor,
      title: title,
      desc: desc,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    addData(diaryEntry).then((result) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Flutter",
              style: TextStyle(fontSize: 22),
            ),
            Text(
              "Blog",
              style: TextStyle(fontSize: 22, color: Colors.blue),
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              uploadDiary();
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.file_upload)),
          )
        ],
      ),
      body: _isLoading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            CheckboxListTile(
                title: Text("Low Priority"),
                value: _low,
                onChanged: _onLowChanged,
            ),
            CheckboxListTile(
                title: Text("Medium Priority"),
                value: _medium,
                onChanged: _onMediumChanged
            ),
            CheckboxListTile(
                title: Text("High Priority"),
                value: _high,
                onChanged: _onHighChanged,
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(hintText: "Title"),
                    onChanged: (val) {
                      title = val;
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: "Desc"),
                    onChanged: (val) {
                      desc = val;
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

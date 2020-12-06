import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communicaid/src/pages/diary_page.dart';
import 'package:flutter/material.dart';
import '../../main.dart';

class DiaryItem extends StatefulWidget {
  final String docId;

  const DiaryItem({
    @required this.docId});

  @override
  _DiaryItemState createState() => _DiaryItemState();
}

class _DiaryItemState extends State<DiaryItem> {

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.grey[100],
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 5.0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openCategoryPage,
            splashColor: Theme.of(context).splashColor,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0,10,0,10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Image.asset(
                      'assets/images/heart_diary.png',
                      height: 50.0,
                      width: 50.0,
                      fit: BoxFit.fitWidth,
                    ),
                    title: Text(
                      widget.docId,
                      style: Theme.of(context).textTheme.title.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _openCategoryPage() {
    Routes.sailor.navigate(DiaryCategoryPage.routeName, params: {
      'docId': widget.docId});
  }
}

class DiaryEntryItem extends StatefulWidget {
  final DocumentSnapshot entryDocument;

  const DiaryEntryItem({
    @required this.entryDocument});

  @override
  _DiaryEntryItemState createState() => _DiaryEntryItemState();
}

class _DiaryEntryItemState extends State<DiaryEntryItem> {

  @override
  Widget build(BuildContext context) {
    return Card(
      color: (widget.entryDocument.data["color"]== "green")?Color(0xff79b380):(widget.entryDocument.data["color"]== "yellow")? Color(0xfff2f556): Color(0xffc45e58),
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 5.0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Theme.of(context).splashColor,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0,10,0,10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Image.asset(
                      'assets/images/heart_diary.png',
                      height: 50.0,
                      width: 50.0,
                      fit: BoxFit.fitWidth,
                    ),
                    title: Text(
                      widget.entryDocument.data['title'],
                      style: Theme.of(context).textTheme.title.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    subtitle: Text(
                      widget.entryDocument.data['desc'],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:communicaid/src/pages/info_topic.dart';
import 'package:flutter/material.dart';
import '../../main.dart';

class InfoItem extends StatefulWidget {
  final String docId;

  const InfoItem({
      @required this.docId});

  @override
  _InfoItemState createState() => _InfoItemState();
}

class _InfoItemState extends State<InfoItem> {

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
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: Image.asset(
                        'assets/images/info_i.jpg',
                        height: 50.0,
                        width: 50.0,
                        fit: BoxFit.cover,
                      ),
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
    Routes.sailor.navigate(InfoCategoryPage.routeName, params: {
      'docId': widget.docId});
  }
}
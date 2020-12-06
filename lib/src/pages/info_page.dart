import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communicaid/src/widgets/info_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/login/data/models/user_model.dart';
import '../../features/login/presentation/bloc/login_bloc.dart';
import '../../features/login/presentation/pages/profile_page.dart';
import '../../injection_container.dart';
import '../../main.dart';
import '../widgets/custom_confirmation_dialog.dart';
import '../widgets/users_search_delegate.dart';
import 'home_page.dart';
import 'info_topic.dart';
import 'settings_page.dart';



class InfoPage extends StatefulWidget {
  static const String routeName = '/info-page';

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  List<DocumentSnapshot> catagoryData;
  String currentUserId;

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

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.dehaze),
          onPressed: () => _scaffoldKey.currentState.openDrawer(),
        ),
        title: Image.asset(
          "assets/images/logo_and_text_alt.png",
          height: 40,
        ),
        elevation: 0.0,
        centerTitle: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: _openSearchScreen,
              child: Icon(
                Icons.search,
                size: 30.0,
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget> [
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xff5d89b3),
                ),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: Image.asset("assets/images/logo.png", width: 100,height: 100,),
                      ),
                      Image.asset("assets/images/logo_text_alt.png",height: 35,),
                    ],
                  ),
                )),
            CustomListTile(Icons.home, "Home", _openProfilePage),
            CustomListTile(Icons.person, "Profile", _openProfilePage),
            CustomListTile(Icons.bookmark, "Diary", _openProfilePage),
            CustomListTile(Icons.message, "Messages", _openMessagesScreen),
            CustomListTile(Icons.drafts, "Forums", _openProfilePage),
            CustomListTile(Icons.calendar_today, "Reminders", _openProfilePage),
            CustomListTile(Icons.info_outline, "Information", _openInfoScreen),
            CustomListTile(Icons.settings, "Settings", () => _openSettingsPage(context)),
            CustomListTile(Icons.cancel, "Log Out", _performLogOut),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 30.0,
            left: 20.0,
            child: Text(
              "Information",
              style: TextStyle(
                fontSize: 30.0,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            )
          ),
          Positioned(
            top: 81.0,
            child: Container(
              height: 2.0,
              width: screenSize.width,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Positioned(
            top: screenSize.height * 0.12,
            child: Container(
              width: screenSize.width,
              height: screenSize.height * 0.85,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
              ),
              child: FutureBuilder <Stream<List<DocumentSnapshot>>>(
                future: getListOfCatagories(),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return StreamBuilder<List<DocumentSnapshot>>(
                    stream: snap.data,
                    builder:
                        (ctx, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      catagoryData = snapshot.data;

                      if (snapshot.data.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/images/logo.png'),
                              Text(
                                'No info available',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (ctx, index) {
                          return InfoItem(
                            docId: snapshot.data[index].documentID,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  final _firestore = serviceLocator<Firestore>();
  Future<Stream<List<DocumentSnapshot>>> getListOfCatagories() async {
    return _firestore.collection('information').snapshots().transform(
      StreamTransformer<QuerySnapshot, List<DocumentSnapshot>>.fromHandlers(
        handleData: (querySnapshot, sink) async {
          print('loading all information headers');
          final _categoriesList = List<DocumentSnapshot>();

          for (final doc in querySnapshot.documents) {
            _categoriesList.add(doc);
          }

          print(_categoriesList);

          sink.add(_categoriesList);
        },
      ),
    );
  }

  void _openSearchScreen() {
    showSearch(
      context: context,
      delegate: UsersSearchDelegate(
        usersData: catagoryData,
      ),
    );
  }
  void _openMessagesScreen() {
    Routes.sailor.navigate(HomePage.routeName);
  }

  void _openInfoScreen() {
    Routes.sailor.navigate(InfoPage.routeName);
  }

  void _openProfilePage() {
    Routes.sailor.navigate(ProfilePage.routeName, params: {
      'userId': null,
    }).then((value) {
      setState(() {});
    });
  }

  void _openSettingsPage(context) {
    Routes.sailor.navigate(SettingsPage.routeName);
  }

  void _performLogOut() {
    showDialog(
      context: context,
      child: CustomConfirmationDialog(
        title: 'Do you want to log out?',
        onCancelPressed: () {
          Navigator.of(context).pop();
        },
        onOkPressed: _sendLogoutEvent,
      ),
    );
  }

  void _sendLogoutEvent() {
    BlocProvider.of<LoginBloc>(context).add(SignOutWithGoogleEvent());
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}

class CustomListTile extends StatelessWidget {
  IconData icon;
  String text;
  Function onTap;

  CustomListTile(this.icon, this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 12.0, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[400]),),
        ),
        child: InkWell(
          splashColor: Colors.blue[200],
          onTap: onTap,
          child:Container(
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(icon),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(text, style: TextStyle(
                        fontSize: 14.0,
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communicaid/core/theme/app_themes.dart';
import 'package:communicaid/src/widgets/custom_app_bar_action.dart';
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
import 'info_page.dart';
import 'settings_page.dart';



class InfoCategoryPage extends StatefulWidget {
  static const String routeName = '/info-category-page';

  final String docId;

  const InfoCategoryPage(
      {@required this.docId});

  @override
  _InfoCategoryPageState createState() => _InfoCategoryPageState();
}

class _InfoCategoryPageState extends State<InfoCategoryPage> {
  List<DocumentSnapshot> categoryData;
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
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 7.0,
                  horizontal: 7.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  image: DecorationImage(
                    image: AssetImage('assets/images/info_i.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                height: 40.0,
                width: 40.0,
              ),
            ),
            Text(
              "Information",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
        leading: CustomAppBarAction(
          iconColor: Colors.white,
          icon: Icons.arrow_back,
          onActionPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned(
              top: screenSize.height * 0.025,
              left: screenSize.width * 0.05,
              child: Text(
                widget.docId,
                style: TextStyle(
                  fontSize: screenSize.height * 0.05,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              )
          ),
          Positioned(
            top: screenSize.height * 0.1,
            child: Container(
              width: screenSize.width,
              height: screenSize.height * 0.78,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
              ),
              child: FutureBuilder <Stream<List<DocumentSnapshot>>>(
                future: getListOfCatagoryQs(),
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

                      categoryData = snapshot.data;

                      if (snapshot.data.isEmpty) {
                        return Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset('assets/images/no_data.png'),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0,20,0,10),
                                  child: Text(
                                    "No info on this topic as of yet!",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (ctx, index) {
                          return ExpansionTile(
                            title: Text(
                              snapshot.data[index].data["question"],
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            children: <Widget>[
                              ListTile(
                                title: Text(snapshot.data[index].data["answer"]),
                              )
                            ],
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
  Future<Stream<List<DocumentSnapshot>>> getListOfCatagoryQs() async {
    return _firestore.collection('information').document(widget.docId).collection(widget.docId).snapshots().transform(
      StreamTransformer<QuerySnapshot, List<DocumentSnapshot>>.fromHandlers(
        handleData: (querySnapshot, sink) async {
          print('loading all information headers');
          final _categoriesList = List<DocumentSnapshot>();

          for (final doc in querySnapshot.documents) {
            if (doc.documentID != "info") {
              _categoriesList.add(doc);
            }
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
        usersData: categoryData,
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
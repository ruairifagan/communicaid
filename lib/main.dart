import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communicaid/src/pages/diary_catagories_page.dart';
import 'package:communicaid/src/pages/diary_entry_page.dart';
import 'package:communicaid/src/pages/diary_page.dart';
import 'package:communicaid/src/pages/info_page.dart';
import 'package:communicaid/src/providers/users_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sailor/sailor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'features/login/domain/entities/user.dart';
import 'features/login/presentation/bloc/login_bloc.dart';
import 'features/login/presentation/pages/loading_page.dart';
import 'features/login/presentation/pages/login_page.dart';
import 'features/login/presentation/pages/profile_page.dart';
import 'features/login/presentation/pages/update_info_page.dart';
import 'injection_container.dart';
import 'src/pages/chat_page.dart';
import 'src/pages/home_page.dart';
import 'src/pages/image_message_view.dart';
import 'src/pages/settings_page.dart';
import 'src/pages/info_topic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await init();
  Routes.createRoutes();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final bloc = serviceLocator<LoginBloc>();
            bloc.add(CheckLoggedInStateEvent());
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) => ThemeBloc(),
        ),
      ],
      child: ChangeNotifierProvider<UsersProvider>(
        create: (_) => UsersProvider(),
        child: BlocBuilder<ThemeBloc, AppThemeState>(
          builder: (_, state) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CommunicAID',
            theme: state.themeData,
            home: BlocListener<LoginBloc, LoginState>(
              listener: (ctx, state) {
                if (state is AlertMessageState) {
                  _displaySnackBar(
                    context: ctx,
                    message: state.message,
                    isSuccessful: true,
                  );
                } else if (state is ErrorState) {
                  _displaySnackBar(
                    context: ctx,
                    message: state.message,
                    isSuccessful: false,
                  );
                }
              },
              child: BlocBuilder<LoginBloc, LoginState>(
                builder: (ctx, state) {
                  if (state is LoggedInState) {
                    try {
                      serviceLocator.registerLazySingleton(() => state.user);
                    } catch (err) {}
                    return HomePage();
                  } else if (state is LoggedOutState ||
                      state is AccountDeletedState) {
                    serviceLocator.unregister(
                      instance: serviceLocator<User>(),
                    );
                    return LoginPage();
                  } else if (state is LoadingState) {
                    return LoadingPage();
                  } else if (state is AlertMessageState) {
                    try {
                      final currentUser = serviceLocator<User>();
                      return HomePage();
                    } catch (error) {
                      return LoginPage();
                    }
                  } else if (state is ErrorState) {
                    try {
                      final currentUser = serviceLocator<User>();
                      return HomePage();
                    } catch (error) {
                      return LoginPage();
                    }
                  } else {
                    return Center(
                      child: Text('Error Loading Screen'),
                    );
                  }
                },
              ),
            ),
            onGenerateRoute: Routes.sailor.generator(),
            navigatorKey: Routes.sailor.navigatorKey,
          ),
        ),
      ),
    );
  }

  void _displaySnackBar({
    BuildContext context,
    String message,
    bool isSuccessful,
  }) {
    Flushbar(
      //margin: const EdgeInsets.all(8.0),
      //borderRadius: 10.0,
      //padding: const EdgeInsets.all(0.0),
      // messageText: CustomSnackBar(
      //   message: message,
      //   isSuccessful: isSuccessful,
      // ),
      message: message,
      duration: Duration(seconds: 2),
    ).show(context);
  }
}

class Routes {
  static Sailor sailor = Sailor();

  static void createRoutes() {
    sailor.addRoutes([
      SailorRoute(
        name: LoginPage.routeName,
        builder: (_, args, params) => LoginPage(),
      ),
      SailorRoute(
        name: HomePage.routeName,
        builder: (_, args, params) => HomePage(),
      ),
      SailorRoute(
        name: InfoPage.routeName,
        builder: (_, args, params) => InfoPage(),
      ),
      SailorRoute(
        name: DiaryPage.routeName,
        builder: (_, args, params) => DiaryPage(),
      ),
      SailorRoute(
          name: ProfilePage.routeName,
          builder: (_, args, params) =>
              ProfilePage(userId: params.param('userId')),
          params: [SailorParam(name: 'userId')]),
      SailorRoute(
        name: ChatPage.routeName,
        builder: (_, args, params) => ChatPage(
          peerId: params.param('peerId'),
          peerName: params.param('peerName'),
          peerImageUrl: params.param('peerImageUrl'),
        ),
        params: [
          SailorParam(
            name: 'peerId',
            defaultValue: '',
            isRequired: true,
          ),
          SailorParam(
            name: 'peerName',
            defaultValue: '',
            isRequired: true,
          ),
          SailorParam(
            name: 'peerImageUrl',
            defaultValue: '',
            isRequired: true,
          ),
        ],
      ),
      SailorRoute(
        name: InfoCategoryPage.routeName,
        builder: (_, args, params) => InfoCategoryPage(
          docId: params.param('docId'),
        ),
        params: [
          SailorParam(
              name: 'docId',
              defaultValue: '',
              isRequired: true)
        ],
      ),
      SailorRoute(
        name: DiaryCategoryPage.routeName,
        builder: (_, args, params) => DiaryCategoryPage(
          docId: params.param('docId'),
        ),
        params: [
          SailorParam(
              name: 'docId',
              defaultValue: '',
              isRequired: true)
        ],
      ),
      SailorRoute(
        name: DiaryEntryPage.routeName,
        builder: (_, args, params) => DiaryEntryPage(
          collectionName: params.param('collectionName'),
        ),
        params: [
          SailorParam(
              name: 'collectionName',
              defaultValue: '',
              isRequired: true)
        ],
      ),
      SailorRoute(
        name: ImageMessageView.routeName,
        builder: (ctx, args, params) => ImageMessageView(
          imageUrl: params.param('imageUrl'),
        ),
        params: [
          SailorParam(
            name: 'imageUrl',
            isRequired: true,
          ),
        ],
      ),
      SailorRoute(
        name: UpdateInfoPage.routeName,
        builder: (_, args, params) {
          return UpdateInfoPage(
            isSigningUp: params.param('isSigningUp'),
          );
        },
        params: [
          SailorParam<bool>(name: 'isSigningUp'),
        ],
      ),
      SailorRoute(
        name: SettingsPage.routeName,
        builder: (_, args, params) => SettingsPage(),
      ),
    ]);
  }
}

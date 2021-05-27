import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app/src/ui/accounts/login/login1/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_form_builder/localization/form_builder_localizations.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
//import 'package:path/path.dart' as p;
//import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:upgrader/upgrader.dart';
import 'others/splash.dart';
import 'src/app.dart';
import 'src/data/gallery_options.dart';
import 'src/models/app_state_model.dart';
import 'src/resources/api_provider.dart';
import 'src/themes/gallery_theme_data_material.dart';
import 'src/ui/intro/intro_slider.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/src/ui/accounts/login/login1/login.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/src/ui/accounts/login/login1/register.dart';
//Directory _appDocsDir;

void setOverrideForDesktop() {
  if (kIsWeb) return;

  if (Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  } else if (Platform.isFuchsia) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() async {
  setOverrideForDesktop();
  AppStateModel model = AppStateModel();
  WidgetsFlutterBinding.ensureInitialized();
  await model.getLocalData();
  await Firebase.initializeApp();
  // await Future.delayed(Duration(milliseconds: 1000), () {

  // }
  //);

  //UnComment when SSL site not working
  //HttpOverrides.global = new MyHttpOverrides();
  //SharedPreferences.setMockInitialValues({});
  //UnComment when Using Dynamic Splash
  //_appDocsDir = await getApplicationDocumentsDirectory();
  runApp(RestartWidget(child: MyApp()));
}

class MyApp extends StatefulWidget {
  final AppStateModel model = AppStateModel();
  MyApp({Key key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final apiProvider = ApiProvider();
  int appVersion = 410111;
  int lastAppVersion = 410111;
  Timer _timer;
  int _start = 0;
  var splashIndex = ['0', '1', '2', '3', '4', '5'];
  String url;

  // Future<void> setUserId() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt('userId', widget.model.user.id);
  //
  //   //print(lastAppVersion);
  // }
  // static Future<int> getUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (!prefs.containsKey('userId')) {
  //     return null;
  //   }
  //   final extractedUserData = prefs.getInt('userId');
  //
  //   return extractedUserData;
  // }
  // void getLocal()async{
  //   // AppStateModel model = AppStateModel();
  //   // WidgetsFlutterBinding.ensureInitialized();
  // await  model.getLocalData();
  //
  // }
  Future<void> addLastAppVersion() async {
    try {
      // FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final res = await FirebaseFirestore.instance
          .collection("lastAppVersion")
          .get()
          .then((value) {
        setState(() {
          lastAppVersion = value.docs.first.data()["lastAppVersion"];
        });
      });
    } catch (onError) {
      // by catch error method and print it this will  prevent our from crashing if found error in above future method
      print(onError);
      throw onError;
    }
  }

  @override
  void initState() {
    super.initState();

    apiProviderInt();
    AppStateModel();

    addLastAppVersion();
    //  getLocal();

    //splashIndex.shuffle();
    //startTimer();
  }

  File fileFromDocsDir(String filename) {
    //TODO Uncomment when using dynamic splash
    //String pathName = p.join(_appDocsDir.path, filename);
    //return File(pathName);
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  void apiProviderInt() async {
    await apiProvider.init();
    widget.model.fetchAllBlocks();
    widget.model.getCustomerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return ModelBinding(
      initialModel: GalleryOptions(
        themeMode: ThemeMode.system,
        customTextDirection: CustomTextDirection.localeBased,
        textScaleFactor: 1,
        locale: widget.model.appLocale,
        platform: defaultTargetPlatform,
      ),
      child: Builder(
        builder: (context) {
          //print(GalleryOptions.of(context).locale.languageCode);
          return

              /// authorize with word press
              ScopedModel<AppStateModel>(
                  model: widget.model,
                  child: MaterialApp(
                      localizationsDelegates: [
                        GlobalCupertinoLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        FormBuilderLocalizations.delegate,
                      ],
                      supportedLocales: GalleryOptions.supportedLocales,
                      locale: GalleryOptions.of(context).locale,
                      title: 'Marketly',
                      debugShowCheckedModeBanner: false,
                      themeMode: GalleryOptions.of(context).themeMode,
                      theme: GalleryOptions.of(context).locale == Locale('ar')
                          ? GalleryThemeData.lightArabicThemeData.copyWith(
                              platform: GalleryOptions.of(context).platform,
                            )
                          : GalleryThemeData.lightThemeData.copyWith(
                              platform: GalleryOptions.of(context).platform,
                            ),
                      darkTheme:
                          GalleryOptions.of(context).locale == Locale('ar')
                              ? GalleryThemeData.darkArabicThemeData.copyWith(
                                  platform: GalleryOptions.of(context).platform,
                                )
                              : GalleryThemeData.darkThemeData.copyWith(
                                  platform: GalleryOptions.of(context).platform,
                                ),
                      home: ScopedModelDescendant<AppStateModel>(
                          builder: (context, child, model) {
                        //  print('country codeeeeeeeeeeeeeeeeee ${widget.model.appLocale.countryCode}');
                        if (model.hasSeenIntro == null) {
                          return IntroScreen();
                        } else if (model.blocks != null && _start == 0) {
                          return model.blocks.user != null
                              ? UpgradeAlert(
                                  //messages: MyArabic(),
//countryCode: "EG",
                                  debugAlwaysUpgrade:
                                      lastAppVersion > appVersion
                                          ? true
                                          : false,
                                  canDismissDialog: appVersion == lastAppVersion
                                      ? true
                                      : false,
                                  //debugDisplayOnce: false,
                                  showIgnore: false,
                                  showLater: false,
                                  //minAppVersion: "2.13",
                                  onUpdate: () {
                                    _launchInBrowser(
                                        "https://play.google.com/store/apps/details?id=com.microwebapp.marketly");
                                    return true;
                                  },
                                  child: App())
                              : Login1();
                          //Register ();

                        } else {
                          return Material(
                              child: Scaffold(
                            body: AnnotatedRegion<SystemUiOverlayStyle>(
                              value: SystemUiOverlayStyle.dark,
                              child: Center(
                                child: Container(
                                    width: 200,
                                    child: Image.asset(
                                      'lib/assets/images/logo.png',
                                      fit: BoxFit.fitHeight,
                                    )),
                              ),
                            ),
                          ));

                          //For dinamic splash not used because issues in pathprovider in recent flutter update
                          return Material(
                            child: Stack(
                              children: [
                                Container(
                                    height: MediaQuery.of(context).size.height,
                                    child: Image(
                                        fit: BoxFit.fitHeight,
                                        image: NetworkToFileImage(
                                            url: '',
                                            file: fileFromDocsDir("splash" +
                                                splashIndex[0] +
                                                ".jpg"),
                                            debug: true))),
                                model.blocks != null
                                    ? Positioned(
                                        top: 20,
                                        right: 20,
                                        child: FlatButton(
                                          child: Text(
                                              'SKIP 0' + _start.toString()),
                                          onPressed: () => cancelTimer(),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          );
                        }
                      })));

          /// without autharize
          // ScopedModel<AppStateModel>(
          //   model: widget.model,
          //   child: MaterialApp(
          //       localizationsDelegates: [
          //         GlobalCupertinoLocalizations.delegate,
          //         GlobalMaterialLocalizations.delegate,
          //         GlobalWidgetsLocalizations.delegate,
          //       ],
          //       supportedLocales: GalleryOptions.supportedLocales,
          //       locale: GalleryOptions.of(context).locale,
          //       title: 'Marketly',
          //       debugShowCheckedModeBanner: false,
          //       themeMode: GalleryOptions.of(context).themeMode,
          //       theme: GalleryOptions.of(context).locale == Locale('ar')
          //           ? GalleryThemeData.lightArabicThemeData.copyWith(
          //         platform: GalleryOptions.of(context).platform,
          //       )
          //           : GalleryThemeData.lightThemeData.copyWith(
          //         platform: GalleryOptions.of(context).platform,
          //       ),
          //       darkTheme: GalleryOptions.of(context).locale == Locale('ar')
          //           ? GalleryThemeData.darkArabicThemeData.copyWith(
          //         platform: GalleryOptions.of(context).platform,
          //       )
          //           : GalleryThemeData.darkThemeData.copyWith(
          //         platform: GalleryOptions.of(context).platform,
          //       ),
          //       home: ScopedModelDescendant<AppStateModel>(
          //           builder: (context, child, model) {
          //             if (model.hasSeenIntro == null) {
          //               return IntroScreen();
          //             } else if (model.blocks != null && _start == 0) {
          //               return
          //                   UpgradeAlert(
          //
          //                       debugAlwaysUpgrade: lastAppVersion>appVersion ? true: false,
          //                       canDismissDialog: appVersion==lastAppVersion? true: false,
          //                       //debugDisplayOnce: false,
          //                       showIgnore: false,
          //                       showLater: false,
          //                       //minAppVersion: "2.13",
          //                       onUpdate: (){
          //                         _launchInBrowser("https://play.google.com/store/apps/details?id=com.microwebapp.marketly");
          //                         return true;
          //                       },
          //                       child: App());
          //
          //             } else {
          //               return Material(
          //                   child: Scaffold(
          //
          //                     body: AnnotatedRegion<SystemUiOverlayStyle>(
          //                       value: SystemUiOverlayStyle.dark,
          //                       child: Center(
          //                         child: Container(
          //                             width: 200,
          //                             child: Image.asset('lib/assets/images/logo.png', fit: BoxFit.fitHeight,)
          //                         ),
          //                       ),
          //                     ),
          //                   )
          //               );
          //
          //               //For dinamic splash not used because issues in pathprovider in recent flutter update
          //               return Material(
          //                 child: Stack(
          //                   children: [
          //                     Container(
          //                         height: MediaQuery.of(context).size.height,
          //                         child: Image(
          //                             fit: BoxFit.fitHeight,
          //                             image: NetworkToFileImage(
          //                                 url: '',
          //                                 file: fileFromDocsDir(
          //                                     "splash" + splashIndex[0] + ".jpg"),
          //                                 debug: true))),
          //                     model.blocks != null
          //                         ? Positioned(
          //                       top: 20,
          //                       right: 20,
          //                       child: FlatButton(
          //                         child: Text('SKIP 0' + _start.toString()),
          //                         onPressed: () => cancelTimer(),
          //                       ),
          //                     )
          //                         : Container()
          //                   ],
          //                 ),
          //               );
          //             }
          //           })));
        },
      ),
    );
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            cancelTimer();
          } else {
            _start = _start - 1;
          }
          print(_start);
        },
      ),
    );
  }

  void cancelTimer() {
    _timer.cancel();
    setState(() {
      _start = 0;
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

const List<Locale> supportedLocales = <Locale>[
  Locale('en'),
  Locale('af'),
  Locale('am'),
  Locale('ar'),
  Locale('ar', 'EG'),
  Locale('ar', 'JO'),
  Locale('ar', 'MA'),
  Locale('ar', 'SA'),
  Locale('as'),
  Locale('az'),
  Locale('be'),
  Locale('bg'),
  Locale('bn'),
  Locale('bs'),
  Locale('ca'),
  Locale('cs'),
  Locale('da'),
  Locale('de'),
  Locale('de', 'AT'),
  Locale('de', 'CH'),
  Locale('el'),
  Locale('en', 'AU'),
  Locale('en', 'CA'),
  Locale('en', 'GB'),
  Locale('en', 'IE'),
  Locale('en', 'IN'),
  Locale('en', 'NZ'),
  Locale('en', 'SG'),
  Locale('en', 'ZA'),
  Locale('es'),
  Locale('es', '419'),
  Locale('es', 'AR'),
  Locale('es', 'BO'),
  Locale('es', 'CL'),
  Locale('es', 'CO'),
  Locale('es', 'CR'),
  Locale('es', 'DO'),
  Locale('es', 'EC'),
  Locale('es', 'GT'),
  Locale('es', 'HN'),
  Locale('es', 'MX'),
  Locale('es', 'NI'),
  Locale('es', 'PA'),
  Locale('es', 'PE'),
  Locale('es', 'PR'),
  Locale('es', 'PY'),
  Locale('es', 'SV'),
  Locale('es', 'US'),
  Locale('es', 'UY'),
  Locale('es', 'VE'),
  Locale('et'),
  Locale('eu'),
  Locale('fa'),
  Locale('fi'),
  Locale('fil'),
  Locale('fr'),
  Locale('fr', 'CA'),
  Locale('fr', 'CH'),
  Locale('gl'),
  Locale('gsw'),
  Locale('gu'),
  Locale('he'),
  Locale('hi'),
  Locale('hr'),
  Locale('hu'),
  Locale('hy'),
  Locale('id'),
  Locale('is'),
  Locale('it'),
  Locale('ja'),
  Locale('ka'),
  Locale('kk'),
  Locale('km'),
  Locale('kn'),
  Locale('ko'),
  Locale('ky'),
  Locale('lo'),
  Locale('lt'),
  Locale('lv'),
  Locale('mk'),
  Locale('ml'),
  Locale('mn'),
  Locale('mr'),
  Locale('ms'),
  Locale('my'),
  Locale('nb'),
  Locale('ne'),
  Locale('nl'),
  Locale('or'),
  Locale('pa'),
  Locale('pl'),
  Locale('pt'),
  Locale('pt', 'BR'),
  Locale('pt', 'PT'),
  Locale('ro'),
  Locale('ru'),
  Locale('si'),
  Locale('sk'),
  Locale('sl'),
  Locale('sq'),
  Locale('sr'),
  Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
  Locale('sv'),
  Locale('sw'),
  Locale('ta'),
  Locale('te'),
  Locale('th'),
  Locale('tl'),
  Locale('tr'),
  Locale('uk'),
  Locale('ur'),
  Locale('uz'),
  Locale('vi'),
  Locale('zh'),
  Locale('zh', 'CN'),
  Locale('zh', 'HK'),
  Locale('zh', 'TW'),
  Locale('zu')
];

class RestartWidget extends StatefulWidget {
  RestartWidget({this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();
  bool timerIsFinish = false;

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        ' apppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp was restartttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt');

    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

// class MyUpgraderMessages extends UpgraderMessages {
//   @override
//   String get buttonTitleIgnore => 'My Ignore';
// }
class MyArabic extends UpgraderMessages {
  /// Override the message function to provide custom language localization.
  @override
  String message(UpgraderMessage messageKey) {
    if (languageCode == 'ar') {
      switch (messageKey) {
        case UpgraderMessage.body:
          return 'متاح نسخه جديد من ماركتلي الان';
        case UpgraderMessage.buttonTitleIgnore:
          return 'es Ignore';
        case UpgraderMessage.buttonTitleLater:
          return 'es Later';
        case UpgraderMessage.buttonTitleUpdate:
          return 'حدث الان';
        case UpgraderMessage.prompt:
          return 'es Want to update?';
        case UpgraderMessage.title:
          return 'تحديث';
      }
    }
    // Messages that are not provided above can still use the default values.
    return super.message(messageKey);
  }
}

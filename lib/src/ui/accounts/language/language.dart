

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './../../../models/app_state_model.dart';
import './../../../models/blocks_model.dart';
import './../../../resources/api_provider.dart';
import '../../../data/gallery_options.dart';
import 'package:app/main.dart';
class LanguagePage extends StatefulWidget {
  LanguagePage(
      {Key key})
      : super(key: key);
  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {


  final apiProvider = ApiProvider();
  AppStateModel appStateModel = AppStateModel();
  String oldLang ;
  bool isPressed= false;
  bool canBack =true;
  // void timer() async {
  //   // setState(() {
  //   // //  timerIsFinish = true;
  //   // });
  //
  //  await Future.delayed(Duration(milliseconds: 5000), (
  //
  //       ) {
  //     RestartWidget.restartApp(context);
  //
  //     // setState(() {
  //     //  // timerIsFinish = false;
  //     // });
  //    //  runApp(MyApp());
  //   });
  // }
  @override
  void initState() {
    super.initState();
    oldLang = appStateModel.blocks.localeText.language;
  //  canBack = oldLang== appStateModel.blocks.localeText.language;
  }

  @override
  Widget build(BuildContext context) {
   //canBack = oldLang== appStateModel.blocks.localeText.language;
    return ScopedModelDescendant<AppStateModel>(
        builder: (context, child, model) {
          return Scaffold(
              appBar: AppBar(
                title: Text(
                  appStateModel.blocks.localeText.language,
                ),
                automaticallyImplyLeading: false,
                leading: Padding(
                padding: const EdgeInsets.all(8.0),
          child: IconButton(
          icon:!isPressed?
          const Icon(Icons.arrow_back): canBack? CircularProgressIndicator():const Icon(Icons.arrow_back),
            //
            onPressed: (){
              Navigator.pop(context);

            },
              ),),),
              body: model.blocks?.languages != null ?
              buildLanguageItems(model.blocks.languages) : Container());
        }
    );
  }

  Widget buildLanguageItems(List<Language> languages) {
    final options = GalleryOptions.of(context);
    return
      !isPressed?
      ListView.builder(
        itemCount: languages.length,
        itemBuilder: (BuildContext context, int index) {
          return
           Column(
            children: <Widget>[
              new ListTile(
                trailing: Radio<String>(

                  value: languages[index].code,
                  groupValue: apiProvider.filter['lan'],
                  onChanged: (value) async {

                 await  appStateModel.updateLanguage(languages[index].code);
                    GalleryOptions.update(
                      context,
                      options.copyWith(locale: Locale(languages[index].code),
                    ));
                 setState(() {
                   isPressed=true;
                   print(' when select lang changeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee and ispresed $isPressed');
                   //canBack= oldLang== appStateModel.blocks.localeText.language;

                 });
                 await Future.delayed(Duration(milliseconds: 3400), (){
                   setState(() {
                     canBack=false;
                     isPressed=false;
                   });
                 });

                  }),
                title: Text(languages[index].nativeName),
                onTap: () async {
                  print(' when select lang changeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee and ispresed $isPressed');
                  //canBack= oldLang== appStateModel.blocks.localeText.language;
                  await   appStateModel.updateLanguage(languages[index].code);
                  GalleryOptions.update(
                    context,
                    options.copyWith(locale: Locale(languages[index].code),
                  ));
                  setState(() {
                    isPressed=true;
                    print(' when select lang changeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee and ispresed $isPressed');
                    //canBack= oldLang== appStateModel.blocks.localeText.language;

                  });
                  await Future.delayed(Duration(milliseconds: 2000), (){
                    setState(() {
                      canBack= false;
                      isPressed=false;
                    });
                  });
                  // RestartWidget.restartApp(context);
                  // setState(() {
                  // // updateLang= appStateModel.appLocale.languageCode;
                  // });
                },
              ),
              Divider(
                height: 0,
              )
             ],);


        }):Center(
        child:CircularProgressIndicator() ,
      );
  }
}






// import 'package:flutter/material.dart';
// import 'package:scoped_model/scoped_model.dart';
//
// import './../../../models/app_state_model.dart';
// import './../../../models/blocks_model.dart';
// import './../../../resources/api_provider.dart';
// import '../../../data/gallery_options.dart';
// import 'package:app/main.dart';
// class LanguagePage extends StatefulWidget {
//   LanguagePage(
//       {Key key})
//       : super(key: key);
//   @override
//   _LanguagePageState createState() => _LanguagePageState();
// }
//
// class _LanguagePageState extends State<LanguagePage> {
//
//   final apiProvider = ApiProvider();
//   AppStateModel appStateModel = AppStateModel();
//
//   String currentLang;
//   String updateLang ;
//   bool timerIsFinish=false;
//
//   void timer() async {
//     setState(() {
//       timerIsFinish = true;
//     });
//
//     await Future.delayed(Duration(milliseconds: 5000), (
//
//         ) {
//
//       setState(() {
//         timerIsFinish = false;
//       });
//        runApp(MyApp());
//     });
//   }
//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       currentLang= appStateModel.appLocale.languageCode;
//       updateLang = currentLang;
//     });
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//         appBar: AppBar(
//
//           title: Text(
//             appStateModel.blocks.localeText.language,
//           ),
//           automaticallyImplyLeading: false,
//           leading: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child:timerIsFinish?
//                 Container(width: 20,height: 20,
//                 child: CircularProgressIndicator(),):
//             IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: ()async  {
//                 var canBack = updateLang==currentLang;
//                 print(' can backkkkkkkkkkkkkkkkkkkkkkkkkkk $canBack');
//            //  await
// return
//                 canBack
//                     ?  Navigator.pop(context)
//                     :
//                 timer();
//                 RestartWidget.restartApp(context);
//                 // Navigator.of(context).push(MaterialPageRoute(
//                 //     builder: (context) =>
//                 //         Material(child: MyApp())));
//               },
//             ),
//           ),
//         ),
//         body: ScopedModelDescendant<AppStateModel>(
//             builder: (context, child, model) {
//               if (model.blocks?.languages != null) {
//                 return buildLanguageItems(model.blocks.languages);
//               } else
//                 return Container();
//             }));
//   }
//
//   Widget buildLanguageItems(List<Language> languages) {
//     final options = GalleryOptions.of(context);
//     return ListView.builder(
//         itemCount: languages.length,
//         itemBuilder: (BuildContext ctxt, int index) {
//
//           );
//         });
//   }
// }

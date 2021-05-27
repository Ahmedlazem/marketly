import 'package:flutter/material.dart';
import './../../../../models/app_state_model.dart';
import './../../../../models/register_model.dart';
import './../../../../ui/widgets/buttons/button.dart';
import '../../../color_override.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/main.dart';
import 'package:app/src/app.dart';
class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
 // final _scaffoldKey = GlobalKey<ScaffoldState>();
  final appStateModel = AppStateModel();
  RegisterModel _register = RegisterModel();
  bool _obscureText = true;
  var isLoading = false;
  final _formKey = GlobalKey<FormState>();
  //DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("Users");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(),
      body:
          // Builder(
          //   builder: (context) => ListView(
          //       shrinkWrap: true,
          //       children: [
          //         SizedBox(height: 15.0),
          //         Container(
          //           height: MediaQuery.of(context).size.height,
          //          // width: double.infinity,
          //           margin: const EdgeInsets.only(left: 16.0, right: 16.0),
          Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              height: 850,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.start,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 60,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 120, maxWidth: 220),
                      child: Image.asset(
                        'lib/assets/images/logo.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  PrimaryColorOverride(
                    child: TextFormField(
                      onSaved: (val) =>
                          setState(() => _register.firstName = val),
                      validator: (value) {
                        if (value.isEmpty) {
                          return appStateModel
                              .blocks.localeText.pleaseEnterFirstName;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: appStateModel.blocks.localeText.firstName),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  PrimaryColorOverride(
                    child: TextFormField(
                      onSaved: (val) =>
                          setState(() => _register.lastName = val),
                      validator: (value) {
                        if (value.isEmpty) {
                          return appStateModel
                              .blocks.localeText.pleaseEnterLastName;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: appStateModel.blocks.localeText.lastName),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),

                  /// phone nomber

                  PrimaryColorOverride(
                    child: TextFormField(
                      onSaved: (val) =>
                          setState(() => _register.phoneNumber = val),
                      validator: (value) {
                        if (value.isEmpty ||
                            value.length < 11 ||
                            value.length > 11) {
                          return appStateModel
                              .blocks.localeText.pleaseEnterPhoneNumber;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText:
                              appStateModel.blocks.localeText.phoneNumber),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  PrimaryColorOverride(
                    child: TextFormField(
                      onSaved: (val) => setState(() => _register.email = val),
                      validator: (value) {
                        if (value.isEmpty) {
                          return appStateModel
                              .blocks.localeText.pleaseEnterValidEmail;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: appStateModel.blocks.localeText.email),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  PrimaryColorOverride(
                    child: TextFormField(
                      obscureText: _obscureText,
                      onSaved: (val) =>
                          setState(() => _register.password = val),
                      validator: (value) {
                        if (value.isEmpty) {
                          return appStateModel
                              .blocks.localeText.pleaseEnterPassword;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              }),
                          labelText: appStateModel.blocks.localeText.password),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  SizedBox(height: 30.0),
                  AccentButton(
                    onPressed: () => _submit(context),
                    text: appStateModel.blocks.localeText.signIn,
                    showProgress: isLoading,
                  ),
                  SizedBox(height: 30.0),
                  FlatButton(
                      padding: EdgeInsets.all(16.0),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              appStateModel
                                  .blocks.localeText.alreadyHaveAnAccount,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(fontSize: 15, color: Colors.grey)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(appStateModel.blocks.localeText.signIn,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(
                                        color: Theme.of(context).accentColor)),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    //         ]),
    //   )
    // );
  }

  Future _submit(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
      // FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      // await firebaseAuth
      //     .createUserWithEmailAndPassword(
      //         email: _register.email, password: _register.password)
      //     .then((result) async {
      //   await FirebaseFirestore.instance
      //       .collection('newUsers')
      //       .doc(result.user.uid)
      //       .set({
      //     'firstName': _register.firstName,
      //     'lastName': _register.lastName,
      //     'phone': _register.phoneNumber,
      //     // 'passWord': _register.password,
      //     'email': _register.email,
      //     'creat@': DateTime.now().toIso8601String(),
      //   });
      // }).catchError((err) {
      //   showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return AlertDialog(
      //           title: Text("Error"),
      //           content: Text(err.message),
      //           actions: [
      //             FlatButton(
      //               child: Text("Ok"),
      //               onPressed: () {
      //                 Navigator.of(context).pop();
      //               },
      //             )
      //           ],
      //         );
      //       });
      // });
      bool status = await appStateModel.register(_register.toJson(), context);
      setState(() {
        isLoading = false;
      });
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(builder: (c) => App()),
      //         (route) => false);

      if (status) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (c) => App()),
                (route) => false);
        // Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => App(),maintainState: false));
        //RestartWidget.restartApp(context);
        // Navigator.popUntil(
        //     context, ModalRoute.withName(Navigator.defaultRouteName));
      }
    }
  }
}

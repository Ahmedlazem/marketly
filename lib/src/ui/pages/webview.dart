import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config.dart';
import '../../resources/api_provider.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;
  const   WebViewPage({Key key, this.url, this.title}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState(url: url);
}

class _WebViewPageState extends State<WebViewPage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final String url;
  bool _isLoadingPage = true;
  final config = Config();
  final cookieManager = WebviewCookieManager();
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  bool injectCookies = false;


  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  WebViewController controller;
  StreamSubscription<double> _onProgressChanged;
  double progress = 0.0;

  @override
  void initState() {

    _setCookies();
   // flutterWebViewPlugin.getCookies();
    _seCookies();
   flutterWebViewPlugin.close();

    _onProgressChanged =
        flutterWebViewPlugin.onProgressChanged.listen((double prog) {
      if (mounted) {
        setState(() {
          progress = prog;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
// TODO: implement dispose
    _onProgressChanged.cancel();
    flutterWebViewPlugin.dispose();
    // controller.dispose();
    super.dispose();
  }

  _WebViewPageState({this.url});

  @override
  Widget build(BuildContext context) {


    return Container(
      child: Column(
        children: [
          progress < 1.0
              ? Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      Container(),
                      Expanded(
                        child: Center(
                          child: Container(
                            child: SpinKitRing(
                              color: Colors.blue,
                              size: 50.0,
                              lineWidth: 4,
                            ),

                          ),
                        ),
                      )
                    ],
                  ),
                )
              : Center(),
          Expanded(
            child: WebviewScaffold(
              key: scaffoldKey,
              url: url,
              appBar: AppBar(
                title: widget.title != null ? Text(widget.title) : AppBar(),
                automaticallyImplyLeading: false,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () async {
                      var canBack = await flutterWebViewPlugin.canGoBack();
                     // print(' can backkkkkkkkkkkkkkkkkkkkkkkkkkk $canBack');

                      canBack
                          ? flutterWebViewPlugin.goBack()
                          : Navigator.pop(context);
                    },
                  ),
                ),
              ),
              withJavascript: true,
              primary: true,
              withLocalStorage: true,

              withZoom: true,
              appCacheEnabled: true,
              withLocalUrl: true,
              withOverviewMode: true,
              geolocationEnabled: true,
enableAppScheme: true,
              ignoreSSLErrors: true,

              allowFileURLs: true,

            ),
          ),
        ],
      ),
    );
  }

  _setCookies() async {
    Uri uri = Uri.parse(config.url);
    String domain = uri.host;
    print('Domain: ' + domain);
    ApiProvider apiProvider = ApiProvider();

    List<Cookie> cookies = apiProvider.generateCookies();
    apiProvider.cookieList.forEach((element) async {
      await flutterWebViewPlugin.getCookies(
        // Cookie(element.name, element.value)..domain = domain
        // //..expires = DateTime.now().add(Duration(days: 10))
        // //..httpOnly = true
      );
    });
    setState(() {
      injectCookies = true;
    });
  }
  _seCookies() async {
    Uri uri = Uri.parse(config.url);
    String domain = uri.host;
    print('Domain: ' + domain);
    ApiProvider apiProvider = ApiProvider();

    List<Cookie> cookies = apiProvider.generateCookies();
    apiProvider.cookieList.forEach((element) async {
      await cookieManager.setCookies([
        Cookie(element.name, element.value)..domain = domain
        //..expires = DateTime.now().add(Duration(days: 10))
        //..httpOnly = true
      ]);
    });
    setState(() {
      injectCookies = true;
    });
  }
}

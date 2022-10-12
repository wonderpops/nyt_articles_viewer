import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyt_articles_viewer/blocs/bloc/articles_bloc.dart';
import 'package:nyt_articles_viewer/main_layout.dart';
import 'package:nyt_articles_viewer/screens/home_screen/home_screen.dart';
import 'package:uni_links/uni_links.dart';

bool _initialURILinkHandled = false;

void main() {
  ArticlesBloc articlesBloc = ArticlesBloc();
  runApp(
    BlocProvider(
      create: (context) => articlesBloc,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Timer newArticleChecker;
  @override
  void initState() {
    ArticlesBloc articlesBloc = BlocProvider.of<ArticlesBloc>(context);
    newArticleChecker = Timer.periodic(const Duration(seconds: 60),
        (_) => articlesBloc.add(CheckNewArticlesEvent()));
    super.initState();
  }

  @override
  void dispose() {
    newArticleChecker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The NYT top stories',
      theme: ThemeData(
        colorSchemeSeed: Color.fromARGB(255, 89, 110, 170),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Color.fromARGB(255, 89, 110, 170),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const MainLayoutWidget(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription? _sub;

  @override
  void initState() {
    initUniLinks();
    super.initState();
  }

  Future<void> initUniLinks() async {
    // ... check initialLink

    // Attach a listener to the stream
    _sub = linkStream.listen((String? link) {
      print('kist');
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });

    // NOTE: Don't forget to call _sub.cancel() in dispose()
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                title: const Text("Initial Link"),
                subtitle: Text('asfasf'),
              ),
            ],
          ),
        )));
  }
}

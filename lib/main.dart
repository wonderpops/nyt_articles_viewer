import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:nyt_articles_viewer/blocs/bloc/articles_bloc.dart';
import 'package:nyt_articles_viewer/main_layout.dart';
import 'package:nyt_articles_viewer/screens/home_screen/home_screen.dart';
import 'package:uni_links/uni_links.dart';

import 'models/article_preview_model.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

bool _initialURILinkHandled = false;

void main() async {
  ArticlesBloc articlesBloc = ArticlesBloc();
  WidgetsFlutterBinding.ensureInitialized();
  Directory directory = await pathProvider.getApplicationDocumentsDirectory();
  Hive
    ..init(directory.path)
    ..registerAdapter(ArticleAdapter());

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
  StreamSubscription? _sub;

  @override
  void initState() {
    initUniLinks();
    ArticlesBloc articlesBloc = BlocProvider.of<ArticlesBloc>(context);
    newArticleChecker = Timer.periodic(const Duration(seconds: 60),
        (_) => articlesBloc.add(CheckNewArticlesEvent()));
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    newArticleChecker.cancel();
    super.dispose();
  }

  Future<void> initUniLinks() async {
    // ... check initialLink

    // Attach a listener to the stream
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        ArticlesBloc articlesBloc = BlocProvider.of<ArticlesBloc>(context);
        articlesBloc.add(ArticleViewEvent(articleUrl: link));
      }
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });

    // NOTE: Don't forget to call _sub.cancel() in dispose()
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

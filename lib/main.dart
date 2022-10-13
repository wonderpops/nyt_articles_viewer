import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:nyt_articles_viewer/blocs/bloc/articles_bloc.dart';
import 'package:nyt_articles_viewer/main_layout.dart';
import 'package:nyt_articles_viewer/screens/home_screen/home_screen.dart';
import 'package:uni_links/uni_links.dart';

import 'models/article_preview_model.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

import 'screens/article_screen/article_screen.dart';

bool _initialUriIsHandled = false;

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
      child: const MyApp(),
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

  Uri? _initialUri;
  Uri? _latestUri;
  Object? _err;

  StreamSubscription? _sub;

  final _scaffoldKey = GlobalKey();

  @override
  void initState() {
    _handleIncomingLinks();
    _handleInitialUri();
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

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      // It will handle app links while the app is already started - be it in
      // the foreground or in the background.
      _sub = uriLinkStream.listen((Uri? uri) {
        print('got uri: $uri');
        ArticlesBloc articlesBloc = BlocProvider.of<ArticlesBloc>(context);
        articlesBloc.add(ArticleViewEvent(articleUrl: uri.toString()));
      }, onError: (Object err) {
        print('got err: $err');
      });
    }
  }

  Future<void> _handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final uri = await getInitialUri();

        if (uri == null) {
          print('no initial uri');
        } else {
          print('got initial uri: $uri');
          ArticlesBloc articlesBloc = BlocProvider.of<ArticlesBloc>(context);
          articlesBloc.add(ArticleViewEvent(articleUrl: uri.toString()));
        }
        if (!mounted) return;
        setState(() => _initialUri = uri);
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('falied to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri');
        setState(() => _err = err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The NYT top stories',
      theme: ThemeData(
        colorSchemeSeed: Color.fromARGB(255, 11, 51, 163),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Color.fromARGB(255, 179, 170, 218),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Builder(builder: (context) {
        if (_initialUri != null) {
          return BlocConsumer<ArticlesBloc, ArticlesState>(
            listener: (context, state) {
              if (state is ArticleViewState) {
                Navigator.of(context)
                    .push(PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ArticleScreenWidget(),
                  transitionDuration: const Duration(milliseconds: 300),
                  transitionsBuilder: (_, a, __, c) =>
                      FadeTransition(opacity: a, child: c),
                ))
                    .then((value) {
                  _initialUri = null;
                  setState(() {});
                });
              }
            },
            builder: (context, state) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            },
          );
        } else {
          return const MainLayoutWidget();
        }
      }),
    );
  }
}

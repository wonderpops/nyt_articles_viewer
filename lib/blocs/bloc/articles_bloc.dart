import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:nyt_articles_viewer/domain/nyt_api_client.dart';
import 'package:nyt_articles_viewer/models/article_preview_model.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:http/http.dart' as http;

part 'articles_event.dart';
part 'articles_state.dart';

class ArticlesBloc extends Bloc<ArticlesEvent, ArticlesState> {
  final NytApiClient nytApiClient = NytApiClient();
  List<ArticlePreview> articles = [];

  List compareArticlesLists(List<ArticlePreview> storedArticles,
      List<ArticlePreview> receivedArticles) {
    bool wasMerged = false;
    if (receivedArticles.isNotEmpty) {
      for (var i = 0; i < receivedArticles.length; i++) {
        bool isInsertNeeded = true;
        for (var j = 0; j < storedArticles.length; j++) {
          // print('$i - ${receivedArticles[i].url} || ${articles[j].url}');
          if (receivedArticles[i].url == storedArticles[j].url) {
            isInsertNeeded = false;
            break;
          }
        }

        if (isInsertNeeded) {
          wasMerged = true;

          storedArticles.insert(i, receivedArticles[i]);
        }
      }

      if (storedArticles.length > 40) {
        storedArticles.removeRange(40, storedArticles.length);
      }
    }
    return [wasMerged, storedArticles];
  }

  ArticlesBloc() : super(ArticlesInitial()) {
    on<ArticlesLoadEvent>(onArticlesLoading);
    on<ArticleViewEvent>(onArticleView);
    on<CheckNewArticlesEvent>(onCheckNewArticles);
  }
  onArticlesLoading(
      ArticlesLoadEvent event, Emitter<ArticlesState> emit) async {
    emit(ArticlesLoadingState());
    List<ArticlePreview> receivedArticles = await nytApiClient.getArticles();
    var box = await Hive.openBox<ArticlePreview>('articlesBox');

    List<ArticlePreview> storedArticles = box.values.toList();

    List compareResults =
        compareArticlesLists(storedArticles, receivedArticles);

    if (compareResults[0]) {
      await box.clear();

      for (int i = 0; i < compareResults[1].length; i++) {
        await box.add(compareResults[1][i]);
      }
    }

    articles = compareResults[1];

    emit(ArticlesLoadedState(articles: storedArticles));
  }

  onArticleView(ArticleViewEvent event, Emitter<ArticlesState> emit) async {
    ArticlePreview article =
        articles.firstWhere((a) => a.url == event.articleUrl);
    emit(ArticleViewState(
      articleUrl: event.articleUrl,
      backgroundImage: Image.network(article.multimediaUrl),
    ));
  }

  onCheckNewArticles(
      CheckNewArticlesEvent event, Emitter<ArticlesState> emit) async {
    print('Cheking new articles...');
    List<ArticlePreview> newArticles = await nytApiClient.getArticles();
    var box = await Hive.openBox<ArticlePreview>('articlesBox');

    List<ArticlePreview> storedArticles = box.values.toList();

    List compareResults = compareArticlesLists(storedArticles, newArticles);

    if (compareResults[0]) {
      await box.clear();

      for (int i = 0; i < compareResults[1].length; i++) {
        await box.add(compareResults[1][i]);
      }
    }

    articles = compareResults[1];

    emit(NewArticlesLoadedState());
  }
}

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:nyt_articles_viewer/domain/nyt_api_client.dart';
import 'package:nyt_articles_viewer/models/article_preview_model.dart';

part 'articles_event.dart';
part 'articles_state.dart';

class ArticlesBloc extends Bloc<ArticlesEvent, ArticlesState> {
  final NytApiClient nytApiClient = NytApiClient();
  List<ArticlePreview> articles = [];

  ArticlesBloc() : super(ArticlesInitial()) {
    on<ArticlesLoadEvent>(onArticlesLoading);
    on<ArticleViewEvent>(onArticleView);
    on<CheckNewArticlesEvent>(onCheckNewArticles);
  }
  onArticlesLoading(
      ArticlesLoadEvent event, Emitter<ArticlesState> emit) async {
    emit(ArticlesLoadingState());
    List<ArticlePreview> a = await nytApiClient.getArticles();
    articles = a;
    inspect(articles);
    emit(ArticlesLoadedState(articles: articles));
  }

  onArticleView(ArticleViewEvent event, Emitter<ArticlesState> emit) async {
    ArticlePreview article =
        articles.firstWhere((a) => a.url == event.articleUrl);
    emit(ArticleViewState(
      articleUrl: event.articleUrl,
      backgroundImage: Image.network(article.multimedia.first.url),
    ));
  }

  onCheckNewArticles(
      CheckNewArticlesEvent event, Emitter<ArticlesState> emit) async {
    print('Cheking new articles...');
    List<ArticlePreview> newArticles = await nytApiClient.getArticles();

    // print('${newArticles.first.url} || ${articles.first.url}');

    // print('${newArticles.length} ^^ ${articles.length}');

    for (var i = 0; i < newArticles.length; i++) {
      bool isInsertNeeded = true;
      for (var j = 0; j < articles.length; j++) {
        // print('${newArticles[i].url} || ${articles[j].url}');
        if (newArticles[i].url == articles[j].url) {
          isInsertNeeded = false;
        }
      }
      if (isInsertNeeded) {
        print('Was inserted new article in position $i');
        articles.insert(i, newArticles[i]);
      }
    }

    if (articles.length > 40) {
      articles.removeRange(40, articles.length);
    }

    emit(NewArticlesLoadedState());
  }
}

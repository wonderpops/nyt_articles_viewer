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
  }
  onArticlesLoading(
      ArticlesLoadEvent event, Emitter<ArticlesState> emit) async {
    emit(ArticlesLoadingState());
    articles = await nytApiClient.getArticles();
    // inspect(articles);
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
}

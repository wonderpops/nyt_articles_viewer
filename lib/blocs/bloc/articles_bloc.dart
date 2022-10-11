import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nyt_articles_viewer/domain/nyt_api_client.dart';
import 'package:nyt_articles_viewer/models/article_model.dart';

part 'articles_event.dart';
part 'articles_state.dart';

class ArticlesBloc extends Bloc<ArticlesEvent, ArticlesState> {
  final NytApiClient nytApiClient = NytApiClient();

  ArticlesBloc() : super(ArticlesInitial()) {
    on<ArticlesLoadEvent>(onArticlesLoading);
  }
  onArticlesLoading(
      ArticlesLoadEvent event, Emitter<ArticlesState> emit) async {
    emit(ArticlesLoadingState());
    List<Article> articles = await nytApiClient.getArticles();
    inspect(articles);
    emit(ArticlesLoadedState(articles: articles));
  }
}

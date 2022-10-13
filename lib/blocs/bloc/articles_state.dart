part of 'articles_bloc.dart';

@immutable
abstract class ArticlesState {}

class ArticlesInitial extends ArticlesState {}

class ArticlesLoadingState extends ArticlesState {}

class ArticlesLoadedState extends ArticlesState {
  final List<ArticlePreview> articles;
  ArticlesLoadedState({required this.articles});
}

class ArticleViewState extends ArticlesState {
  final String articleUrl;
  final String? backgroundImageUrl;
  ArticleViewState({required this.articleUrl, this.backgroundImageUrl});
}

class NewArticlesLoadedState extends ArticlesState {}

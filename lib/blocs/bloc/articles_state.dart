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
  final Image? backgroundImage;
  ArticleViewState({required this.articleUrl, required this.backgroundImage});
}

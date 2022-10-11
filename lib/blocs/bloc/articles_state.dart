part of 'articles_bloc.dart';

@immutable
abstract class ArticlesState {}

class ArticlesInitial extends ArticlesState {}

class ArticlesLoadingState extends ArticlesState {}

class ArticlesLoadedState extends ArticlesState {
  final List<Article> articles;
  ArticlesLoadedState({required this.articles});
}

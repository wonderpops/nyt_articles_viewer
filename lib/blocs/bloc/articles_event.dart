part of 'articles_bloc.dart';

@immutable
abstract class ArticlesEvent {}

class ArticlesLoadEvent extends ArticlesEvent {}

class ArticleViewEvent extends ArticlesEvent {
  final String articleUrl;

  ArticleViewEvent({required this.articleUrl});
}

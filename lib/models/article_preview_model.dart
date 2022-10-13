import 'package:hive/hive.dart';

part 'article_preview_model.g.dart';

@HiveType(typeId: 0, adapterName: 'ArticleAdapter')
class ArticlePreview {
  @HiveField(0)
  final String section;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String abstract;

  @HiveField(3)
  final String url;

  @HiveField(4)
  final String byline;

  @HiveField(5)
  final String createdDate;

  @HiveField(6)
  final String multimediaUrl;

  @HiveField(7)
  final String uri;

  ArticlePreview(
      {required this.section,
      required this.title,
      required this.abstract,
      required this.url,
      required this.byline,
      required this.createdDate,
      required this.multimediaUrl,
      required this.uri});

  ArticlePreview.fromJson(Map<String, dynamic> json)
      : section = json['section'],
        title = json['title'],
        abstract = json['abstract'],
        url = json['url'],
        byline = json['byline'],
        createdDate = json['created_date'],
        multimediaUrl = json['multimedia'][0]['url'],
        uri = json['uri'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['section'] = section;
    data['title'] = title;
    data['abstract'] = abstract;
    data['url'] = url;

    data['byline'] = byline;

    data['created_date'] = createdDate;

    data['multimedia'][0]['url'] = multimediaUrl;

    return data;
  }
}

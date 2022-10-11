import 'dart:developer';

import 'package:nyt_articles_viewer/domain/api_key.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:nyt_articles_viewer/models/article_model.dart';

class NytApiClient {
  final String _apiKey = nytApiKey;
  final _client = http.Client();
  final String _host = 'https://api.nytimes.com/svc/topstories/v2/';

  Future<List<Article>> getArticles({String section = 'home'}) async {
    final url = Uri.parse('$_host/$section.json?api-key=$_apiKey');
    final response =
        await _client.get(url, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      // inspect(response);
      final json = convert.jsonDecode(response.body) as Map;
      // inspect(json);
      List<Article> articles = [];
      for (var i = 0; i < json['results'].length; i++) {
        articles.add(Article.fromJson(json['results'][i]));
      }
      return articles;
    } else {
      throw Exception('Error when loading questions');
    }
  }
}

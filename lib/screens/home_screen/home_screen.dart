import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nyt_articles_viewer/blocs/bloc/articles_bloc.dart';

import '../../models/article_model.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  late ArticlesBloc articlesBloc;
  late PageController pageController;

  @override
  void initState() {
    articlesBloc = BlocProvider.of<ArticlesBloc>(context);
    articlesBloc.add(ArticlesLoadEvent());
    pageController = PageController();
    super.initState();
  }

  jumpToPage(pageIndex) {
    pageController.jumpToPage(pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NYT Top Stories'),
          backgroundColor: colorScheme.primaryContainer,
          automaticallyImplyLeading: false,
        ),
        extendBody: true,
        body: BlocBuilder<ArticlesBloc, ArticlesState>(
          builder: (context, state) {
            switch (state.runtimeType) {
              case ArticlesLoadedState:
                ArticlesLoadedState articlesLoadedState =
                    articlesBloc.state as ArticlesLoadedState;
                List<Article> articles = articlesLoadedState.articles;
                int maxArticlesOnPageCount = 5;
                return PageView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: pageController,
                    itemCount:
                        (articles.length / maxArticlesOnPageCount).ceil(),
                    itemBuilder: (context, page) {
                      List<Article> pageArticles;
                      if ((page + 1) * maxArticlesOnPageCount <
                          articles.length) {
                        pageArticles = articles
                            .getRange(
                              page * maxArticlesOnPageCount,
                              (page + 1) * maxArticlesOnPageCount,
                            )
                            .toList();
                      } else {
                        pageArticles = articles
                            .skip(page * maxArticlesOnPageCount)
                            .toList();
                      }

                      return ListView(
                        children: pageArticles
                                .map<Widget>((article) =>
                                    _ArticlePreviewWidget(article: article))
                                .toList() +
                            [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Opacity(
                                      opacity: page == 0 ? 0 : 1,
                                      child: TextButton(
                                          onPressed: () {
                                            if (page != 0) {
                                              jumpToPage(page - 1);
                                            }
                                          },
                                          child: const Text('Previous page')),
                                    ),
                                    Text(
                                        '${page + 1} of ${(articles.length / maxArticlesOnPageCount).ceil()}'),
                                    Opacity(
                                      opacity: page ==
                                              (articles.length /
                                                          maxArticlesOnPageCount)
                                                      .ceil() -
                                                  1
                                          ? 0
                                          : 1,
                                      child: TextButton(
                                          onPressed: () {
                                            if (page !=
                                                (articles.length /
                                                            maxArticlesOnPageCount)
                                                        .ceil() -
                                                    1) {
                                              jumpToPage(page + 1);
                                            }
                                          },
                                          child: const Text('Next page')),
                                    ),
                                  ],
                                ),
                              )
                            ],
                      );
                    });
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}

class _ArticlePreviewWidget extends StatelessWidget {
  const _ArticlePreviewWidget({super.key, required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 150,
        child: Card(
          clipBehavior: Clip.hardEdge,
          elevation: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: Image.network(article.multimedia.first.url),
                ),
              ),
              Flexible(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AutoSizeText(
                        article.title,
                        style: GoogleFonts.barlowCondensed(),
                        minFontSize: 18,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 16),
                                  Flexible(
                                    child: AutoSizeText(
                                      article.byline,
                                      maxFontSize: 12,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          children: [
                            const Icon(Icons.date_range, size: 16),
                            Flexible(
                              child: AutoSizeText(
                                DateFormat('yyyy.MM.dd kk:mm').format(
                                    DateTime.parse(article.createdDate)),
                                maxFontSize: 12,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

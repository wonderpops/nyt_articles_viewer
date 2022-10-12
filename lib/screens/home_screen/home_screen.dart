import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nyt_articles_viewer/blocs/bloc/articles_bloc.dart';
import 'package:nyt_articles_viewer/screens/article_screen/article_screen.dart';

import '../../models/article_preview_model.dart';

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

  List<Widget> buildArticlesPage(context, List<ArticlePreview> pageArticles,
      int currentPage, int pageCount) {
    List<Widget> pageWidgets = [];
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    pageWidgets.add(
      AppBar(
        title: const Text('The NYT top stories'),
        primary: false,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
    );

    pageWidgets += pageArticles
        .map<Widget>((article) => _ArticlePreviewWidget(article: article))
        .toList();

    pageWidgets.add(pageChangerWidget(currentPage, pageCount));
    return pageWidgets;
  }

  Widget pageChangerWidget(int currentPage, int pageCount) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Opacity(
            opacity: currentPage == 0 ? 0 : 1,
            child: TextButton(
                onPressed: () {
                  if (currentPage != 0) {
                    jumpToPage(currentPage - 1);
                  }
                },
                child: const Text('Previous page')),
          ),
          Text('${currentPage + 1} of $pageCount'),
          Opacity(
            opacity: currentPage == pageCount - 1 ? 0 : 1,
            child: TextButton(
                onPressed: () {
                  if (currentPage != pageCount) {
                    jumpToPage(currentPage + 1);
                  }
                },
                child: const Text('Next page')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      backgroundColor: colorScheme.surfaceVariant.withOpacity(.4),
      body: BlocConsumer<ArticlesBloc, ArticlesState>(
        listener: (context, state) {
          if (state is ArticleViewState) {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const ArticleScreenWidget(),
                transitionDuration: const Duration(milliseconds: 300),
                transitionsBuilder: (_, a, __, c) =>
                    FadeTransition(opacity: a, child: c),
              ),
            );
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case ArticlesLoadedState:
            case ArticleViewState:
              List<ArticlePreview> articles = articlesBloc.articles;
              int maxArticlesOnPageCount = 5;
              return PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  itemCount: (articles.length / maxArticlesOnPageCount).ceil(),
                  itemBuilder: (context, page) {
                    List<ArticlePreview> pageArticles;
                    if ((page + 1) * maxArticlesOnPageCount < articles.length) {
                      pageArticles = articles
                          .getRange(
                            page * maxArticlesOnPageCount,
                            (page + 1) * maxArticlesOnPageCount,
                          )
                          .toList();
                    } else {
                      pageArticles =
                          articles.skip(page * maxArticlesOnPageCount).toList();
                    }

                    return ListView(
                        children: buildArticlesPage(context, pageArticles, page,
                            (articles.length / maxArticlesOnPageCount).ceil()));
                  });
            default:
              return Container();
          }
        },
      ),
    );
  }
}

class _ArticlePreviewWidget extends StatelessWidget {
  const _ArticlePreviewWidget({super.key, required this.article});
  final ArticlePreview article;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          ArticlesBloc articlesBloc = BlocProvider.of<ArticlesBloc>(context);
          articlesBloc.add(ArticleViewEvent(articleUrl: article.url));
        },
        child: SizedBox(
          child: Card(
            clipBehavior: Clip.hardEdge,
            elevation: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 4.0 / 3.0,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(article.multimedia.first.url),
                          ),
                        ),
                      ),
                      Positioned(
                          left: 12,
                          top: 12,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: colorScheme.tertiaryContainer),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              child: Text(article.section),
                            ),
                          )),
                    ],
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Opacity(
                            opacity: .4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(Icons.date_range, size: 16),
                                      Flexible(
                                        child: AutoSizeText(
                                          DateFormat('yyyy.MM.dd kk:mm').format(
                                              DateTime.parse(
                                                  article.createdDate)),
                                          maxFontSize: 12,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AutoSizeText(
                          article.title,
                          style: GoogleFonts.barlowCondensed(),
                          minFontSize: 22,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

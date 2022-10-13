import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:nyt_articles_viewer/blocs/bloc/articles_bloc.dart';
import 'package:nyt_articles_viewer/models/section_model.dart';
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
  final double appbarHeight = 60;
  late ScrollController _scrollViewController;

  bool isScrollingDown = false;
  bool isScrolling = false;

  double lastOffset = 0;
  double offset = 0;
  bool isFilterCoosing = false;
  Section? selectedSection;

  @override
  void initState() {
    articlesBloc = BlocProvider.of<ArticlesBloc>(context);
    if (articlesBloc.articles.length == 0) {
      articlesBloc.add(ArticlesLoadEvent());
    }

    pageController = PageController();

    _scrollViewController = ScrollController();
    _scrollViewController.addListener(calcOffset);

    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    _scrollViewController.removeListener(calcOffset);
    _scrollViewController.dispose();

    super.dispose();
  }

  calcOffset() {
    if (_scrollViewController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!isScrollingDown) {
        isScrolling = true;
        lastOffset = _scrollViewController.offset;
        isScrollingDown = true;
      }
    }

    if (_scrollViewController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (isScrollingDown) {
        isScrolling = true;
        isScrollingDown = false;
        lastOffset = _scrollViewController.offset - appbarHeight;
      }
    }

    offset = _scrollViewController.offset - lastOffset;

    offset = offset > appbarHeight
        ? appbarHeight
        : offset < 0
            ? 0
            : offset;

    if (_scrollViewController.offset == 0) {
      offset = 0;
    }

    if (offset != appbarHeight && offset != 0) {
      setState(() {});
    }

    if (offset == appbarHeight || offset == 0) {
      isScrolling = false;
    }

    // print('$lastOffset | $offset');
  }

  jumpToPage(pageIndex) {
    pageController.jumpToPage(pageIndex);
  }

  List<Widget> buildArticlesPage(context, List<ArticlePreview> pageArticles,
      int currentPage, int pageCount) {
    List<Widget> pageWidgets = [];
    ColorScheme colorScheme = Theme.of(context).colorScheme;

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
      backgroundColor: colorScheme.brightness == Brightness.light
          ? Color.fromARGB(255, 233, 232, 240)
          : Color.fromARGB(100, 0, 0, 0),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: appbarHeight - offset),
            child: BlocConsumer<ArticlesBloc, ArticlesState>(
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
                if (state is NewArticlesLoadedState) {
                  setState(() {});
                }
              },
              builder: (context, state) {
                switch (state.runtimeType) {
                  case ArticlesLoadedState:
                  case ArticleViewState:
                  case NewArticlesLoadedState:
                    late List<ArticlePreview> articles;
                    if (selectedSection != null) {
                      articles = articlesBloc.articles
                          .where((element) =>
                              element.section == selectedSection!.name)
                          .toList();
                    } else {
                      articles = articlesBloc.articles;
                    }
                    int maxArticlesOnPageCount = 5;
                    if (articles.length > 0) {
                      return PageView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: pageController,
                          itemCount:
                              (articles.length / maxArticlesOnPageCount).ceil(),
                          itemBuilder: (context, page) {
                            List<ArticlePreview> pageArticles;
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
                                controller: _scrollViewController,
                                children: buildArticlesPage(
                                    context,
                                    pageArticles,
                                    page,
                                    (articles.length / maxArticlesOnPageCount)
                                        .ceil()));
                          });
                    } else {
                      return const Center(
                        child: Text('Articles not found 😢'),
                      );
                    }

                  default:
                    return const Center(
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(),
                      ),
                    );
                }
              },
            ),
          ),
          Opacity(
            opacity: 1 - offset / appbarHeight,
            child: Container(
              color: colorScheme.surface,
              child: SizedBox(
                height: appbarHeight - offset,
                width: double.maxFinite,
                child: Transform.translate(
                  offset: Offset(0, offset * -1),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AutoSizeText(
                          'The NYT top stories',
                          minFontSize: 18,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    isFilterCoosing = true;
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.filter_list_alt),
                                ),
                                Visibility(
                                  visible: selectedSection != null,
                                  child: Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        height: 8,
                                        width: 8,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: colorScheme.error),
                                      )),
                                )
                              ],
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () async {
                                // articlesBloc.add(CheckNewArticlesEvent());
                              },
                              icon: const Icon(Icons.notifications),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: isFilterCoosing,
            child: Container(
              color: Colors.black.withOpacity(.6),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          isFilterCoosing = false;
                          setState(() {});
                        },
                        icon: Icon(Icons.cancel_outlined,
                            color: Colors.white.withOpacity(.8)),
                      ),
                      Card(
                        elevation: 10,
                        child: SizedBox(
                            width: double.maxFinite,
                            height: 300,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GridView.count(
                                childAspectRatio: 3 / 1,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                crossAxisCount: 2,
                                children: sections
                                    .map((e) => GestureDetector(
                                          onTap: () {
                                            isFilterCoosing = false;
                                            selectedSection = e;
                                            setState(() {});
                                          },
                                          child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: colorScheme
                                                    .tertiaryContainer),
                                            child: Center(
                                                child: AutoSizeText(e.name)),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            )),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            isFilterCoosing = false;
                            selectedSection = null;
                            setState(() {});
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(8),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          child: const Text(
                            'Cancel all filters',
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
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
                            child: CachedNetworkImage(
                              imageUrl: article.multimediaUrl,
                              placeholder: (context, url) => Padding(
                                padding: const EdgeInsets.all(100),
                                child: CircularProgressIndicator(
                                  color: colorScheme.tertiary,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
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
                                  horizontal: 12, vertical: 2),
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
                          style: GoogleFonts.barlowCondensed(
                            fontWeight: FontWeight.bold,
                          ),
                          minFontSize: 24,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        AutoSizeText(
                          article.abstract,
                          style: GoogleFonts.barlowCondensed(),
                          minFontSize: 18,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
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

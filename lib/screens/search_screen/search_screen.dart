import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nyt_articles_viewer/models/article_preview_model.dart';

import '../../blocs/bloc/articles_bloc.dart';
import '../article_screen/article_screen.dart';

class SearchScreenWidget extends StatefulWidget {
  const SearchScreenWidget({super.key});

  @override
  State<SearchScreenWidget> createState() => _SearchScreenWidgetState();
}

class _SearchScreenWidgetState extends State<SearchScreenWidget>
    with SingleTickerProviderStateMixin {
  final double appbarHeight = 60;
  late ScrollController _scrollViewController;
  late ArticlesBloc articlesBloc;
  bool isScrollingDown = false;
  bool isScrolling = false;

  double lastOffset = 0;
  double offset = 0;
  List<ArticlePreview> searchResults = [];

  @override
  void initState() {
    articlesBloc = BlocProvider.of<ArticlesBloc>(context);
    _scrollViewController = ScrollController();
    _scrollViewController.addListener(calcOffset);
    searchResults = articlesBloc.articles;
    super.initState();
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _scrollViewController.removeListener(() {});
    super.dispose();
  }

  searchArticles(String query) {
    List<ArticlePreview> results = [];
    if (query != '') {
      for (var i = 0; i < articlesBloc.articles.length; i++) {
        if (articlesBloc.articles[i].title
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            articlesBloc.articles[i].section.contains(query.toLowerCase())) {
          results.add(articlesBloc.articles[i]);
        }
      }
    } else {
      searchResults = articlesBloc.articles;
      setState(() {});
      return;
    }

    searchResults = results;
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BlocListener<ArticlesBloc, ArticlesState>(
      listener: (context, state) {
        if (articlesBloc.state is ArticleViewState) {
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
      child: Scaffold(
        backgroundColor: colorScheme.brightness == Brightness.light
            ? Color.fromARGB(255, 233, 232, 240)
            : Color.fromARGB(100, 0, 0, 0),
        body: SafeArea(
            child: Column(
          children: [
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
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: TextField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10.0),
                              suffixIcon: const Icon(Icons.search),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide(
                                      width: 1,
                                      color:
                                          colorScheme.outline.withOpacity(.4))),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide(
                                    color: colorScheme.primary.withOpacity(.4)),
                              ),
                              labelText: 'Search...',
                              hintText: 'Type query or section name',
                            ),
                            onChanged: (query) async {
                              searchArticles(query);
                            }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (searchResults.isNotEmpty)
              Flexible(
                child: ListView.builder(
                    controller: _scrollViewController,
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return _ArticlePreviewWidget(
                          article: searchResults[index]);
                    }),
              ),
            if (searchResults.isEmpty)
              const Flexible(
                child: SizedBox(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: Center(
                      child: AutoSizeText(
                    'Articles not found 😢',
                    minFontSize: 18,
                  )),
                ),
              ),
          ],
        )),
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
    return GestureDetector(
      onTap: () {
        ArticlesBloc articlesBloc = BlocProvider.of<ArticlesBloc>(context);
        articlesBloc.add(ArticleViewEvent(articleUrl: article.url));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 150,
          child: Card(
            clipBehavior: Clip.hardEdge,
            elevation: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: CachedNetworkImage(
                          imageUrl: article.multimediaUrl,
                          placeholder: (context, url) => Padding(
                            padding: const EdgeInsets.all(50),
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
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AutoSizeText(
                          article.title,
                          style: GoogleFonts.barlowCondensed(),
                          minFontSize: 18,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Visibility(
                          visible: article.byline.isNotEmpty,
                          child: Flexible(
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
      ),
    );
  }
}

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
  // late ScrollController scrollController;

  @override
  void initState() {
    articlesBloc = BlocProvider.of<ArticlesBloc>(context);
    articlesBloc.add(ArticlesLoadEvent());
    // scrollController = ScrollController()..addListener(loadMoreArticles);
    super.initState();
  }

  // loadMoreArticles() async {
  //   if (scrollController.offset == scrollController.position.maxScrollExtent) {

  //   }
  // }

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
                return ListView.builder(
                  // controller: scrollController,
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
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
                                  child: Image.network(
                                      articles[index].multimedia.first.url),
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AutoSizeText(
                                        articles[index].title,
                                        style: GoogleFonts.barlowCondensed(),
                                        minFontSize: 18,
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Flexible(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.person,
                                                      size: 16),
                                                  Flexible(
                                                    child: AutoSizeText(
                                                      articles[index].byline,
                                                      maxFontSize: 12,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                            const Icon(Icons.date_range,
                                                size: 16),
                                            Flexible(
                                              child: AutoSizeText(
                                                DateFormat('yyyy.MM.dd kk:mm')
                                                    .format(DateTime.parse(
                                                        articles[index]
                                                            .createdDate)),
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
                  },
                );
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}

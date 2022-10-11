import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nyt_articles_viewer/blocs/bloc/articles_bloc.dart';

import '../../models/article_model.dart';

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  late ArticlesBloc articlesBloc;

  @override
  void initState() {
    articlesBloc = BlocProvider.of<ArticlesBloc>(context);
    articlesBloc.add(ArticlesLoadEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('NYT Top Stories'),
          backgroundColor: colorScheme.primaryContainer,
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<ArticlesBloc, ArticlesState>(
          builder: (context, state) {
            switch (state.runtimeType) {
              case ArticlesLoadedState:
                ArticlesLoadedState articlesLoadedState =
                    articlesBloc.state as ArticlesLoadedState;
                List<Article> articles = articlesLoadedState.articles;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: Column(
                            children: [
                              if (articles[index].multimedia != null)
                                Image.network(
                                    articles[index].multimedia!.first.url ??
                                        ''),
                              Row(
                                children: [],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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

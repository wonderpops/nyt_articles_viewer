import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nyt_articles_viewer/main_layout.dart';
import 'package:nyt_articles_viewer/screens/home_screen/home_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../blocs/bloc/articles_bloc.dart';
import '../../models/article_preview_model.dart';

class ArticleScreenWidget extends StatefulWidget {
  const ArticleScreenWidget({super.key});

  @override
  State<ArticleScreenWidget> createState() => _ArticleScreenWidgetState();
}

class _ArticleScreenWidgetState extends State<ArticleScreenWidget> {
  bool isPageReady = false;

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ArticlesBloc articlesBloc = BlocProvider.of<ArticlesBloc>(context);
    ArticleViewState articleViewState = articlesBloc.state as ArticleViewState;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.surfaceVariant,
        body: Stack(
          children: [
            _BackgroundWidget(
              multimedia: articleViewState.backgroundImage,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                          backgroundColor:
                              Colors.transparent, // <-- Button color
                          foregroundColor:
                              colorScheme.primary, // <-- Splash color
                        ),
                        child:
                            const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: articleViewState.articleUrl));
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                          backgroundColor:
                              Colors.transparent, // <-- Button color
                          foregroundColor:
                              colorScheme.primary, // <-- Splash color
                        ),
                        child:
                            const Icon(Icons.link_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: WebView(
                            javascriptMode: JavascriptMode.unrestricted,
                            // navigationDelegate: (NavigationRequest request) {
                            //   return NavigationDecision.prevent;
                            // },
                            onPageStarted: (url) {
                              print(url);
                            },

                            onPageFinished: (str) {
                              isPageReady = true;
                              setState(() {});
                            },
                            initialUrl: articleViewState.articleUrl,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: !isPageReady,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  color: colorScheme.surface,
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                ))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundWidget extends StatelessWidget {
  const _BackgroundWidget({super.key, required this.multimedia});
  final Image? multimedia;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (multimedia is Image) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Flexible(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FittedBox(
                      fit: BoxFit.fitHeight,
                      clipBehavior: Clip.hardEdge,
                      child: multimedia,
                    ),
                    Positioned.fill(
                        bottom: 0,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [
                                0.2,
                                1,
                              ],
                              colors: [
                                colorScheme.surfaceVariant,
                                colorScheme.surfaceVariant.withOpacity(.0),
                              ],
                            )),
                            height: 30,
                            width: double.maxFinite,
                          ),
                        )),
                    Positioned.fill(
                        child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [
                            0,
                            0.9,
                          ],
                          colors: [
                            colorScheme.surfaceVariant.withOpacity(.0),
                            colorScheme.surfaceVariant,
                          ],
                        )),
                        height: 50,
                        width: double.maxFinite,
                      ),
                    ))
                  ],
                ),
              ),
              const Flexible(child: SizedBox())
            ],
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 5, sigmaY: 5, tileMode: TileMode.clamp),
            child: Container(
              alignment: Alignment.center,
              color: colorScheme.background.withOpacity(.1),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}

// class _ArticleWidget extends StatefulWidget {
//   const _ArticleWidget({super.key, required this.article});
//   final ArticlePreview article;

//   @override
//   State<_ArticleWidget> createState() => _ArticleWidgetState();
// }

// class _ArticleWidgetState extends State<_ArticleWidget> {
//   @override
//   void initState() {
//     if (Platform.isAndroid) WebView.platform = AndroidWebView();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     ColorScheme colorScheme = Theme.of(context).colorScheme;
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: GestureDetector(
//         onTap: () {
//           ArticlesBloc articlesBloc = BlocProvider.of<ArticlesBloc>(context);
//           articlesBloc.add(ArticleViewEvent(articleUrl: widget.article.url));
//         },
//         child: SizedBox(
//           child: Card(
//             clipBehavior: Clip.hardEdge,
//             elevation: 0,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: AspectRatio(
//                       aspectRatio: 4.0 / 3.0,
//                       child: FittedBox(
//                         fit: BoxFit.cover,
//                         clipBehavior: Clip.hardEdge,
//                         child:
//                             Image.network(widget.article.multimedia.first.url),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Flexible(
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Flexible(
//                           child: Opacity(
//                             opacity: .4,
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Flexible(
//                                   child: Row(
//                                     children: [
//                                       const Icon(Icons.person, size: 16),
//                                       Flexible(
//                                         child: AutoSizeText(
//                                           widget.article.byline,
//                                           maxFontSize: 12,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Flexible(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       const Icon(Icons.date_range, size: 16),
//                                       Flexible(
//                                         child: AutoSizeText(
//                                           DateFormat('yyyy.MM.dd kk:mm').format(
//                                               DateTime.parse(
//                                                   widget.article.createdDate)),
//                                           maxFontSize: 12,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         AutoSizeText(
//                           widget.article.title,
//                           style: GoogleFonts.barlowCondensed(),
//                           minFontSize: 22,
//                           maxLines: 5,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         Container(
//                             height: 500,
//                             child: WebView(initialUrl: widget.article.url))
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

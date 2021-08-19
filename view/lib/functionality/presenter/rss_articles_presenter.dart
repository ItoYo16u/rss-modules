import 'package:flutter/widgets.dart';
import 'package:rss_core/model/rss_item.dart';
import 'package:rss_core/query/rss_query.dart';

class RssArticlesPresenter extends StatefulWidget {
  const RssArticlesPresenter(
      {required this.rssQuery,
      required this.url,
      required this.builder,
      required this.onLoading,
      required this.onError,
      Key? key})
      : super(key: key);

  final RSSQuery rssQuery;
  final String url;
  final Widget Function(BuildContext context, Iterable<RSSItem> articles,
      Future<void> Function() refresh) builder;
  final Widget onLoading;
  final Widget Function(BuildContext, Object?) onError;

  @override
  _RssArticlesPresenterState createState() => _RssArticlesPresenterState();
}

class _RssArticlesPresenterState extends State<RssArticlesPresenter> {
  late Future<Iterable<RSSItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.rssQuery.listArticlesByUrl(widget.url);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Iterable<RSSItem>>(
      future: _future,
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          return widget.builder(ctx, snapshot.data!, () async {
            final res = await widget.rssQuery.listArticlesByUrl(widget.url);
            final completed = Future.value(res);
            setState(() {
              _future = completed;
            });
          });
        } else {
          return widget.onLoading;
        }
      });
}

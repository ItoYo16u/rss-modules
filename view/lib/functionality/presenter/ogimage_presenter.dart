import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:rss_core/query/rss_query.dart';

class OGImagePresenter extends StatefulWidget {
  const OGImagePresenter(
      {required this.rssQuery,
      required this.articleUrl,
      required this.onLoading,
      required this.onError,
      this.onNotFound,
      this.builder,
      this.keepAlive = false,
      Key? key})
      : super(key: key);

  final RSSQuery rssQuery;
  final String articleUrl;
  final Widget Function(BuildContext context, String ogImageUrl)? builder;
  final Widget onLoading;
  final bool keepAlive;
  final Widget Function(BuildContext, Object?) onError;
  final Widget Function(BuildContext)? onNotFound;

  @override
  _OGImagePresenterState createState() => _OGImagePresenterState();
}

class _OGImagePresenterState extends State<OGImagePresenter>
    with AutomaticKeepAliveClientMixin {
  late Future<String?> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.rssQuery.fetchOGImageByUrl(widget.articleUrl);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<String?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null) {
              return widget.onNotFound?.call(context) ??
                  const SizedBox.shrink();
            } else {
              if (widget.builder != null) {
                return widget.builder!(context, snapshot.data!);
              } else {
                return CachedNetworkImage(imageUrl: snapshot.data!);
              }
            }
          } else if (snapshot.hasError) {
            return widget.onError(context, snapshot.error);
          } else {
            return widget.onLoading;
          }
        });
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}

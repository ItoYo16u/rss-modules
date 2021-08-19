import 'package:flechette/flechette.dart';
import 'package:flutter/material.dart';
import 'package:rss_core/model/rss_channel.dart';
import 'package:rss_core/query/rss_query.dart';

class RSSChannelPresenter extends StatefulWidget {
  const RSSChannelPresenter(
      {required this.rssQuery,
      required this.url,
      required this.builder,
      required this.onError,
      this.onLoading,
      Key? key})
      : super(key: key);

  final RSSQuery rssQuery;
  final String url;
  final Widget Function(BuildContext context, RSSChannel articles) builder;
  final Widget? onLoading;
  final Widget Function(BuildContext, Object?) onError;

  @override
  _RSSChannelPresenterState createState() => _RSSChannelPresenterState();
}

class _RSSChannelPresenterState extends State<RSSChannelPresenter> {
  late Future<Result<RSSChannel>> _f;

  @override
  void initState() {
    super.initState();
    _f = widget.rssQuery.getChannelByUrl(widget.url);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Result<RSSChannel>>(
      future: _f,
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          final res = snapshot.data!;
          if (res.isSuccess) {
            return widget.builder(ctx, res.value!);
          } else {
            return widget.onError(ctx, res.errorKey);
          }
        } else if (snapshot.hasError) {
          return widget.onError(ctx, snapshot.error);
        } else {
          return widget.onLoading ??
              const Center(
                child: CircularProgressIndicator(),
              );
        }
      });
}

import 'package:flutter/material.dart';
import 'package:rss_core/model/rss_channel.dart';
import 'package:rss_core/query/rss_query.dart';

class RSSListPresenter extends StatefulWidget {
  const RSSListPresenter(
      {required this.rssQuery,
      required this.builder,
      required this.wantKeepAlive,
      required this.onError,
      this.onLoading,
      this.doOnData,
      Key? key})
      : super(key: key);

  final RSSQuery rssQuery;
  final bool wantKeepAlive;
  final Widget Function(BuildContext context, Iterable<RSSChannel> channels,
      Future<void> Function() refresh) builder;
  final Widget? onLoading;
  final Widget Function(BuildContext, Object?) onError;
  final void Function(Iterable<RSSChannel>)? doOnData;

  @override
  _RSSListPresenterState createState() => _RSSListPresenterState();
}

class _RSSListPresenterState extends State<RSSListPresenter>
    with AutomaticKeepAliveClientMixin {
  late Future<Iterable<RSSChannel>> _f;

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;

  @override
  void initState() {
    super.initState();
    _f = widget.rssQuery.listSavedRSSChannels();
    if (widget.doOnData != null) {
      _f.then((value) => widget.doOnData!(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Iterable<RSSChannel>>(
        future: _f,
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return widget.builder(ctx, snapshot.data!, () async {
              final next = await widget.rssQuery.listSavedRSSChannels();
              setState(() {
                _f = Future.value(next);
              });
            });
          } else if (snapshot.hasError) {
            return widget.onError(ctx, snapshot.error!);
          } else {
            return widget.onLoading ??
                const Center(child: CircularProgressIndicator());
          }
        });
  }
}

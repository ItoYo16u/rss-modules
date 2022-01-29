import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rss_core/query/rss_query.dart';
import 'package:rss_view/functionality/presenter/rss_channel_presenter.dart';

class FeedThumbnail extends StatelessWidget {
  const FeedThumbnail(
      {required this.url,
      required this.rssQuery,
      required this.width,
      required this.height,
      required this.onThumbnailMissing,
      Key? key})
      : super(key: key);

  final String url;
  final double width;
  final double height;
  final RSSQuery rssQuery;

  /// displayed when the channel found by the given url does not have thumbnail.
  final Widget onThumbnailMissing;

  @override
  Widget build(BuildContext context) => RSSChannelPresenter(
        rssQuery: rssQuery,
        url: url,
        builder: (ctx, channel) => channel.favicon == null
            ? onThumbnailMissing
            : CachedNetworkImage(
                width: width,
                height: height,
                imageUrl: channel.favicon!.src.toString(),
                placeholder: (context, url) => ColoredBox(
                  color: Theme.of(context).canvasColor,
                ),
                errorWidget: (context, url, dynamic err) => ColoredBox(
                  color: Theme.of(context).canvasColor,
                ),
              ),
        onLoading: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
          child: ColoredBox(
            color: Theme.of(context).canvasColor,
          ),
        ),
        onError: (_, __) => Container(
          width: width,
          height: height,
          padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
          child: ColoredBox(
            color: Theme.of(context).canvasColor,
          ),
        ),
      );
}

import 'package:flechette/flechette.dart';
import 'package:meta/meta.dart';
import 'package:rss_core/model/rss_channel.dart';
import 'package:rss_core/model/rss_item.dart';

abstract class RSSQuery {
  final Map<String, RSSChannel> _cache = {};

  Future<Iterable<RSSItem>> listArticlesByUrl(String url);

  /// implement logic to get rss channel's urls.
  @protected
  Future<Iterable<String>> getSavedRSSUrls();

  // fetch channel from cache or storage.
  @nonVirtual
  Future<Result<RSSChannel>> getChannelByUrl(String url) async {
    final maybeChannel = _cache[url];
    if (maybeChannel != null) {
      return Result.success(maybeChannel);
    }
    final channel = await onCacheMissing(url);
    if (channel.isSuccess) {
      _cache[url] = channel.value!;
      return channel;
    } else {
      return Result.failure('CHANNEL_NOT_FOUND',
          'Reason: ${channel.errorKey!}. Detail: ${channel.errorMessage}');
    }
  }

  /// implement logic to fetch rss channels if cache for the given url is missing.
  @protected
  Future<Result<RSSChannel>> onCacheMissing(String url);

  Future<String?> fetchOGImageByUrl(String url);

  @nonVirtual
  Future<Iterable<RSSChannel>> listSavedRSSChannels() async {
    final urls = await getSavedRSSUrls();
    final channels = await Future.wait(urls.map(getChannelByUrl));
    return channels.where((e) => e.isSuccess).map((e) => e.value!);
  }
}

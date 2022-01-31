import 'package:flechette/flechette.dart';
import 'package:rss_core/model/channel_list.dart';
import 'package:rss_core/model/rss_channel.dart';

abstract class RSSRepository {
  Future<Result<RSSChannel>> addRSSChannel(String userId, String url);

  Future<Result<String>> removeRSSChannel(String userId, String url);

  Future<Iterable<String>> getSavedRSSChannels(String userId);

  Future<Iterable<ChannelList>> getChannelLists(String userId);
}

import 'package:rss_core/model/channel_list.dart';

abstract class RSSRepository {
  Future<void> addRSSChannel(String userId, String url);

  Future<void> removeRSSChannel(String userId, String url);

  Future<Iterable<String>> getSavedRSSChannels(String userId);

  Future<Iterable<ChannelList>> getChannelLists(String userId);
}

import 'package:rss_core/model/channel_list.dart';

abstract class RSSRepository {
  Future<int> addGroup(String userId, String groupLabel,
      {Iterable<String> urls = const <String>[]});

  Future<void> addRSSChannel(String userId, String url);

  Future<void> addRSSChannels(String userId, Iterable<String> urls);

  Future<void> removeRSSChannel(String userId, String url);

  Future<void> removeRSSChannels(String userId, Iterable<String> urls);

  Future<Iterable<String>> getSavedRSSChannels(String userId);

  Future<Iterable<ChannelList>> getChannelLists(String userId);

  Future<void> deleteGroup(String userId, int groupId);

  Future<void> deleteGroups(String userId, Iterable<int> groupIds);
}

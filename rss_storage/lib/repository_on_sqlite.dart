import 'package:flechette/struct/tuple.dart';
import 'package:flechette/syntax/collections.dart';
import 'package:path/path.dart' as path;
import 'package:rss_core/model/channel_list.dart';
import 'package:rss_core/repository/rss_repository.dart';
import 'package:rss_storage/config.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

class RSSRepositoryOnSqlite implements RSSRepository {
  RSSRepositoryOnSqlite._(this._db, this._config);
  static Future<RSSRepository> instance(DBConfig config) async {
    final dbpath = await sqlite.getDatabasesPath();
    final p = path.join(dbpath, config.dbFile);
    return sqlite.openDatabase(p, version: config.version,
        onCreate: (db, version) async {
      await Future.wait([
        db.execute(
            'CREATE TABLE ${config.channelTable} (user_id TEXT, url TEXT)'),
        db.execute(
            'CREATE TABLE ${config.groupTable} (group_id INTEGER PRIMARY KEY AUTOINCREMENT,user_id TEXT, label TEXT)'),
        db.execute(
            'CREATE TABLE ${config.relationTable} (group_id INTEGER, channel_url TEXT, FOREIGN KEY(group_id) REFERENCES ${config.groupTable}(group_id))')
      ]);
    }).then((db) => _instance ??= RSSRepositoryOnSqlite._(db, config));
  }

  static RSSRepositoryOnSqlite? _instance;

  final sqlite.Database _db;
  final DBConfig _config;

  @override
  Future<Iterable<String>> getSavedRSSChannels(String userId) async {
    final records = await _db.query(_config.channelTable,
        where: 'user_id = ?', whereArgs: [userId], columns: ['url']);
    return records.map((record) => record['url']! as String);
  }

  @override
  Future<Iterable<ChannelList>> getChannelLists(String userId) async {
    final q =
        'SELECT ${_config.groupTable}.group_id,${_config.groupTable}.label, ${_config.relationTable}.channel_url '
        'FROM ${_config.groupTable} '
        'INNER JOIN ${_config.relationTable} '
        'ON ${_config.groupTable}.group_id = ${_config.relationTable}.group_id '
        'WHERE ${_config.groupTable}.user_id = ? ';
    final data = await _db.rawQuery(q, [userId]);
    return data
        .groupBy(
            (record) => $(record['group_id'] as int, record['label'] as String))
        .entries
        .map((entry) => ChannelList(
            id: entry.key.$0,
            label: entry.key.$1,
            channelURLs: entry.value.map((record) => record['url'] as String)));
  }

  @override
  Future<int> addGroup(String userId, String groupLabel,
      {Iterable<String> urls = const <String>[]}) async {
    //final followingChannels = await getSavedRSSChannels(userId);
    //final notFollowings = urls.where((url) => !followingChannels.contains(url));
    //if (notFollowings.isNotEmpty) {
    //  await addRSSChannels(userId, notFollowings);
    // }
    final g = {'label': groupLabel, 'user_id': userId};
    final res = await _db.transaction((txn) async {
      final groupId = await txn.insert(_config.groupTable, g);
      final relations =
          urls.map((url) => {'channel_url': url, 'group_id': groupId});
      final batch = txn.batch();
      relations.toList().forEach((relation) {
        batch.insert(_config.relationTable, relation);
      });
      await batch.commit();
      return groupId;
    });
    return res;
  }

  Future<int?> updateGroup(String userId, int groupId,
      // cmd : Add(urls) | Delete(urls)
      {Iterable<String> urls = const <String>[]}) async {
    final g = await _db.query(_config.groupTable,
        where: 'group_id = ? AND user_id = ?',
        whereArgs: [groupId, userId],
        columns: ['group_id', 'label'],
        limit: 1);
    if (g.isEmpty) {
      return null;
    } else {
      throw UnimplementedError();
    }
  }

  @override
  Future<void> deleteGroup(String userId, int groupId) async {
    await _db.delete(_config.groupTable,
        where: 'user_id = ? AND group_id = ?', whereArgs: [userId, groupId]);
  }

  @override
  Future<void> deleteGroups(String userId, Iterable<int> groupIds) async {
    final bt = _db.batch();
    groupIds.toList().forEach((id) {
      bt.delete(_config.groupTable,
          where: 'user_id = ? AND group_id = ?', whereArgs: [userId, id]);
    });
    await bt.commit();
  }

  @override
  Future<void> addRSSChannel(String userId, String url) async {
    await _db.insert(_config.channelTable, {'url': url, 'user_id': userId});
  }

  @override
  Future<void> addRSSChannels(String userId, Iterable<String> urls) async {
    final bt = _db.batch();
    urls.toList().forEach((url) {
      bt.insert(_config.channelTable, {'url': url, 'user_id': userId});
    });
    await bt.commit();
  }

  @override
  Future<void> removeRSSChannels(String userId, Iterable<String> urls) async {
    final bt = _db.batch();
    urls.toList().forEach((url) {
      bt.delete(_config.channelTable,
          where: 'user_id = ? AND url = ?', whereArgs: [userId, url]);
    });
    await bt.commit();
  }

  @override
  Future<void> removeRSSChannel(String userId, String url) async {
    await _db.delete(_config.channelTable,
        where: 'user_id = ? AND url = ?', whereArgs: [userId, url]);
  }

  void dispose() {
    _db.close();
  }
}

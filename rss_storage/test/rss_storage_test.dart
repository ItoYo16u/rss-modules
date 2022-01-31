import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:rss_core/repository/rss_repository.dart';
import 'package:rss_storage/config.dart';
import 'package:rss_storage/repository_on_sqlite.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  const user0 = 'user0';
  const user1 = 'user1';
  const testdb = 'test.db';
  final config = DBConfig(dbFile: testdb, groupTable: 'g', channelTable: 'ch');
  late final RSSRepository repo;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    repo = await RSSRepositoryOnSqlite.instance(config);
    WidgetsFlutterBinding.ensureInitialized();
  });
  tearDownAll(() async {
    final dbpath = await getDatabasesPath();
    await deleteDatabase(path.join(dbpath, testdb));
  });

  test('initialize database successfully', () async {
    final channels = await repo.getSavedRSSChannels(user0);
    expect(channels.isEmpty, true);
    final channelLists = await repo.getChannelLists(user0);
    expect(channelLists.isEmpty, true);
  });
  test('add,get and delete rss channel for user', () async {
    const ch = 'example.com/rss.xml';
    await repo.addRSSChannel(user0, ch);
    final c0 = await repo.getSavedRSSChannels(user0);
    final c1 = await repo.getSavedRSSChannels(user1);
    expect(c0.length, 1);
    expect(c1.length, 0);
    await repo.removeRSSChannel(user0, ch);
    await repo.removeRSSChannel(user1, ch);
    final c0_1 = await repo.getSavedRSSChannels(user0);
    final c1_1 = await repo.getSavedRSSChannels(user1);
    expect(c0_1.isEmpty, true);
    expect(c1_1.isEmpty, true);
  });
  test('add,get and delete rss channel group for user', () async {
    const ch0 = 'example.com/rss.xml';
    const testGroup = 'test_group';
    final impl = repo as RSSRepositoryOnSqlite;
    final channelLists0 = await impl.getChannelLists(user0);
    expect(channelLists0.length, 0);
    final groupId0 = await impl.addGroup(user0, testGroup, urls: [ch0]);
    final user0chList = await impl.getChannelLists(user0);
    final user1chList = await impl.getChannelLists(user1);
    expect(user0chList.length, 1);
    expect(user1chList.length, 0);
    expect(user0chList.first.label, testGroup);
    expect(user0chList.first.id, groupId0);
    const testGroup1 = 'test_group_1';
    final groupId1 = await impl.addGroup(user0, testGroup1, urls: [ch0]);
    final channelLists3 = await impl.getChannelLists(user0);
    expect(channelLists3.length, 2);
    await impl.deleteGroup(user0, groupId0);
    final channelLists2 = await impl.getChannelLists(user0);
    expect(channelLists2.length, 1);
    await impl.deleteGroup(user0, groupId1);
    final channelLists4 = await impl.getChannelLists(user0);
    expect(channelLists4.length, 0);
  });
}

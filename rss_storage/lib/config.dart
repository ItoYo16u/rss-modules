class DBConfig {
  DBConfig(
      {required this.dbFile,
      required this.groupTable,
      required this.channelTable,
      this.version = 1});
  final String dbFile;
  final int version;
  final String channelTable;
  final String groupTable;
  String get relationTable => channelTable + groupTable;
}

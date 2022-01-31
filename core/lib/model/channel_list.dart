class ChannelList {
  ChannelList(
      {required this.id, required this.label, required this.channelURLs});
  final Iterable<String> channelURLs;
  final int id;
  final String label;
}

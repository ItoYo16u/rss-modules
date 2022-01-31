class ChannelList {
  ChannelList(
      {required this.id,
      required this.label,
      required Iterable<String> channelURLs})
      : _underlying = channelURLs;
  final Iterable<String> _underlying;
  final String id;
  final String label;
}

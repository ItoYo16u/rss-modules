import 'package:rss_core/model/rss_channel.dart';

abstract class ParsableFromXML {}

const pubDateMapping = <RSSType, String>{
  RSSType.atom: 'updated',
  RSSType.v1_0: 'dc:date',
  RSSType.v2_0: 'pubDate'
};

const itemMapping = <RSSType, String>{
  RSSType.atom: 'entry',
  RSSType.v1_0: 'item',
  RSSType.v2_0: 'item'
};

const descriptionMapping = <RSSType, String>{
  RSSType.atom: 'summary',
  RSSType.v1_0: 'description',
  RSSType.v2_0: 'description'
};
const imageMapping = <RSSType, String?>{
  RSSType.v1_0: null,
  RSSType.v2_0: 'image',
  RSSType.atom: null
};

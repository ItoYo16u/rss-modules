import 'package:flechette/flechette.dart';
import 'package:rss_core/adaptor/xml/model_ops.dart';
import 'package:rss_core/adaptor/xml/rss_type_compat.dart';
import 'package:rss_core/model/rss_channel.dart';
import 'package:rss_core/model/rss_item.dart';
import 'package:xml/xml.dart';

class RSSParser {
  RSSType? checkRSSType(XmlDocument document) {
    final docName = document.rootElement.name;
    if (docName == XmlName.fromString('rdf:RDF')) {
      return RSSType.v1_0;
    } else if (docName == XmlName.fromString('rss')) {
      return RSSType.v2_0;
    } else if (docName == XmlName.fromString('feed')) {
      return RSSType.atom;
    } else {
      return null;
    }
  }

  Result<RSSChannel> extractChannel(XmlDocument doc, String rssUrl) {
    final rssType = checkRSSType(doc);
    if (rssType == null) {
      return Result.failure('', '');
    }
    final props = _extractChannelXML(rssType, doc);
    if (props == null) {
      return Result.failure('CHANNEL_NOT_FOUND', '');
    }
    return props.extractChannel(rssType, rssUrl);
  }

  Iterable<RSSItem> extractItems(XmlDocument doc, RSSChannel channel) {
    final rssType = checkRSSType(doc);
    if (rssType == null) {
      return [];
    }
    final itemElms = _extractItemsXML(rssType, doc);
    return itemElms
        .map((elm) => elm.extractItem(channel, rssType))
        .where((result) => result.isSuccess)
        .map((result) => result.value!);
  }

  XmlElement? _extractChannelXML(RSSType rssType, XmlDocument doc) {
    if (rssType == RSSType.atom) {
      final channelProps = doc.rootElement;
      return channelProps;
    } else {
      try {
        final channelProps = doc.rootElement.childElements.singleWhere(
          (element) => element.name == XmlName.fromString('channel'),
        );
        return channelProps;
      } on StateError {
        return null;
      }
    }
  }

  Iterable<XmlElement> _extractItemsXML(RSSType rssType, XmlDocument doc) {
    if (rssType == RSSType.v1_0) {
      final itemProps = doc.findAllElements(itemMapping[rssType]!);
      return itemProps;
    } else {
      final itemsProps = _extractChannelXML(rssType, doc);
      if (itemsProps == null) {
        return [];
      } else {
        return itemsProps.findAllElements(itemMapping[rssType]!);
      }
    }
  }
}

import 'package:rss_core/adaptor/xml/rss_parser.dart';
import 'package:rss_core/model/rss_channel.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'resource.dart';
// https://stackoverflow.com/questions/49385303/how-do-i-convert-a-date-time-string-to-a-datetime-object-in-dart

void main() {
  group('RSSParser', () {
    group('given rss 1.0', () {
      test('can parse rss doc', () {
        final p = RSSParser();
        final d = XmlDocument.parse(rss1_0);
        final rssType = p.checkRSSType(d);
        expect(rssType, RSSType.v1_0);
        final res = p.extractChannel(d, '');
        final channel = res.value;
        expect(channel is RSSChannel, true);
        expect(channel!.thumbnail == null, true);
        final items = p.extractItems(d, channel);
        expect(items.length, 3);
        expect(items.first.title, 'article0');
      });
    });
  });
  group('given rss 2.0', () {
    test('can parse rss doc', () {
      final p = RSSParser();
      final d = XmlDocument.parse(rss2_0);
      final rssType = p.checkRSSType(d);
      expect(rssType, RSSType.v2_0);
      final res = p.extractChannel(d, '');
      final channel = res.value;
      expect(channel is RSSChannel, true);
      expect(channel!.thumbnail == null, false);
      expect(channel.thumbnail!.src, 'http://example.com/image.jpg');
      final items = p.extractItems(d, channel);
      expect(items.length, 4);
      expect(items.first.title, 'article0');
    });
  });
  group('given atom', () {
    test('can parse rss doc', () {
      final p = RSSParser();
      final d = XmlDocument.parse(atom);
      final rssType = p.checkRSSType(d);
      expect(rssType, RSSType.atom);
      final res = p.extractChannel(d, 'http://example.com');
      final channel = res.value;
      expect(channel is RSSChannel, true);
      expect(channel!.thumbnail == null, true);
      final items = p.extractItems(d, channel);
      expect(items.length, 3);
      expect(items.first.title, 'article0');
    });
  });
}

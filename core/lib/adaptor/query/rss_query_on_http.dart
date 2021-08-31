import 'package:flechette/flechette.dart';
import 'package:http/http.dart' as http;
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:rss_core/adaptor/xml/rss_parser.dart';
import 'package:rss_core/model/rss_channel.dart';
import 'package:rss_core/model/rss_item.dart';
import 'package:rss_core/query/rss_query.dart';
import 'package:xml/xml.dart';
/// partial implementation that depends on http
abstract class RSSQueryOnHttp extends RSSQuery {
  RSSQueryOnHttp(this.client);

  final http.Client client;

  @override
  Future<Result<RSSChannel>> onCacheMissing(String url) async {
    final xmlString = await client.get(Uri.parse(url));
    final doc = XmlDocument.parse(xmlString.body);
    final p = RSSParser();
    final channel = p.extractChannel(doc, url);
    return channel;
  }

  @override
  Future<String?> fetchOGImageByUrl(String url) async {
    final data = await MetadataFetch.extract(url);
    return data?.image;
  }

  @override
  Future<Iterable<RSSItem>> listArticlesByUrl(String url) async {
    final xmlString = await client.get(Uri.parse(url));
    final doc = XmlDocument.parse(xmlString.body);
    final p = RSSParser();
    final channel = p.extractChannel(doc, url);
    if (channel.isSuccess) {
      final items = p.extractItems(doc, channel.value!);
      return items;
    } else {
      return <RSSItem>[];
    }
  }
}

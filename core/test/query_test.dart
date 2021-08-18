import 'package:http/http.dart' as http;
import 'package:http/src/client.dart';
import 'package:rss_core/adaptor/query/rss_query_on_http.dart';
import 'package:rss_core/model/rss_channel.dart';
import 'package:test/test.dart';

class RSSQueryTest extends RSSQueryOnHttp {
  RSSQueryTest(Client client) : super(client);

  @override
  Future<Iterable<String>> getSavedRSSUrls() {
    throw UnimplementedError();
  }
}

void main() {
  group('rss query on http', () {
    final client = http.Client();
    final q = RSSQueryTest(client);
    group('list articles by url', () {
      test('returns List<RSSItem>', () async {
        final res =
            await q.listArticlesByUrl('https://jp.techcrunch.com/feed/');
        expect(res.isNotEmpty, true);
      });
    });
    group('get channel by url', () {
      test('', () async {
        final res = await q.getChannelByUrl('https://jp.techcrunch.com/feed/');
        expect(res.value != null, true);
        expect(res.value!.title, 'TechCrunch Japan');
        expect(res.value!.thumbnail is Thumbnail, true);
        expect(
          res.value!.thumbnail!.src,
          'https://jp.techcrunch.com/wp-content/uploads/2021/05/cropped-logo_tc-1.png?w=32',
        );
      });
    });
  });
}

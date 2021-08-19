import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rss_core/adaptor/query/rss_query_on_http.dart';
import 'package:rss_view/rss_view.dart';

void main() {
  runApp(const MyApp());
}

class MockQuery extends RSSQueryOnHttp {
  MockQuery(http.Client client) : super(client);

  @override
  Future<Iterable<String>> getSavedRSSUrls() async {
    return [
      'http://jp.techcrunch.com/feed',
      'https://www.vox.com/rss/index.xml',
      'https://www.theguardian.com/world/zimbabwe/rss'
    ];
  }
}

final mockQuery = MockQuery(http.Client());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: RSSListPresenter(
          wantKeepAlive: false,
          rssQuery: mockQuery,
          onError: (_, __) => const SizedBox.shrink(),
          builder: (ctx, channels, _) => ListView.builder(
            itemBuilder: (ctx, idx) {
              final channel = channels.toList()[idx];
              return ListTile(
                title: Text(channel.title),
                subtitle: Text(channel.description),
                leading: FeedThumbnail(
                    rssQuery: mockQuery,
                    width: 42,
                    height: 42,
                    url: channel.url),
              );
            },
            itemCount: channels.length,
          ),
        ),
      ),
    );
  }
}

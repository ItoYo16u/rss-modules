import 'package:flechette/flechette.dart';
import 'package:rss_core/model/rss_channel.dart';

abstract class RSSRepository {
  Future<Result<RSSChannel>> addRSSChannel(String url);

  Future<Result<String>> removeRSSChannel(String url);
}

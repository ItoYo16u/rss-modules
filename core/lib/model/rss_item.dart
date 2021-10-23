/// article summary belonging to rss channel
class RSSItem {
  RSSItem({
    required this.id,
    required this.feedUrl,
    required this.feedTitle,
    required this.title,
    required this.description,
    required this.url,
    required this.rssUrl,
    required this.displayTime,
    this.categories = const [],
    this.author,
    this.keywords = const [],
    this.feedThumbnail,
  });

  final String id;

  /// title of article or rss content
  final String title;

  /// title of feed this item belongs to
  final String feedTitle;

  /// thumbnail url of feed this item belongs to
  final String? feedThumbnail;

  /// rss xml url this item belongs to
  final String rssUrl;

  /// author of this article or rss content
  final String? author;

  /// categories of this item
  final List<String> categories;
  final DateTime displayTime;
  final String description;

  final String feedUrl;

  /// uid
  final String url;
  final List<String> keywords;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'guid': id,
        'title': title,
        'url': url,
        'description': description,
        'feed_url': feedUrl,
        'feed_title': feedTitle,
        if (feedThumbnail != null) ...<String, dynamic>{
          'feed_image_url': feedThumbnail
        },
        if (author != null) ...<String, dynamic>{'author': author},
        'categories': categories,
        'keywords': keywords,
        'pub_date': displayTime.toIso8601String(),
      };
}

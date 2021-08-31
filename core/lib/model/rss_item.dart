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
  final String title;
  final String feedTitle;
  final String? feedThumbnail;
  final String rssUrl;
  final String? author;
  final List<String> categories;
  final DateTime displayTime;
  final String description;

  // uid;
  final String feedUrl;

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

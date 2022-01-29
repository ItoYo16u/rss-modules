enum RSSType { v1_0, v2_0, atom }

class RSSChannel {
  RSSChannel(
      {required this.url,
      required this.title,
      required this.link,
      required this.description,
      this.thumbnail,
      this.favicon});

  /// unique url to identify rss channel
  final String url;

  /// rss title
  final String title;

  /// link to website
  final String link;

  /// rss description
  final String description;

  @Deprecated('will be replaced with favicon. Use favicon instead')

  /// rss channel thumbnail.
  final Thumbnail? thumbnail;

  /// rss channel favicon.
  final Favicon? favicon;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'url': url,
        'title': title,
        'link': link,
        'description': description,
      };
}

class Favicon {
  Favicon({
    required this.src,
    this.title,
    this.alink,
    this.width,
    this.height,
  });
  final String? title;

  /// this src url must be valid url with image prefix
  final Uri src;
  final String? alink;
  final double? width;
  final double? height;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'url': src,
        if (title != null) ...<String, dynamic>{'title': title},
        if (alink != null) ...<String, dynamic>{'link': alink},
        if (width != null) ...<String, dynamic>{'width': width},
        if (height != null) ...<String, dynamic>{'height': height},
      };
}

class Thumbnail {
  Thumbnail({
    required this.src,
    this.title,
    this.alink,
    this.width,
    this.height,
  });
  final String? title;

  /// this src url must be valid url with image prefix
  final Uri src;
  final String? alink;
  final double? width;
  final double? height;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'url': src,
        if (title != null) ...<String, dynamic>{'title': title},
        if (alink != null) ...<String, dynamic>{'link': alink},
        if (width != null) ...<String, dynamic>{'width': width},
        if (height != null) ...<String, dynamic>{'height': height},
      };
}

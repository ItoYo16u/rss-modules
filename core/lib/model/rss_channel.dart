enum RSSType { v1_0, v2_0, atom }

class RSSChannel {
  RSSChannel({
    required this.url,
    required this.title,
    required this.link,
    required this.description,
    this.thumbnail,
  });

  final String url;
  final String title;
  final String link;
  final String description;
  final Thumbnail? thumbnail;
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
  final String src;
  final String? alink;
  final double? width;
  final double? height;
}

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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'url': url,
        'title': title,
        'link': link,
        'description': description,
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
  final String src;
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

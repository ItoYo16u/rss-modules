import 'dart:io';

import 'package:flechette/flechette.dart';
import 'package:rss_core/adaptor/xml/rss_type_compat.dart';
import 'package:rss_core/model/exceptions.dart';
import 'package:rss_core/model/rss_channel.dart';
import 'package:rss_core/model/rss_item.dart';
import 'package:xml/xml.dart';

extension Extractor on XmlElement {
  Result<String> extractStringBy(String name) =>
      attemptFirstElementBy(name).map((p0) => p0.text);

  Result<String> extractNonEmptyStringBy(String name) {
    final elms = findElements(name);
    if (elms.isEmpty) {
      return Result.failure(
        RSSParseFailures.elementNotFound,
        '$name not found',
      );
    }
    final elm = elms.first.text;
    if (elm.isEmpty) {
      return Result.failure(
        RSSParseFailures.invalidFormat,
        '$name must not be empty string, but empty string element found.',
      );
    }
    return Result.success(
      findElements(name).first.text,
    );
  }

  Result<String> extractAttrStrBy(String tagName, String attrName) {
    final elm = findFirstElementBy(tagName);
    if (elm == null) {
      return Result.failure(
          RSSParseFailures.elementNotFound, 'Element $tagName Not Found');
    }
    final attr = elm.getAttribute(attrName);
    if (attr == null) {
      return Result.failure(
          RSSParseFailures.attrNotFound, 'Attribute $attrName Not Found');
    }
    return Result.success(attr);
  }

  XmlElement? findFirstElementBy(String name) {
    final elms = findElements(name);
    if (elms.isEmpty) {
      return null;
    } else {
      return elms.first;
    }
  }

  Result<XmlElement> attemptFirstElementBy(String name) {
    final elms = findElements(name);
    if (elms.isEmpty) {
      return Result.failure(
          RSSParseFailures.elementNotFound, 'Element $name Not Found');
    } else {
      return Result.success(elms.first);
    }
  }

  Result<Uri> extractUrlBy(String name) {
    final elms = findElements(name);
    if (elms.isEmpty) {
      return Result.failure(
        RSSParseFailures.elementNotFound,
        '$name not found',
      );
    }
    final elm = elms.first.text;
    final uri = Uri.tryParse(elm);
    if (uri == null) {
      return Result.failure(
        RSSParseFailures.invalidFormat,
        'invalid format: $uri can not be parsed as Uri',
      );
    }
    return Result.success(uri);
  }

  Result<DateTime> extractDatetimeBy(String name) {
    final maybePubDate = attemptFirstElementBy(name)
        .map((p0) => p0.text.replaceAll('+0000', 'GMT'));
    if (!maybePubDate.isSuccess) {
      return Result.failure(maybePubDate.errorKey!, maybePubDate.errorMessage!);
    }
    final pubDate = maybePubDate.value!;

    try {
      // parse ISO format
      final datetime = DateTime.parse(pubDate);
      return Result.success(datetime);
    } on FormatException {
      try {
        final retryWithHTTPFormat = HttpDate.parse(pubDate);
        return Result.success(retryWithHTTPFormat);
      } on HttpException catch (_) {
        return Result.failure(
          RSSParseFailures.invalidFormat,
          'pubDate is neither ISO format nor Standard HTTP Date format.',
        );
      }
    }
  }

  Result<List<String>> extractListBy(String name) => Result.success(
        findElements(name).map((e) => e.text).toList(),
      );
}

extension FaviconExtractor on XmlElement {
  Result<Thumbnail> extractThumbnail(RSSType rssType) {
    final title = extractStringBy('title');
    final src = extractUrlBy('url');

    final alink = extractStringBy('link');
    if (title.isSuccess && src.isSuccess) {
      return Result.success(
        Thumbnail(title: title.value, src: src.value!, alink: alink.value),
      );
    }
    return Result.failure(
      RSSParseFailures.missingProperty,
      'Invalid Property: ${[
        if (!title.isSuccess) ...['title is missing or invalid'],
        if (!src.isSuccess) ...['src is missing or invalid']
      ]}',
    );
  }
}

extension ChannelExtractor on XmlElement {
  Result<RSSChannel> extractChannel(RSSType rssType, String rssUrl) {
    final title = extractStringBy('title');
    final description = extractStringBy(descriptionMapping[rssType]!);
    final link = extractStringBy('link');
    // fixme: better handling
    // only work for rss 1.0, 2.0;
    final imgElm = getElement('image');
    final atomIcon = getElement('icon');
    late final Thumbnail? thumbnail;

    if (imgElm == null) {
      // possibly atom rss.
      final maybeUri = atomIcon.map((elm) => Uri.tryParse(elm.text));
      if (maybeUri == null) {
        thumbnail = null;
      } else {
        thumbnail = Thumbnail(src: maybeUri);
      }
    } else {
      // rss 1.0 / 2.0
      thumbnail = imgElm.extractThumbnail(rssType).value;
    }

    final isValid = rssType == RSSType.atom
        ? title.isSuccess && link.isSuccess
        : title.isSuccess && description.isSuccess && link.isSuccess;
    if (isValid) {
      return Result.success(
        RSSChannel(
            url: rssUrl,
            title: title.value!,
            description: rssType == RSSType.atom
                ? description.value ?? ''
                : description.value!,
            link: link.value!,
            thumbnail: thumbnail,
            favicon: thumbnail.map((p0) => Favicon(src: p0.src))),
      );
    }
    return Result.failure(
      RSSParseFailures.missingProperty,
      'Invalid Property: ${[
        if (!title.isSuccess) ...['title is missing or invalid'],
        if (!description.isSuccess) ...['description is missing or invalid'],
        if (!link.isSuccess) ...['link is missing or invalid'],
      ]}',
    );
  }
}

extension ItemThumbnailExtractor on XmlElement {
  Thumbnail? extractItemThumbnail(RSSType rssType) {
    late Thumbnail? thumbnail;
    if (rssType == RSSType.atom) {
      const tagName = 'enclosure';
      final tpe = extractAttrStrBy(tagName, 'type');
      if (tpe.isSuccess &&
          {'image/png', 'image/jpg', 'image/jpeg'}.contains(tpe.value!)) {
        final imgUrl = extractAttrStrBy(tagName, 'url');
        if (imgUrl.isSuccess) {
          final maybeUri = Uri.tryParse(imgUrl.value!);
          if (maybeUri == null) {
            thumbnail = null;
          } else {
            thumbnail = Thumbnail(src: maybeUri);
          }
        } else {
          thumbnail = null;
        }
      } else {
        thumbnail = null;
      }
    } else {
      thumbnail = null;
    }
    return thumbnail;
  }
}

extension ItemExtractor on XmlElement {
  Result<RSSItem> extractItem(RSSChannel channel, RSSType rssType) {
    final title = extractStringBy('title');
    final description = extractStringBy(descriptionMapping[rssType]!);
    final categories = extractListBy('category');
    final url = extractStringBy('link');
    final thumbnail = extractItemThumbnail(rssType);
    final pubDate = extractDatetimeBy(pubDateMapping[rssType]!);
    if (title.isSuccess &&
        description.isSuccess &&
        url.isSuccess &&
        pubDate.isSuccess) {
      return Result.success(
        RSSItem(
          id: url.value!,
          feedTitle: channel.title,
          feedUrl: channel.link,
          rssUrl: channel.url,
          feedThumbnail: channel.thumbnail,
          feedFavicon: channel.favicon,
          thumbnail: thumbnail,
          title: title.value!,
          description: description.value!,
          url: url.value!,
          displayTime: pubDate.value!,
          categories: categories.value ?? [],
        ),
      );
    }
    return Result.failure(
      RSSParseFailures.missingProperty,
      'Invalid Property: ${[
        if (!title.isSuccess) ...['title is missing or invalid'],
        if (!description.isSuccess) ...['src is missing or invalid'],
        if (!url.isSuccess) ...['url is missing or invalid'],
        if (!pubDate.isSuccess) ...['pubDate is missing or invalid: '],
      ]}',
    );
  }
}

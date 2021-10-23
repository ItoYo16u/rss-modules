import 'dart:io';

import 'package:flechette/flechette.dart';
import 'package:rss_core/adaptor/xml/rss_type_compat.dart';
import 'package:rss_core/model/exceptions.dart';
import 'package:rss_core/model/rss_channel.dart';
import 'package:rss_core/model/rss_item.dart';
import 'package:xml/xml.dart';

extension Extractor on XmlElement {
  Result<String> extractStringBy(String name) {
    try {
      return Result.success(
        findElements(name).first.text,
      );
    } on StateError {
      return Result.failure(
          RSSParseFailures.elementNotFound, '$name not found');
    }
  }

  Result<DateTime> extractDatetimeBy(String name) {
    late String pubDate;
    final elements = findElements(name);
    if (elements.isEmpty) {
      return Result.failure(RSSParseFailures.elementNotFound, name);
    } else {
      pubDate = elements.first.text.replaceAll('+0000', 'GMT');
    }
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

  Result<List<String>> extractListBy(String name) {
    try {
      return Result.success(
        findElements(name).map((e) => e.text).toList(),
      );
    } on StateError {
      return Result.failure(
          RSSParseFailures.elementNotFound, '$name not found');
    }
  }
}

extension ThumbnailExtractor on XmlElement {
  Result<Thumbnail> extractThumbnail(RSSType rssType) {
    final title = extractStringBy('title');
    final src = extractStringBy('url');
    final alink = extractStringBy('link');
    if (title.isSuccess && src.isSuccess) {
      return Result.success(
        Thumbnail(title: title.value!, src: src.value!, alink: alink.value),
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

extension Optional<T> on T? {
  R? map<R>(R Function(T) f) {
    if (this == null) {
      return null;
    } else {
      return f(this!);
    }
  }

  R mapOr<R>(R Function(T) f, {required R or}) {
    if (this == null) {
      return or;
    } else {
      return f(this!);
    }
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
    final img = imgElm?.extractThumbnail(rssType) ??
        atomIcon.mapOr(
          (icon) => Result.success(Thumbnail(src: icon.text)),
          or: Result.failure('NEITHER_IMAGE_NOR_ICON_FOUND', ''),
        );
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
          thumbnail: img?.value,
        ),
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

extension ItemExtractor on XmlElement {
  Result<RSSItem> extractItem(RSSChannel channel, RSSType rssType) {
    final title = extractStringBy('title');
    final description = extractStringBy(descriptionMapping[rssType]!);
    final categories = extractListBy('category');
    final url = extractStringBy('link');
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
          feedThumbnail: channel.thumbnail?.src,
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

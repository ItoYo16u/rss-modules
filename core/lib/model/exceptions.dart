enum RSSParserException {
  elementNotFound,
  invalidFormat,
  attrNotFound,
  missingProperty,
  channelNotFound,
  thumbnailNotFound,
  invalidRSSType,
}

class RSSParseFailures {
  static const String elementNotFound = 'ELEMENT_NOT_FOUND';
  static const String attrNotFound = 'ATTR_NOT_FOUND';
  static const String invalidFormat = 'INVALID_FORMAT';
  static const String missingProperty = 'MISSING_PROPERTY';
  static const String channelNotFound = 'CHANNEL_NOT_FOUND';
  static const String thumbnailNotFound = 'THUMBNAIL_NOT_FOUND';
  static const String invalidRSSType = 'INVALID_RSS_TYPE';
}

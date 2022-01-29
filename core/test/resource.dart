const rss1_0 = '''
<?xml version="1.0" encoding="UTF-8"?>
<rdf:RDF xmlns="http://purl.org/rss/1.0/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:content="http://purl.org/rss/1.0/modules/content/"
    xml:lang="ja">

    <channel rdf:about="http://example.com/feed.rdf">
        <title>title</title>
        <link>http://example.com</link>
        <description>description</description>
        <items>
        <rdf:Seq>
        <rdf:li rdf:resource="http://example.com/post0.html" />
        <rdf:li rdf:resource="http://example.com/post1.html" />
        </rdf:Seq>
        </items>
    </channel>

    <item rdf:about="http://example.com/post0.html">
        <title>article0</title>
        <link>http://example.com/post0.html</link>
        <description>description</description>
        <dc:date>1999-04-23</dc:date>
    </item>
    <item rdf:about="http://example.com/post1.html">
        <title>article1</title>
        <link>http://example.com/post1.html</link>
        <description>description</description>
        <dc:date>1999-04-23 13:45:56Z</dc:date>
    </item>
    <item rdf:about="http://example.com/post2.html">
        <title>article2</title>
        <link>http://example.com/post2.html</link>
        <description>description</description>
        <dc:date>2014-06-02T00:00:00+09:00</dc:date>
    </item>
</rdf:RDF>
''';

const rss2_0 = '''
  <?xml version='1.0' encoding='UTF-8'?>
<rss version='2.0'>
    <channel>
        <title>title</title>
        <link>http://example.com/</link>
        <description>description</description>
        <image>
            <url>http://example.com/image.jpg</url>
            <title>image</title>
            <link>https://example.com</link>
        </image>
        <item>
            <title>article0</title>
            <link>http://example.com/post0.html</link>
            <description>description</description>
            <pubDate>Wed, 15 Oct 2014 22:00:59 GMT</pubDate>
        </item>
        <item>
            <title>article1</title>
            <link>http://example.com/post1.html</link>
            <description>description</description>
            <pubDate>Friday, 23-Apr-99 13:45:56 GMT</pubDate>
        </item>
        <item>
            <title>article2</title>
            <link>http://example.com/post1.html</link>
            <description>description</description>
            <pubDate>Fri Apr 23 13:45:56 1999</pubDate>
        </item>
        <item>
            <title>article3</title>
            <link>http://example.com/post1.html</link>
            <description>description</description>
            <pubDate>Fri, 23 Apr 1999 13:45:56 GMT</pubDate>
        </item>
    </channel>
</rss>
  ''';

const atom = '''
<feed xmlns='http://www.w3.org/2005/Atom' xml:lang='ja'>
    <id>https://example.com/rss/index.xml</id>
    <title>title</title>
    <icon>https://example.com/image.jpg</icon>
    <updated>2008-06-11T15:30:59Z</updated>
    <link rel='alternate' type='text/html' href='http://www.example.com/feed/' />
    <link rel='self' type='application/atom+xml' href='http://example.com/rss/index.xml' />
    <entry>
        <id>http://example.com/post0.html</id>
        <title>article0</title>
        <link rel='alternate' type='text/html' href='http://example.com/post0.html' />
        <enclosure url="https://example.com/img.png" type="image/png"/>
        <updated>2008-06-11T15:30:59Z</updated>
        <summary>summary0</summary>
    </entry>
    <entry>
        <id>http://example.com/post1.html</id>
        <title>title</title>
        <link rel='alternate' type='text/html' href='http://example.com/post1.html' />
        <updated>2008-06-10T15:30:59Z</updated>
        <summary>summary1</summary>
    </entry>
    <entry>
        <id>http://example.com/post2.html</id>
        <title>記事タイトル2</title>
        <link rel='alternate' type='text/html' href='http://phpjavascriptroom.com/post2.html' />
        <updated>2021-08-16T10:50:00-04:00</updated>
        <summary>summary2</summary>
    </entry>
</feed>''';

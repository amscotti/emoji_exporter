import std.algorithm : startsWith;
import std.array : back, split;
import std.stdio : writefln;
import std.format : format;
import std.net.curl : HTTP, get, download;
import std.path : buildPath;
import std.process : environment;
import std.exception : enforce;
import fast.json : parseJSON;

private static immutable string SLACK_API_TOKEN = "SLACK_API_TOKEN";
private static immutable string ENDPOINT = "https://slack.com/api/emoji.list";
private static immutable string DOWNLOAD = "downloads";
private static immutable string ALIAS = "alias:";
private static immutable string DOWNLOAD_TEXT = "Downloading %s";

private struct EmojiList
{
    bool ok;
    string cache_ts;
    string[string] emoji;
}

private EmojiList get_emojis(immutable string token)
{
    auto http = HTTP();
    http.addRequestHeader("Authorization", format!"Bearer %s"(token));

    auto emojiReturn = get(ENDPOINT, http).parseJSON;
    return emojiReturn.read!(EmojiList);
}

private void download_emoji(immutable string name, immutable string url, immutable string path)
{
    writefln(DOWNLOAD_TEXT, name);
    download(url, buildPath(path, format!"%s.%s"(name, url.split(".").back())));
}

void main()
{
    immutable string token = environment.get(SLACK_API_TOKEN);
    enforce(token != null, "Environment variable SLACK_API_TOKEN isn't set");

    const EmojiList e = get_emojis(token);
    foreach (string name, url; e.emoji)
    {
        if (url.startsWith(ALIAS))
        {
            continue;
        }
        download_emoji(name, url, DOWNLOAD);
    }
}

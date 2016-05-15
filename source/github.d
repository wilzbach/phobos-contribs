module contribs.github;

import std.typecons;
import std.datetime;
import contribs.formats;

alias ContributorTime = Tuple!(ContributorWithAvatar[], "contributors",
                                SysTime, "lastUpdated");
ContributorTime[string] commitCache;
Duration invalidationDur = dur!"hours"(24);

struct ContributorWithAvatar
{
    string login;
    size_t id;
    string avatar_url;
    string html_url;
}

shared string GITHUB_USER, GITHUB_PASSWORD;

private ContributorWithAvatar[] refreshEntry(string url)
{
    import requests;
    import vibe.data.json;
    import std.algorithm;
    import std.array: array;
    import std.format: format;

    import std.experimental.logger;

    GithubCommit[] commits;
    Request rq;
    import std.stdio;
    if (GITHUB_USER.length > 0)
        rq.authenticator = new BasicAuthentication(GITHUB_USER, GITHUB_PASSWORD);
    for (size_t page = 1; ; page++)
    {
        Response rs = rq.get(url ~ "&page=" ~ format("%d", page));
        if (rs.code == 200)
        {
            GithubCommit[] current_commits = deserializeJson!(GithubCommit[])(cast(string) rs.responseBody.data);
            if (current_commits.length == 0)
                break;
            else
                commits ~= current_commits;
        }
        else
        {
            if (rs.code == 403)
                warning("Rate limited reached");
            break;
        }
    }

    auto users = commits.map!`a.author`
        .map!((x) => ContributorWithAvatar(x.login, x.id, x.avatar_url, x.html_url))
        .array.sort!`a.login < b.login`().uniq.array;
    ContributorTime ct;
    ct.contributors = users;
    ct.lastUpdated = Clock.currTime();
    commitCache[url] = ct;
    return users;
}

ContributorWithAvatar[] getContributors(string repo, string file)
{
    string url = "https://api.github.com/repos/" ~ repo ~"/commits?path=" ~ file;
    if (url in commitCache)
    {
        auto entry = commitCache[url];
        if ((Clock.currTime() - entry.lastUpdated) > invalidationDur)
            return refreshEntry(url);
        else
            return entry.contributors;
    }
    else
    {
        return refreshEntry(url);
    }
}

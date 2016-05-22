module contribs.formats;

import vibe.data.json;

struct GithubCommit
{
    string sha;
    GitCommit commit;
    string url;
    string html_url;
    string comments_url;
    @optional GithubUser author;
    // committer is optional
    @optional GithubUser committer;
    struct GithubCommitParents
    {
        string sha;
        string url;
        string html_url;
    }
    @optional GithubCommitParents[] parents;
}

struct GitAuthor
{
    string name;
    string email;
    string date;
}

struct GitCommit
{
    struct GitTree
    {
        string sha;
        string url;
    }

    GitAuthor author;
    GitAuthor committer;
    string message;
    string url;
    GitTree tree;
    size_t comment_count;
}

struct GithubUser
{
    string login;
    size_t id;
    string avatar_url;
    string gravatar_id;
    string url;
    string html_url;
    string followers_url;
    string following_url;
    string gists_url;
    string starred_url;
    string subscriptions_url;
    string organizations_url;
    string repos_url;
    string events_url;
    string received_events_url;
    string type;
    bool site_admin;
}

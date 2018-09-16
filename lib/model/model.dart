// Contribution Model
class Contribution {
  final String author;
  final String category;
  final String moderator;
  final String repository;
  final int created;
  final int reviewDate;
  final bool staffPicked;
  final String title;
  final double totalPayout;
  final String url;
  final String status;

  Contribution({
    this.author,
    this.category,
    this.moderator,
    this.repository,
    this.created,
    this.reviewDate,
    this.staffPicked,
    this.title,
    this.totalPayout,
    this.url,
    this.status,
  });

  // From Json Constructor
  Contribution.fromJson(Map json)
      : author = json['author'] as String,
        // Remove any -task categories
        category = (json['category'] as String)
            .replaceFirst('-task', '')
            .replaceFirst("task-", ''),
        moderator = json['moderator'] as String,
        // Shorten Repository url for UI page.
        repository = (json['repository'] as String)
            .replaceFirst('https://github.com/', ''),
        staffPicked = json['staff_picked'] as bool,
        title = json['title'] as String,
        totalPayout = json['total_payout'] as double,
        url = json['url'] as String,
        // Unwrap Date from the json
        created = Date.fromJson(json['created']).date,
        reviewDate = Date.fromJson(json['review_date']).date,
        status = json['status'];
}

// Class to easily unwrap the date object from the Json
class Date {
  final int date;

  Date(this.date);

  Date.fromJson(Map json) : date = json['\$date'];
}

// Model for the github release [Json].  Only need [tag_name] and [html_url]
class GithubReleaseModel {
  final String tagName;
  final String htmlUrl;

  GithubReleaseModel(this.tagName, this.htmlUrl);

  GithubReleaseModel.fromJson(Map json)
      : this.tagName = json['tag_name'],
        this.htmlUrl = json['html_url'];
}

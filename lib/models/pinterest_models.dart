import 'dart:convert';

import 'package:googleapis/classroom/v1.dart';

class Pinterest {
  Pinterest({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.promotedAt,
    required this.width,
    required this.height,
    required this.color,
    required this.blurHash,
    this.description,
    required this.altDescription,
    required this.urls,
    required this.links,
    required this.categories,
    required this.likes,
    required this.likedByUser,
    required this.currentUserCollections,
    this.sponsorship,
    this.topicSubmissions,
    required this.user,
  });

  String id;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? promotedAt;
  int width;
  int height;
  String color;
  String? blurHash;
  String? description;
  dynamic altDescription;
  Urls urls;
  PinterestLinks links;
  List<dynamic> categories;
  int likes;
  bool likedByUser;
  List<dynamic> currentUserCollections;
  Sponsorship? sponsorship;
  TopicSubmissions? topicSubmissions;
  User user;

  factory Pinterest.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('results')) {
      throw ArgumentError("Invalid JSON: 'results' property is missing.");
    }

    dynamic results = json['results'];
    if (results == null) {
      throw ArgumentError("Invalid JSON: 'results' property is null.");
    }

    if (results is List<dynamic>) {
      List<Pinterest> photos =
          results.map((x) => Pinterest.fromJson(x)).toList();
      return photos.first;
    }

    return Pinterest(
      id: json["id"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      promotedAt: json["promoted_at"] != null
          ? DateTime.parse(json["promoted_at"])
          : null,
      width: json["width"],
      height: json["height"],
      color: json["color"],
      blurHash: json["blur_hash"],
      description: json["description"],
      altDescription: json["alt_description"],
      urls: Urls.fromJson(json["urls"] ?? {}),
      links: PinterestLinks.fromJson(json["links"] ?? {}),
      categories: List<dynamic>.from(json["categories"] ?? []),
      likes: json["likes"],
      likedByUser: json["liked_by_user"],
      currentUserCollections:
          List<dynamic>.from(json["current_user_collections"] ?? []),
      sponsorship: json["sponsorship"] != null
          ? Sponsorship.fromJson(json["sponsorship"])
          : null,
      topicSubmissions: json["topic_submissions"] != null
          ? TopicSubmissions.fromJson(json["topic_submissions"])
          : null,
      user: User.fromJson(json["user"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "promoted_at": promotedAt?.toIso8601String(),
      "width": width,
      "height": height,
      "color": color,
      "blur_hash": blurHash,
      "description": description,
      "alt_description": altDescription,
      "urls": urls.toJson(),
      "links": links.toJson(),
      "categories": categories,
      "likes": likes,
      "liked_by_user": likedByUser,
      "current_user_collections": currentUserCollections,
      "sponsorship": sponsorship?.toJson(),
      "topic_submissions": topicSubmissions?.toJson(),
      "user": user.toJson(),
    };
  }
}

class TopicSubmissions {
  List<TopicSubmission> submissions;

  TopicSubmissions({
    required this.submissions,
  });

  factory TopicSubmissions.fromJson(List<dynamic> json) {
    List<TopicSubmission> submissions = json
        .map((submissionJson) => TopicSubmission.fromJson(submissionJson))
        .toList();

    return TopicSubmissions(submissions: submissions);
  }

  List<dynamic> toJson() {
    return submissions.map((submission) => submission.toJson()).toList();
  }
}

class TopicSubmission {
  String status;
  Topic topic;

  TopicSubmission({
    required this.status,
    required this.topic,
  });

  factory TopicSubmission.fromJson(Map<String, dynamic> json) {
    return TopicSubmission(
      status: json['status'],
      topic: Topic.fromJson(json['topic']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'topic': topic.toJson(),
    };
  }
}

class Urls {
  Urls({
    required this.raw,
    required this.full,
    required this.regular,
    required this.small,
    required this.thumb,
  });

  String raw;
  String full;
  String regular;
  String small;
  String thumb;

  factory Urls.fromJson(Map<String, dynamic> json) => Urls(
        raw: json["raw"],
        full: json["full"],
        regular: json["regular"],
        small: json["small"],
        thumb: json["thumb"],
      );

  Map<String, dynamic> toJson() => {
        "raw": raw,
        "full": full,
        "regular": regular,
        "small": small,
        "thumb": thumb,
      };
}

class PinterestLinks {
  PinterestLinks({
    required this.self,
    required this.html,
    required this.download,
    required this.downloadLocation,
  });

  String self;
  String html;
  String download;
  String downloadLocation;

  factory PinterestLinks.fromJson(Map<String, dynamic> json) => PinterestLinks(
        self: json["self"],
        html: json["html"],
        download: json["download"],
        downloadLocation: json["download_location"],
      );

  Map<String, dynamic> toJson() => {
        "self": self,
        "html": html,
        "download": download,
        "download_location": downloadLocation,
      };
}

class Sponsorship {
  Sponsorship({
    required this.impressionUrls,
    this.tagline,
    this.taglineUrl,
    required this.sponsor,
  });

  List<String> impressionUrls;
  String? tagline;
  String? taglineUrl;
  User sponsor;

  factory Sponsorship.fromJson(Map<String, dynamic> json) => Sponsorship(
        impressionUrls:
            List<String>.from(json["impression_urls"].map((x) => x)),
        tagline: json["tagline"],
        taglineUrl: json["tagline_url"],
        sponsor: User.fromJson(json["sponsor"]),
      );

  Map<String, dynamic> toJson() => {
        "impression_urls": List<dynamic>.from(impressionUrls.map((x) => x)),
        "tagline": tagline,
        "tagline_url": taglineUrl,
        "sponsor": sponsor.toJson(),
      };
}

class User {
  User({
    required this.id,
    required this.updatedAt,
    required this.username,
    required this.name,
    required this.firstName,
    this.lastName,
    this.twitterUsername,
    this.portfolioUrl,
    this.bio,
    this.location,
    required this.links,
    required this.profileImage,
    this.instagramUsername,
    required this.totalCollections,
    required this.totalLikes,
    required this.totalPhotos,
    required this.acceptedTos,
    required this.forHire,
    required this.social,
  });

  String id;
  DateTime updatedAt;
  String username;
  String name;
  String firstName;
  String? lastName;
  String? twitterUsername;
  String? portfolioUrl;
  String? bio;
  String? location;
  UserLinks links;
  ProfileImage profileImage;
  String? instagramUsername;
  int totalCollections;
  int totalLikes;
  int totalPhotos;
  bool acceptedTos;
  bool forHire;
  Social social;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        updatedAt: DateTime.parse(json["updated_at"]),
        username: json["username"],
        name: json["name"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        twitterUsername: json["twitter_username"],
        portfolioUrl: json["portfolio_url"],
        bio: json["bio"],
        location: json["location"],
        links: UserLinks.fromJson(json["links"]),
        profileImage: ProfileImage.fromJson(json["profile_image"]),
        instagramUsername: json["instagram_username"],
        totalCollections: json["total_collections"],
        totalLikes: json["total_likes"],
        totalPhotos: json["total_photos"],
        acceptedTos: json["accepted_tos"],
        forHire: json["for_hire"],
        social: Social.fromJson(json["social"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "updated_at": updatedAt.toIso8601String(),
        "username": username,
        "name": name,
        "first_name": firstName,
        "last_name": lastName,
        "twitter_username": twitterUsername,
        "portfolio_url": portfolioUrl,
        "bio": bio,
        "location": location,
        "links": links.toJson(),
        "profile_image": profileImage.toJson(),
        "instagram_username": instagramUsername,
        "total_collections": totalCollections,
        "total_likes": totalLikes,
        "total_photos": totalPhotos,
        "accepted_tos": acceptedTos,
        "for_hire": forHire,
        "social": social.toJson(),
      };
}

class UserLinks {
  UserLinks({
    required this.self,
    required this.html,
    required this.photos,
    required this.likes,
    required this.portfolio,
    required this.following,
    required this.followers,
  });

  String self;
  String html;
  String photos;
  String likes;
  String portfolio;
  String following;
  String followers;

  factory UserLinks.fromJson(Map<String, dynamic> json) => UserLinks(
        self: json["self"],
        html: json["html"],
        photos: json["photos"],
        likes: json["likes"],
        portfolio: json["portfolio"],
        following: json["following"],
        followers: json["followers"],
      );

  Map<String, dynamic> toJson() => {
        "self": self,
        "html": html,
        "photos": photos,
        "likes": likes,
        "portfolio": portfolio,
        "following": following,
        "followers": followers,
      };
}

class ProfileImage {
  ProfileImage({
    required this.small,
    required this.medium,
    required this.large,
  });

  String small;
  String medium;
  String large;

  factory ProfileImage.fromJson(Map<String, dynamic> json) => ProfileImage(
        small: json["small"],
        medium: json["medium"],
        large: json["large"],
      );

  Map<String, dynamic> toJson() => {
        "small": small,
        "medium": medium,
        "large": large,
      };
}

class Social {
  Social({
    required this.instagramUsername,
    required this.portfolioUrl,
    required this.twitterUsername,
  });

  String? instagramUsername;
  String? portfolioUrl;
  String? twitterUsername;

  factory Social.fromJson(Map<String, dynamic> json) => Social(
        instagramUsername: json["instagram_username"],
        portfolioUrl: json["portfolio_url"],
        twitterUsername: json["twitter_username"],
      );

  Map<String, dynamic> toJson() => {
        "instagram_username": instagramUsername,
        "portfolio_url": portfolioUrl,
        "twitter_username": twitterUsername,
      };
}

Pinterest postFromJson(String str) => Pinterest.fromJson(json.decode(str));

String postToJson(Pinterest data) => json.encode(data.toJson());

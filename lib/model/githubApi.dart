import 'dart:async';
import 'dart:convert';

import 'package:utopian_rocks/model/model.dart';

import 'package:http/http.dart' show Client, Response;

class GithubApi {
  final Client _client = Client();
  static const String _url =
      'https://api.github.com/repos/tensor-programming/utopian-rocks-mobile/releases';

  Future<GithubReleaseModel> getReleases() async {
    List<GithubReleaseModel> items = [];

    await _client
        .get(Uri.parse(_url))
        .then((Response res) => res.body)
        .then(json.decode)
        .then((j) => j.forEach((Map<String, dynamic> contribution) =>
            items.add(GithubReleaseModel.fromJson(contribution))));

    return items.first;
  }
}

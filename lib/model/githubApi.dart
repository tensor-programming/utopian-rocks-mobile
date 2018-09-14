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

    Response res = await _client.get(Uri.parse(_url));
    List map = json.decode(res.body);
    var x = map.map((gh) => GithubReleaseModel.fromJson(gh)).toList();
    return x.first;
  }
}

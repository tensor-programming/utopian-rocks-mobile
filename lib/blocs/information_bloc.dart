import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:package_info/package_info.dart';

import 'package:utopian_rocks/model/githubApi.dart';
import 'package:utopian_rocks/model/model.dart';

class InformationBloc {
  Future<PackageInfo> packageInfo;
  GithubApi api;

  // Package info stream
  Stream<PackageInfo> _infoStream = Stream.empty();
  Stream<GithubReleaseModel> _releases = Stream.empty();

  Stream<PackageInfo> get infoStream => _infoStream;
  Stream<GithubReleaseModel> get releases => _releases;

  // BLoc that serves package information to the information drawer.
  // Bloc gets Github release information only on application start.
  InformationBloc(this.packageInfo, this.api) {
    _infoStream = Observable.fromFuture(packageInfo).asBroadcastStream();
    // release information is served as a normal stream which can only be subscribed to once.
    // This stream also only has one element in it. This is done to stop from overflowing the Github API.
    _releases = Observable.fromFuture(api.getReleases()).asBroadcastStream();
  }
}

import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:package_info/package_info.dart';

class InformationBloc {
  Future<PackageInfo> packageInfo;

  // Package info stream
  Stream<PackageInfo> _infoStream = Stream.empty();

  Stream<PackageInfo> get infoStream => _infoStream;

  // BLoc that serves connectivity information and package information to the information drawer.
  InformationBloc(this.packageInfo) {
    _infoStream = Observable.fromFuture(packageInfo).asBroadcastStream();
  }
}

import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:package_info/package_info.dart';
import 'package:connectivity/connectivity.dart';

class InformationBloc {
  final Future<PackageInfo> packageInfo;
  final Future<ConnectivityResult> connectivity;

  // Package info stream
  Stream<PackageInfo> _infoStream = Stream.empty();
  // Connection result stream
  Stream<ConnectivityResult> _connectionStream = Stream.empty();

  Stream<PackageInfo> get infoStream => _infoStream;
  Stream<ConnectivityResult> get connectionInfo => _connectionStream;

  // BLoc that serves connectivity information and package information to the information drawer.
  InformationBloc(this.packageInfo, this.connectivity) {
    _infoStream = Observable.fromFuture(packageInfo).asBroadcastStream();
    _connectionStream = Observable.fromFuture(connectivity).asBroadcastStream();
  }
}

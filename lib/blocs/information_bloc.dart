import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:package_info/package_info.dart';
import 'package:connectivity/connectivity.dart';

class InformationBloc {
  final Future<PackageInfo> packageInfo;
  final Future<ConnectivityResult> connectivity;

  Stream<PackageInfo> _infoStream = Stream.empty();
  Stream<ConnectivityResult> _connectionStream = Stream.empty();

  Stream<PackageInfo> get infoStream => _infoStream;
  Stream<ConnectivityResult> get connectionInfo => _connectionStream;

  InformationBloc(this.packageInfo, this.connectivity) {
    _infoStream = Observable.fromFuture(packageInfo).asBroadcastStream();
    _connectionStream = Observable.fromFuture(connectivity).asBroadcastStream();
  }
}

import 'dart:async';
import 'package:utopian_rocks/model/model.dart';
import 'package:utopian_rocks/model/repository.dart';
import 'package:utopian_rocks/model/htmlParser.dart';
import 'package:rxdart/rxdart.dart';

import 'package:utopian_rocks/utils/utils.dart' as utils;

// Contribution buisness logic class
class ContributionBloc {
  final Api api;
  final ParseWebsite parseWebsite;

  // setup an empty stream for the results
  Stream<List<Contribution>> _results = Stream.empty();
  Stream<String> _voteCount = Stream.empty();
  Stream<int> _timer = Stream.empty();
  // BehaviorSubject allows seeding the tabname data to pending.
  // Tagname is the name of the tab and modifier for the contributions
  BehaviorSubject<String> _tabname =
      BehaviorSubject<String>(seedValue: 'pending');
  // Stream<String> _log = Stream.empty();

  BehaviorSubject<String> _filter = BehaviorSubject<String>(seedValue: 'all');

  Stream<List<Contribution>> get results => _results;
  Stream<String> get voteCount => _voteCount;
  Stream<int> get timer => _timer;

  Sink<String> get tabname => _tabname;
  Sink<String> get filter => _filter;

  ContributionBloc(this.api, this.parseWebsite) {
    _results = _tabname
        // Debounce to account for latency
        .debounce(Duration(milliseconds: 300))
        // Apply the api updateContributions function to tabname stream to get results.
        .asyncMap(api.updateContributions)
        .asyncMap(applyFilter)
        .asBroadcastStream();

    _voteCount = Observable.fromFuture(
      parseWebsite.getVotePower(),
    ).asBroadcastStream();

    _timer = Observable.periodic(Duration(seconds: 1), (x) => x)
        .asyncMap(parseWebsite.getTimer)
        .asBroadcastStream();
  }

  void dispose() {
    _tabname.close();
    _filter.close();
  }

  Future<List<Contribution>> applyFilter(
      List<Contribution> contributions) async {
    var filter = await _filter.stream.first ?? 'all';
    var tabname = await _tabname.stream.first;

    var cons = contributions;

    _tabname.add(tabname);
    if (filter != 'all') {
      cons.removeWhere((c) => c.category != filter);
      return cons;
    }
    return cons;
  }
}

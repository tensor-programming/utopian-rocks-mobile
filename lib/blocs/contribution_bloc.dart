import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:utopian_rocks/model/model.dart';
import 'package:utopian_rocks/model/repository.dart';
import 'package:utopian_rocks/model/html_parser.dart';
import 'package:utopian_rocks/utils/utils.dart';

// Contribution buisness logic class
class ContributionBloc {
  final Api api;
  final ParseWebsite parseWebsite;

  // setup an empty streams for results, filteredResults, voteCount and timer.
  Stream<List<Contribution>> _results = Stream.empty();
  Observable<List<Contribution>> _filteredResults = Observable.empty();
  Stream<String> _voteCount = Stream.empty();
  Stream<int> _timer = Stream.empty();

  // BehaviorSubject allows seeding the tabIndex data to unreviewed.
  // Tagname is the name of the tab and modifier for the contributions
  BehaviorSubject<String> _tabName =
      BehaviorSubject<String>(seedValue: 'unreviewed');
  // BehaviorSubject for the filter, seeded to 'all' by default.
  BehaviorSubject<String> _filter = BehaviorSubject<String>(seedValue: 'all');

  // getters for the streams.
  Stream<List<Contribution>> get results => _results;
  Stream<List<Contribution>> get filteredResults => _filteredResults;
  Stream<String> get voteCount => _voteCount;
  Stream<int> get timer => _timer;

  // getters for the sinks.
  Sink<String> get tabName => _tabName;
  Sink<String> get filter => _filter;

  ContributionBloc(this.api, this.parseWebsite) {
    // get results by putting a new tabname into the tabname [Sink]
    _results = _tabName
        // Apply the api updateContributions function to tabIndex stream to get results.
        .asyncMap(api.updateContributions)
        .asBroadcastStream();
    // Combine the Filter Sink and the results stream with the ApplyFilter to create a filtered list of Contributions.
    _filteredResults = Observable.combineLatest2(_filter, _results, applyFilter)
        .asBroadcastStream();

    // put vote count into observable and feed it to the UI.
    _voteCount =
        Observable.fromFuture(parseWebsite.getVotePower()).asBroadcastStream();

    // increment timer by emitting stream every second.
    _timer = Observable.periodic(Duration(seconds: 1), (x) => x)
        .asyncMap(parseWebsite.getTimer)
        .asBroadcastStream();
  }

  void dispose() {
    _tabName.close();
    _filter.close();
  }
}

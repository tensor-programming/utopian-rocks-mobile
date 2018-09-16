import 'dart:async';
import 'package:utopian_rocks/model/model.dart';
import 'package:utopian_rocks/model/repository.dart';
import 'package:utopian_rocks/model/htmlParser.dart';
import 'package:utopian_rocks/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

// Contribution buisness logic class
class ContributionBloc {
  final Api api;
  final ParseWebsite parseWebsite;

  // setup an empty stream for the results
  Stream<List<Contribution>> _results = Stream.empty();
  Observable<List<Contribution>> _filteredResults = Observable.empty();
  Stream<String> _voteCount = Stream.empty();
  Stream<int> _timer = Stream.empty();
  // BehaviorSubject allows seeding the tabIndex data to pending.
  // Tagname is the name of the tab and modifier for the contributions
  BehaviorSubject<String> _tabName =
      BehaviorSubject<String>(seedValue: 'unreviewed');
  // Stream<String> _log = Stream.empty();

  BehaviorSubject<String> _filter = BehaviorSubject<String>(seedValue: 'all');

  Stream<List<Contribution>> get results => _results;
  Observable<List<Contribution>> get filteredResults => _filteredResults;
  Stream<String> get voteCount => _voteCount;
  Stream<int> get timer => _timer;

  Sink<String> get tabName => _tabName;
  Sink<String> get filter => _filter;

  ContributionBloc(this.api, this.parseWebsite) {
    _results = _tabName

        // Apply the api updateContributions function to tabIndex stream to get results.
        .asyncMap(api.updateContributions)
        .asBroadcastStream();

    _filteredResults = Observable.combineLatest2(_filter, _results, applyFilter)
        .asBroadcastStream();

    _voteCount = Observable.fromFuture(
      parseWebsite.getVotePower(),
    ).asBroadcastStream();

    _timer = Observable.periodic(Duration(seconds: 1), (x) => x)
        .asyncMap(parseWebsite.getTimer)
        .asBroadcastStream();
  }

  void dispose() {
    _tabName.close();
    _filter.close();
  }
}

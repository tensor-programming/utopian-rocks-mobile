import 'dart:async';
import 'package:utopian_rocks/model/model.dart';
import 'package:utopian_rocks/model/repository.dart';
import 'package:rxdart/rxdart.dart';

// Contribution buisness logic class
class ContributionBloc {
  final Api api;

  // setup an empty stream for the results
  Stream<List<Contribution>> _results = Stream.empty();
  // BehaviorSubject allows seeding the tabname data to pending.
  // Tagname is the name of the tab and modifier for the contributions
  BehaviorSubject<String> _tabname =
      BehaviorSubject<String>(seedValue: 'pending');
  // Stream<String> _log = Stream.empty();

  Stream<List<Contribution>> get results => _results;
  Sink<String> get tabname => _tabname;
  // Stream<String> get log => _log;

  ContributionBloc(this.api) {
    _results = _tabname
        // Debounce to account for latency
        .debounce(Duration(milliseconds: 300))
        // Apply the api updateContributions function to tabname stream to get results.
        .asyncMap(api.updateContributions)
        .asBroadcastStream();

    // _log = Observable(results)
    //     .withLatestFrom(_tabname.stream, (_, tabname) => 'results for $tabname')
    //     .asBroadcastStream();
  }

  void dispose() {
    _tabname.close();
  }
}

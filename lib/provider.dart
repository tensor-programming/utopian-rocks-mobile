import 'package:utopian_rocks/repository.dart';

import 'package:flutter/widgets.dart';

import 'package:utopian_rocks/bloc.dart';

// Provider provides bloc to the widget tree where we need it by using the [InheritedWidget] class.
class ContributionProvider extends InheritedWidget {
  final ContributionBloc contributionBloc;

  // Always replace the old [InheritedWidget] with a new one if it is removed.
  @override
  updateShouldNotify(InheritedWidget oldwidget) => true;

  // static method to get the bloc using the build context.
  static ContributionBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(ContributionProvider)
              as ContributionProvider)
          .contributionBloc;

  // setup the bloc and the API in this constructor
  ContributionProvider({
    Key key,
    ContributionBloc contributionBloc,
    Widget child,
  })  : this.contributionBloc = contributionBloc ?? ContributionBloc(Api()),
        super(child: child, key: key);
}

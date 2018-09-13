import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';
import 'package:connectivity/connectivity.dart';

import 'package:utopian_rocks/blocs/information_bloc.dart';

// Provider for the [InformationBloc]
class InformationProvider extends InheritedWidget {
  final InformationBloc informationBloc;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static InformationBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(InformationProvider)
              as InformationProvider)
          .informationBloc;

  InformationProvider({
    Key key,
    InformationBloc informationBloc,
    Widget child,
  })  : this.informationBloc = informationBloc ??
            InformationBloc(
              PackageInfo.fromPlatform(),
              Connectivity().checkConnectivity(),
            ),
        super(
          key: key,
          child: child,
        );
}

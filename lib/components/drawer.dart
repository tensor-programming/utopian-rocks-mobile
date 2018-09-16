import 'package:flutter/material.dart';
import 'package:utopian_rocks/providers/information_provider.dart';

import 'package:url_launcher/url_launcher.dart';

class InformationDrawer extends StatelessWidget {
  final AsyncSnapshot infoStreamSnapshot;

  InformationDrawer(this.infoStreamSnapshot);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      semanticLabel: 'Information Drawer',
      child: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          _buildInfoPanel(context),

          Center(
            child: Image.asset('assets/images/utopian-icon.png'),
          ),
          // _buildConnectionPanel(informationBloc),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, {String subtitle}) {
    return ListTile(
      title: Text(
        title,
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle ?? '',
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoPanel(BuildContext context) {
    if (!infoStreamSnapshot.hasData) {
      return Flexible(
        child: CircularProgressIndicator(),
      );
    }
    return Flex(
      direction: Axis.vertical,
      children: [
        Container(
          padding: EdgeInsets.only(top: 30.0),
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Information',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        _buildInfoTile(
          '${infoStreamSnapshot.data.appName}',
          subtitle:
              "Pre-release Version Number: ${infoStreamSnapshot.data.version}",
        ),
        _buildInfoTile(
          'Instructions: ',
          subtitle: 'Double tab on a contribution to open it in a Browser',
        ),
        _buildInfoTile(
          'Author & Application Info',
          subtitle:
              'Developed by @Tensor. Many thanks to @Amosbastian for creating the original website: utopian.rocks and to the folks over at utopian.io',
        ),
        RaisedButton(
          child: Text('Check for Update'),
          onPressed: () => _getNewRelease(context),
        ),
      ],
    );
  }

  _getNewRelease(BuildContext context) {
    final informationBloc = InformationProvider.of(context);
    informationBloc.releases.listen((releases) {
      if (infoStreamSnapshot.data.version.toString() != releases.tagName) {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                  title: Text('${infoStreamSnapshot.data.appName}'),
                  content: Container(
                    child: Text(
                        'A new version of this application is available to download. The current version is ${infoStreamSnapshot.data.version} and the new version is ${releases.tagName}'),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Download'),
                      onPressed: () => _launchUrl(releases.htmlUrl),
                    ),
                    FlatButton(
                      child: Text('Close'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ));
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('${infoStreamSnapshot.data.appName}'),
                  content: Container(
                    child: Text('There is no new version at this time'),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Close'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ));
      }
    });
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      print('Launching: $url');
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}

import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

import 'package:http/http.dart' as http;

import 'dart:async';

class ParseWebsite {
  http.Client _client = http.Client();

  static Document document;
  static Duration duration;

  static final _url = "https://utopian.rocks/queue";

  Future<Document> getHtml() async {
    Document htmlString;
    await _client
        .get(Uri.parse(_url))
        .then((res) => res.body)
        .then((html) => parse(html))
        .then((html) => htmlString = html);

    return htmlString;
  }

  Future<String> getVotePower() async {
    String votePower;
    document = await getHtml();

    votePower = document.getElementById('current-vp').innerHtml;

    return votePower;
  }

  Future<int> getTimer(int incomingTimer) async {
    String time;
    int duration;

    if (document == null) {
      document = await getHtml();
    }

    time = document.getElementById('time').innerHtml;

    List<String> clock = time.split(':');
    var hours = int.parse(clock[0]) * 60 * 60;
    var minutes = int.parse(clock[1]) * 60;
    var seconds = int.parse(clock[2]);

    duration = (hours + minutes + seconds) - incomingTimer;
    return duration;
  }
}

import 'package:flutter/material.dart';

import 'package:utopian_rocks/model/model.dart';

const categories = [
  'ideas',
  'development',
  'bug-hunting',
  'translations',
  'graphics',
  'analysis',
  'documentation',
  'tutorials',
  'video-tutorials',
  'copywriting',
  'blog',
  'social',
  'all',
];

// a list of the Utopian Color hexidecimal codes.
const colors = <String, Color>{
  'ideas': Color(0xFF4DD39F),
  'development': Color(0xFF000000),
  'bug-hunting': Color(0xffdb524c),
  'translations': Color(0xffffcf26),
  'graphics': Color(0xfff8a700),
  'analysis': Color(0xff174265),
  'documentation': Color(0xffa0a0a0),
  'tutorials': Color(0xFF792a51),
  'video-tutorials': Color(0xFFec3424),
  'copywriting': Color(0xFF007f80),
  'blog': Color(0xff0275d8),
  'social': Color(0xff7bc0f5),
  'all': Color(0xff3237c9),
};

// A list of the Utopian Icon font codes.
const icons = <String, int>{
  'ideas': 0x0049,
  'development': 0x0046,
  'bug-hunting': 0x0043,
  'translations': 0x004a,
  'graphics': 0x0045,
  'analysis': 0x0041,
  'documentation': 0x0047,
  'tutorials': 0x004b,
  'video-tutorials': 0x0048,
  'copywriting': 0x0044,
  'blog': 0x0042,
  'social': 0x004c,
  'all': 0x004e
};

// Vote wieghts for Utopian vote based on Category
const voteWieghts = <String, double>{
  "ideas": 20.0,
  "development": 55.0,
  "bug-hunting": 13.0,
  "translations": 35.0,
  "graphics": 40.0,
  "analysis": 45.0,
  "social": 30.0,
  "documentation": 30.0,
  "tutorials": 30.0,
  "video-tutorials": 35.0,
  "copywriting": 30.0,
  "blog": 30.0,
};

const statuses = [
  "unreviewed",
  "pending",
];

// Get Color based on Category String
Color getCategoryColor(AsyncSnapshot snapshot, int index) {
  return colors[snapshot.data[index].category];
}

// Get Icon based on Category String
int getIcon(AsyncSnapshot snapshot, int index) {
  return icons[snapshot.data[index].category];
}

List<Contribution> applyFilter(
  String filter,
  List<Contribution> contributions,
) {
  if (filter != 'all') {
    return contributions.where((c) => c.category == filter).toList();
  }
  return contributions;
}

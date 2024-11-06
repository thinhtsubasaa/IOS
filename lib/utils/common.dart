// Find item in the list by id
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

findById(String id, List list) {
  return list.firstWhere((item) => item.id == id);
}

// Replace error string
replaceErrorString(String str) {
  str.replaceAll("^", "").trim();
  str = str
      .replaceAll("FormatException: Unexpected character (at character 1)", "")
      .trim();

  return str;
}

// Convert to json string from List<Map<dynamic>> use to test
convertListToJsonString(List<Map<String, dynamic>> data) {
  return json.encode(List<dynamic>.from(data.map((item) => jsonEncode(item))));
}

// Random number
int randomNumber(int min, int max) {
  Random rnd;
  rnd = Random();
  return min + rnd.nextInt(max - min);
}

// Calculate new image scale
Size imageScale(double width) {
  return Size(width, 100);
}

bool validUrl(String url) {
  return Uri.parse(url).isAbsolute;
}

// Limit string return
String textLimit(String text, int limitNumber) {
  return text.substring(0, limitNumber);
}

// set local value
void setLocalValue(key, value, type) async {
  SharedPreferences? sp = await SharedPreferences.getInstance();
  if (type == 'bool') {
    sp.setBool(key, value);
  }
  if (type == 'string') {
    sp.setString(key, value);
  }
  if (type == 'double') {
    sp.setDouble(key, value);
  }
}

getLocalValue(key, type) async {
  SharedPreferences? sp = await SharedPreferences.getInstance();
  var value;
  if (type == 'bool') {
    value = sp.getBool(key) ?? false;
  }
  if (type == 'string') {
    value = sp.getString(key);
  }
  if (type == 'double') {
    value = sp.getDouble(key);
  }
  return value;
}

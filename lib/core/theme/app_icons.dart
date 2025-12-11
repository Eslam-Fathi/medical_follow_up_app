import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import '../platform/app_platform.dart';

class AppIcons {
  // ----- NAVIGATION -----

  static IconData get home =>
      AppPlatform.isWeb ? Icons.home_outlined : FeatherIcons.home;

  static IconData get homeFilled =>
      AppPlatform.isWeb ? Icons.home : FeatherIcons.home;

  static IconData get calendar =>
      AppPlatform.isWeb ? Icons.calendar_today_outlined : FeatherIcons.calendar;

  static IconData get calendarFilled =>
      AppPlatform.isWeb ? Icons.calendar_today : FeatherIcons.calendar;

  static IconData get profile =>
      AppPlatform.isWeb ? Icons.person_outline : FeatherIcons.user;

  static IconData get profileFilled =>
      AppPlatform.isWeb ? Icons.person : FeatherIcons.user;

  static IconData get reports =>
      AppPlatform.isWeb ? Icons.description_outlined : FeatherIcons.fileText;

  static IconData get reportsFilled =>
      AppPlatform.isWeb ? Icons.description : FeatherIcons.fileText;

  // ----- ACTIONS -----

  static IconData get search =>
      AppPlatform.isWeb ? Icons.search : FeatherIcons.search;

  static IconData get filter =>
      AppPlatform.isWeb ? Icons.tune : FeatherIcons.sliders;

  static IconData get notifications => AppPlatform.isWeb
      ? Icons.notifications_none
      : FeatherIcons.bell;

  static IconData get menu =>
      AppPlatform.isWeb ? Icons.menu : FeatherIcons.menu;

  static IconData get settings => AppPlatform.isWeb
      ? Icons.settings_outlined
      : FeatherIcons.settings;

  static IconData get heart =>
      AppPlatform.isWeb ? Icons.favorite_border : FeatherIcons.heart;

  static IconData get heartFilled =>
      AppPlatform.isWeb ? Icons.favorite : FeatherIcons.heart;

  static IconData get star =>
      AppPlatform.isWeb ? Icons.star_border : FeatherIcons.star;

  static IconData get starFilled =>
      AppPlatform.isWeb ? Icons.star : FeatherIcons.star;

  static IconData get arrowRight =>
      AppPlatform.isWeb ? Icons.arrow_forward : FeatherIcons.arrowRight;

  // ----- STATUS -----

  static IconData get activity => AppPlatform.isWeb
      ? Icons.monitor_heart_outlined
      : FeatherIcons.activity;

  static IconData get clock =>
      AppPlatform.isWeb ? Icons.access_time : FeatherIcons.clock;

  static IconData get checkCircle => AppPlatform.isWeb
      ? Icons.check_circle_outline
      : FeatherIcons.checkCircle;

  static IconData get alertCircle => AppPlatform.isWeb
      ? Icons.error_outline
      : FeatherIcons.alertCircle;

  static IconData get info =>
      AppPlatform.isWeb ? Icons.info_outline : FeatherIcons.info;

  // ----- LOCATION / COMMUNICATION -----

  static IconData get mapPin =>
      AppPlatform.isWeb ? Icons.place_outlined : FeatherIcons.mapPin;

  static IconData get phone =>
      AppPlatform.isWeb ? Icons.phone_in_talk_outlined : FeatherIcons.phone;
}

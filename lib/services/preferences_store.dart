import 'package:flutter/foundation.dart';

/// Session preferences only; these do not enforce backend restrictions.
class PreferencesStore {
  PreferencesStore._();
  static final notifications = ValueNotifier<bool>(true);
  static final privateAccount = ValueNotifier<bool>(false);
  static final allowComments = ValueNotifier<bool>(true);
  static final allowSharing = ValueNotifier<bool>(true);
  static final activityStatus = ValueNotifier<bool>(true);
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores read notification IDs independently of the current login session.
class NoticeReadState {
  NoticeReadState({
    Future<List<String>?> Function()? load,
    Future<void> Function(List<String>)? save,
  }) : _load =
           load ??
           (() => SharedPreferencesAsync().getStringList(
             'riyal.read_notifications.v1',
           )),
       _save =
           save ??
           ((ids) => SharedPreferencesAsync().setStringList(
             'riyal.read_notifications.v1',
             ids,
           ));
  final Future<List<String>?> Function() _load;
  final Future<void> Function(List<String>) _save;
  final hasUnread = ValueNotifier(false);
  final Set<String> _read = {};
  Set<String> _current = {};
  Future<void>? _loading;
  Future<void> _writes = Future.value();
  bool _ready = false;

  bool _restored = false;
  Future<void> initialize() {
    if (_restored) return Future.value();
    return _loading ??= _restore().whenComplete(() => _loading = null);
  }

  Future<void> _restore() async {
    try {
      _read.addAll(await _load().timeout(const Duration(seconds: 3)) ?? []);
      _restored = true;
    } catch (error) {
      debugPrint('Notification read-state load failed: $error');
    }
    _ready = true;
    _update();
  }

  void updateIds(Iterable<String> ids) {
    _current = ids.toSet();
    _update();
  }

  void _update() {
    // Avoid a red flash before previously read IDs have loaded.
    hasUnread.value = _ready && _current.any((id) => !_read.contains(id));
  }

  Future<void> markOpened() async {
    // Clear the dot immediately; storage must never block opening the inbox.
    _read.addAll(_current);
    _ready = true;
    _update();
    await initialize();
    // Do not overwrite older saved IDs when loading storage has failed.
    if (!_restored) return;
    final snapshot = _read.toList();
    _writes = _writes.then((_) async {
      try {
        await _save(snapshot).timeout(const Duration(seconds: 3));
      } catch (error) {
        debugPrint('Notification read-state save failed: $error');
      }
    });
    await _writes;
  }
}

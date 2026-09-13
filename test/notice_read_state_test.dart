import 'package:flutter_test/flutter_test.dart';
import 'package:riyal/data/notice_read_state.dart';

void main() {
  test(
    'Read state survives a fresh session and only new IDs restore the dot',
    () async {
      var disk = <String>[];
      NoticeReadState session() => NoticeReadState(
        load: () async => List.of(disk),
        save: (ids) async {
          disk = List.of(ids);
        },
      );
      final first = session();
      first.updateIds(['demo-netflix', 'reminder-electricity']);
      await first.initialize();
      expect(first.hasUnread.value, isTrue);
      await first.markOpened();
      expect(first.hasUnread.value, isFalse);
      final next = session();
      next.updateIds(['demo-netflix', 'reminder-electricity']);
      await next.initialize();
      expect(next.hasUnread.value, isFalse);
      next.updateIds(['demo-netflix', 'reminder-electricity', 'new-staff']);
      expect(next.hasUnread.value, isTrue);
      await next.markOpened();
      expect(next.hasUnread.value, isFalse);
      final last = session();
      last.updateIds(['demo-netflix', 'reminder-electricity', 'new-staff']);
      await last.initialize();
      expect(last.hasUnread.value, isFalse);
    },
  );
  test(
    'Storage failure does not block opening and later attempts can recover',
    () async {
      var fail = true;
      var writes = 0;
      final state = NoticeReadState(
        load: () async {
          if (fail) throw StateError('Unavailable plugin');
          return <String>[];
        },
        save: (ids) async {
          writes++;
          if (fail) throw StateError('Write unavailable');
        },
      );
      state.updateIds(['first']);
      await state.initialize();
      await state.markOpened();
      expect(state.hasUnread.value, isFalse);
      expect(writes, 0);
      fail = false;
      await state.markOpened();
      expect(writes, 1);
      state.updateIds(['first', 'second']);
      expect(state.hasUnread.value, isTrue);
      fail = true;
      await state.markOpened();
      expect(state.hasUnread.value, isFalse);
      fail = false;
      await state.markOpened();
      expect(writes, 3);
    },
  );
}

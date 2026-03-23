import 'package:flutter_test/flutter_test.dart';
import 'package:morning_on_time/models/check_in_status.dart';

void main() {
  group('CheckInStatus', () {
    test('has expected values', () {
      expect(CheckInStatus.values, hasLength(2));
      expect(CheckInStatus.values, contains(CheckInStatus.notStarted));
      expect(CheckInStatus.values, contains(CheckInStatus.goingWell));
    });

    test('enum names are correct', () {
      expect(CheckInStatus.notStarted.name, 'notStarted');
      expect(CheckInStatus.goingWell.name, 'goingWell');
    });
  });
}

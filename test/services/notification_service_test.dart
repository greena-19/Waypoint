
import 'package:flutter_test/flutter_test.dart';

import 'package:waypoint/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('rejects a reminder scheduled in the past', () async {
    await expectLater(
      NotificationService.instance.scheduleReminder(
        id: 3,
        title: 'Past Reminder',
        body: 'This should not be scheduled.',
        scheduledTime: DateTime.now().subtract(
          const Duration(days: 1),
        ),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}

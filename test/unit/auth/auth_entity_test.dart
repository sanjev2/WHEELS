import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/mocks.dart';

void main() {
  test('supports equality', () {
    expect(makeAuthEntity(), makeAuthEntity());
  });

  test('copyWith updates only changed fields', () {
    final entity = makeAuthEntity();
    final updated = entity.copyWith(name: 'Updated', profilePicture: 'me.png');

    expect(updated.name, 'Updated');
    expect(updated.profilePicture, 'me.png');
    expect(updated.email, entity.email);
  });
}

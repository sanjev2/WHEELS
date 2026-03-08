import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authViewModelProvider);
  return authState.authEntity?.userId;
});

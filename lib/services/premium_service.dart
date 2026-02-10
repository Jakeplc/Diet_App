// Conditional export so web builds don't import dart:io.
// On web: premium_service_stub.dart
// On mobile/desktop: premium_service_io.dart
export 'premium_service_stub.dart'
  if (dart.library.io) 'premium_service_io.dart';

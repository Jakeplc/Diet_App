// Conditional export so web builds don't import dart:io / mobile notification plugins.
// On web: notification_service_stub.dart
// On mobile/desktop: notification_service_io.dart
export 'notification_service_stub.dart'
  if (dart.library.io) 'notification_service_io.dart';

// Conditional export so web builds don't import dart:io.
// On web: export_service_stub.dart
// On mobile/desktop: export_service_io.dart
export 'export_service_stub.dart'
  if (dart.library.io) 'export_service_io.dart';

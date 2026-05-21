// Stub for non-web platforms
Future<void> triggerWebDownload(List<int> bytes, String fileName) async {
  // No-op on mobile — handled by native share sheet
}

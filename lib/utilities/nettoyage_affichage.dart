String extractValue(String input) {
  final regex = RegExp(r'(\d.*)');
  final match = regex.firstMatch(input.trim());

  if (match != null) {
    return match.group(1)!.trim();
  } else {
    return input.trim();
  }
}

String cleanCost(String input) {
  return input.replaceAll(RegExp(r'[€£$]'), '').trim();
}

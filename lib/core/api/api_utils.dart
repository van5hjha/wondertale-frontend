import 'dart:convert';

/// Normalizes the gender string to backend format ('boy', 'girl', 'neutral')
String normalizeGender(String gender) {
  final lower = gender.toLowerCase();
  if (lower.contains('boy') || lower.contains('he/him')) {
    return 'boy';
  } else if (lower.contains('girl') || lower.contains('she/her')) {
    return 'girl';
  } else {
    return 'neutral';
  }
}

/// Extracts integer age from age range string (e.g. '4-6 yrs' -> 5)
int extractAge(String ageRange) {
  if (ageRange.contains('0-3')) return 2;
  if (ageRange.contains('4-6')) return 5;
  if (ageRange.contains('7-9')) return 8;
  
  final match = RegExp(r'\d+').firstMatch(ageRange);
  if (match != null) {
    return int.tryParse(match.group(0)!) ?? 5;
  }
  return 5;
}

/// Parses error message from backend JSON response body
String parseError(String body) {
  try {
    final data = json.decode(body);
    if (data['error'] != null) {
      if (data['details'] != null) {
        return '${data['error']}: ${data['details']}';
      }
      return data['error'] as String;
    }
    return body;
  } catch (_) {
    return body;
  }
}

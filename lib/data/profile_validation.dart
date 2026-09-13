String normalizeProfilePhone(String value) {
  var text = value.trim();
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  for (var i = 0; i < 10; i++) {
    text = text.replaceAll(arabic[i], '$i').replaceAll(persian[i], '$i');
  }
  text = text.replaceAll(RegExp(r'[\s()-]'), '');
  if (text.startsWith('00')) text = '+${text.substring(2)}';
  if (RegExp(r'^05\d{8}$').hasMatch(text)) text = '+966${text.substring(1)}';
  return text;
}

String? validateProfileField(String field, String value) {
  final text = value.trim();
  if (text.isEmpty) return 'This field is required';
  if (field == 'Full name' &&
      (text.runes.length < 2 ||
          text.runes.length > 80 ||
          !RegExp(r'[a-zA-Z\u0621-\u064A]').hasMatch(text))) {
    return 'Enter a name between 2 and 80 characters';
  }
  if (field == 'Email' && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
    return 'Enter a valid email';
  }
  if (field == 'Phone number') {
    final phone = normalizeProfilePhone(text);
    if (phone.startsWith('+966')) {
      if (!RegExp(r'^\+9665\d{8}$').hasMatch(phone)) {
        return 'Use 05XXXXXXXX or +9665XXXXXXXX';
      }
    } else if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phone)) {
      return 'Include your country code, e.g. +9665XXXXXXXX';
    }
  }
  return null;
}

bool isProfileFieldComplete(String field, String value) {
  if (['Riyal User', 'user@example.com', '+966 50 000 0000'].contains(value)) {
    return false;
  }
  return validateProfileField(field, value) == null;
}

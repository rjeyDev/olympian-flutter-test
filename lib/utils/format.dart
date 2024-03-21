
String formatWord(String? word) {
  if (word == null) {
    return '';
  }
  return word
    .toLowerCase()
    .replaceAll(' ', '')
    .replaceAll('ё', 'е')
    .replaceAll('й', 'и')
    .replaceAll('ъ', 'ь');
}
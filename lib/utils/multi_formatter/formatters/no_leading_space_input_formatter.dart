import 'package:u/utilities.dart';

/// A [TextInputFormatter] that prevents the user from entering leading whitespace
/// characters.
///
/// This formatter inspects the incoming [TextEditingValue] and if the new text
/// starts with any whitespace characters (including space, tab, newline, and
/// the Zero-Width Non-Joiner), it returns a new value with the leading
/// characters trimmed. It also adjusts the cursor position accordingly to
/// provide a seamless user experience.
class NoLeadingSpaceInputFormatter extends TextInputFormatter {
  /// Called by the text field to format the `newValue`.
  ///
  /// This override implements the logic to detect and remove leading whitespace.
  @override
  TextEditingValue formatEditUpdate(
      final TextEditingValue oldValue,
      final TextEditingValue newValue,
      ) {
    // Check if the new text starts with one or more whitespace or ZWNJ characters.
    if (newValue.text.startsWith(RegExp(r'[\s\u200C\t\n]+'))) {
      // Trim the leading characters using the custom helper method.
      final String trimmedText = _trimLeading(newValue.text);

      // Recalculate the cursor offset based on the number of characters removed
      // from the beginning of the string.
      final int newOffset = newValue.selection.end - (newValue.text.length - trimmedText.length);

      return TextEditingValue(
        text: trimmedText,
        selection: TextSelection.collapsed(
          // Ensure the final offset is not negative.
          offset: newOffset >= 0 ? newOffset : 0,
        ),
      );
    }
    // If no leading whitespace is found, return the new value as is.
    return newValue;
  }

  /// Trims leading whitespace, including the Zero-Width Non-Joiner (U+200C),
  /// tab, and newline characters from the beginning of the string.
  String _trimLeading(final String text) {
    int i = 0;
    while (i < text.length && (text[i] == ' ' || text[i] == '\u200C' || text[i] == '\t' || text[i] == '\n')) {
      i++;
    }
    return text.substring(i);
  }
}
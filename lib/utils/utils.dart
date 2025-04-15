import 'package:u/utilities.dart';

String uuidV4() => const Uuid().v4();

String uuidV1() => const Uuid().v1();

void delay(final int milliseconds, final VoidCallback action) async => Future<dynamic>.delayed(
      Duration(milliseconds: milliseconds),
      () async => action(),
    );

void validateForm({required final GlobalKey<FormState> key, required final VoidCallback action}) {
  if (key.currentState!.validate()) action();
}

bool hasMatch(final String? value, final String pattern) => (value == null) ? false : RegExp(pattern).hasMatch(value);

FormFieldValidator<String> validateMinLength(
  final int minLength, {
  final String requiredMessage = "فیلد الزامی است",
  final String minLengthMessage = "مقدار وارد شده صحیح نیست",
}) =>
    (final String? value) {
      if (value!.isEmpty) return requiredMessage;
      if (value.length < minLength) return minLengthMessage;
      return null;
    };

FormFieldValidator<dynamic> validateNotEmpty({
  final String requiredMessage = "فیلد الزامی است",
}) =>
    (final dynamic value) {
      if (value!.isEmpty) return requiredMessage;
      return null;
    };

FormFieldValidator<String> validateEmail({
  final bool required = true,
  final String requiredMessage = "فیلد الزامی است",
  final String notEmailMessage = "ایمیل وارد شده صحیح نیست",
}) =>
    (final String? value) {
      if (!required && value!.isEmpty) {
        return null;
      } else if (value!.isEmpty) {
        return requiredMessage;
      }
      if (!value.isEmail) return notEmailMessage;
      return null;
    };

FormFieldValidator<String> validateNumber({
  final bool required = true,
  final String requiredMessage = "فیلد الزامی است",
  final String notMobileMessage = "شماره موبایل وارد شده صحیح نیست",
  final String isShortMobileMessage = "شماره موبایل وارد شده کوتاه است",
  final int minLength = 11,
  final String startWith = "0"
}) =>
    (final String? value) {
      if (!required && value!.isEmpty) {
        return null;
      } else if (value!.isEmpty) {
        return requiredMessage;
      }
      if (GetUtils.isNumericOnly(value.englishNumber()) && value.length < minLength && value.startsWith(startWith)) return isShortMobileMessage;
      if (!GetUtils.isNumericOnly(value.englishNumber()) || value.length < minLength || !value.startsWith(startWith)) return notMobileMessage;
      return null;
    };

bool isLoggedIn() => ULocalStorage.getString(UConstants.token) == null ? false : true;

Future<Uint8List> screenshot({required final Widget widget}) => ScreenshotController().captureFromWidget(widget);

import 'package:u/utilities.dart';

class UOtpField extends StatelessWidget {
  const UOtpField({
    super.key,
    required this.pinController,
    this.length = 4,
    this.autoFocus = false,
    this.onCompleted,
    this.validator,
    this.fieldWidth = 60,
    this.fieldHeight = 64,
    this.borderRadius = 8,
    this.fillColor,
    this.borderColor,
    this.activeColor,
    this.cursorColor,
    this.textStyle,
    this.hintStyle,
    this.onTap,
    this.theme,
    this.keyboardType,
    this.hintCharacter,
  });

  final PinInputController pinController;
  final int length;
  final bool autoFocus;
  final double fieldWidth;
  final double fieldHeight;
  final double borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? activeColor;
  final Color? cursorColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final VoidCallback? onTap;
  final MaterialPinTheme? theme;
  final TextInputType? keyboardType;
  final String? hintCharacter;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    return MaterialPinFormField(
      length: length,
      pinController: pinController,
      autoFocus: autoFocus,
      enableAutofill: true,
      autofillHints: const [
        AutofillHints.oneTimeCode,
      ],
      hintCharacter: hintCharacter,
      keyboardType: keyboardType ?? const TextInputType.numberWithOptions(signed: false, decimal: false),
      onTapOutside: (event) => FocusManager.instance.primaryFocus!.unfocus(),
      validator: validator,
      onTap: onTap,
      onCompleted: onCompleted,
      theme:
      theme ??
          MaterialPinTheme(
            shape: MaterialPinShape.outlined,
            cellSize: Size(
              fieldWidth,
              fieldHeight,
            ),
            borderRadius: BorderRadius.circular(
              borderRadius,
            ),
            borderColor: borderColor,
            focusedBorderColor: activeColor,
            fillColor: fillColor,
            focusedFillColor: fillColor,
            filledFillColor: fillColor,
            textStyle: textStyle,
            cursorColor: cursorColor,
          ),
    ).ltr();
  }
}
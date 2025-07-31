import 'package:u/utilities.dart';

class UTextFormField extends StatefulWidget {
  const UTextFormField({
    super.key,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.labelText,
    this.hintStyle,
    this.hintText,
    this.contentPadding,
    this.fontSize,
    this.controller,
    this.onTap,
    this.onTapOutside,
    this.validator,
    this.prefix,
    this.suffix,
    this.suffixText,
    this.onSave,
    this.onEditingComplete,
    this.initialValue,
    this.helperText,
    this.helperMaxLines,
    this.helperStyle,
    this.floatingLabelStyle,
    this.textHeight,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLength,
    this.formatters,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.obscureIconColor,
    this.minLines = 1,
    this.maxLines,
    this.required = false,
    this.isDense = false,
    this.textAlign = TextAlign.start,
    this.showCounter = false,
    this.textDirection,
    this.borderColor,
    this.autovalidateMode,
  });

  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool obscureText;
  final Color? obscureIconColor;
  final bool required;
  final bool isDense;
  final bool readOnly;
  final String? labelText;
  final TextStyle? hintStyle;
  final String? hintText;
  final String? initialValue;
  final String? helperText;
  final int? helperMaxLines;
  final TextStyle? helperStyle;
  final TextStyle? floatingLabelStyle;
  final void Function(PointerDownEvent event)? onTapOutside;
  final String? Function(String?)? validator;
  final double? fontSize;
  final double? textHeight;
  final TextEditingController? controller;
  final int minLines;
  final int? maxLines;
  final TextInputType keyboardType;
  final int? maxLength;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;
  final Widget? prefix;
  final Widget? suffix;
  final String? suffixText;
  final Function(String? value)? onSave;
  final Function()? onEditingComplete;
  final TextAlign textAlign;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? formatters;
  final bool showCounter;
  final TextDirection? textDirection;
  final Color? borderColor;
  final AutovalidateMode? autovalidateMode;

  @override
  State<UTextFormField> createState() => _UTextFormFieldState();
}

class _UTextFormFieldState extends State<UTextFormField> {
  bool obscure = false;

  @override
  void initState() {
    obscure = widget.obscureText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      autovalidateMode: widget.autovalidateMode,
      textDirection: widget.textDirection ??
          (widget.keyboardType == TextInputType.number ||
                  widget.keyboardType == TextInputType.visiblePassword ||
                  widget.keyboardType == TextInputType.emailAddress ||
                  widget.keyboardType == TextInputType.url ||
                  widget.keyboardType == TextInputType.phone
              ? TextDirection.ltr
              : null),
      inputFormatters: widget.formatters ??
          [
            // بلاک کردن حروف فارسی و عربی و فاصله و نیم فاصله
            if (widget.keyboardType == TextInputType.visiblePassword) FilteringTextInputFormatter.allow(RegExp(r'[!-~\u06F0-\u06F9]')),
            if (widget.keyboardType == TextInputType.emailAddress) FilteringTextInputFormatter.deny(RegExp(r'[\u0600-\u06FF\s\u200C]')),
            if (widget.keyboardType == TextInputType.number) FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            if (widget.keyboardType == TextInputType.phone) FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
      style: context.textTheme.bodyMedium!.copyWith(fontSize: (context.textTheme.bodyMedium!.fontSize ?? 12) + 2),
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
      initialValue: widget.initialValue,
      textAlign: widget.textAlign,
      onSaved: widget.onSave,
      onEditingComplete: widget.onEditingComplete,
      onTap: widget.onTap,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: obscure,
      onTapOutside: widget.onTapOutside ?? (event) => FocusManager.instance.primaryFocus?.unfocus(),
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      minLines: widget.minLines,
      maxLines: widget.maxLines ?? (widget.minLines == 1 ? 1 : 20),
      decoration: InputDecoration(
        fillColor: context.theme.dividerColor.withAlpha(50),
        filled: !widget.enabled,
        labelText: widget.labelText != null ? "${widget.labelText}${widget.required ? '*' : ''}" : null,
        labelStyle: widget.hintStyle ??
            context.textTheme.bodyMedium!.copyWith(
              fontSize: (context.textTheme.bodyMedium!.fontSize ?? 12) + 2,
              color: context.theme.hintColor,
            ),
        floatingLabelStyle: widget.floatingLabelStyle ?? context.textTheme.bodyLarge!,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        isDense: widget.isDense,
        helperStyle: widget.helperStyle ?? context.textTheme.bodySmall,
        helperText: widget.helperText,
        helperMaxLines: widget.helperMaxLines,
        hintText: widget.hintText,
        hintStyle: widget.hintStyle ??
            context.textTheme.bodyMedium!.copyWith(
              fontSize: (context.textTheme.bodyMedium!.fontSize ?? 12) + 2,
              color: context.theme.hintColor,
            ),
        contentPadding: widget.contentPadding,
        counter: widget.showCounter ? null : const SizedBox(),
        suffixIcon: widget.obscureText
            ? IconButton(
                splashRadius: 1,
                onPressed: () => setState(() => obscure = !obscure),
                icon: obscure
                    ? Icon(Icons.visibility, color: widget.obscureIconColor ?? context.theme.hintColor)
                    : Icon(Icons.visibility_off, color: widget.obscureIconColor ?? context.theme.hintColor),
              )
            : widget.suffix,
        suffixText: widget.suffixText,
        suffixStyle: context.textTheme.bodyMedium!.copyWith(fontSize: (context.textTheme.bodyMedium!.fontSize ?? 12) + 2),
        prefixIcon: widget.prefix,
        border: widget.borderColor != null ? OutlineInputBorder(borderSide: BorderSide(color: widget.borderColor!)) : null,
        enabledBorder: widget.borderColor != null ? OutlineInputBorder(borderSide: BorderSide(color: widget.borderColor!)) : null,
        disabledBorder: widget.borderColor != null ? OutlineInputBorder(borderSide: BorderSide(color: widget.borderColor!)) : null,
        errorBorder: widget.borderColor != null ? OutlineInputBorder(borderSide: BorderSide(color: widget.borderColor!)) : null,
        focusedBorder: widget.borderColor != null ? OutlineInputBorder(borderSide: BorderSide(color: widget.borderColor!)) : null,
      ),
    );
  }
}

class UTextFieldPersianDatePicker extends StatefulWidget {
  const UTextFieldPersianDatePicker({
    required this.onChange,
    this.fontSize,
    this.hintText,
    this.labelText,
    this.prefix,
    this.suffix,
    this.textHeight,
    this.controller,
    this.initialDate,
    this.startDate,
    this.endDate,
    this.validator,
    this.readOnly = false,
    this.date = true,
    this.time = false,
    this.submitButtonText = "Submit",
    this.cancelButtonText = "Cancel",
    this.textAlign = TextAlign.start,
    super.key,
  });

  final Function(DateTime, Jalali) onChange;
  final double? fontSize;
  final String? hintText;
  final String? labelText;
  final Widget? prefix;
  final bool readOnly;
  final Widget? suffix;
  final TextAlign textAlign;
  final double? textHeight;
  final TextEditingController? controller;
  final Jalali? initialDate;
  final Jalali? startDate;
  final Jalali? endDate;
  final String submitButtonText;
  final String cancelButtonText;
  final String? Function(String?)? validator;
  final bool date;
  final bool time;

  @override
  State<UTextFieldPersianDatePicker> createState() => _UTextFieldPersianDatePickerState();
}

class _UTextFieldPersianDatePickerState extends State<UTextFieldPersianDatePicker> {
  late Jalali jalali;

  @override
  void initState() {
    jalali = (widget.initialDate ?? Jalali.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) => UTextFormField(
        controller: widget.controller,
        prefix: widget.prefix,
        suffix: widget.suffix,
        labelText: widget.labelText,
        fontSize: widget.fontSize,
        hintText: widget.hintText,
        textAlign: widget.textAlign,
        readOnly: true,
        textHeight: widget.textHeight,
        validator: widget.validator,
        onTap: () async {
          if (!widget.readOnly) {
            if (widget.date) {
              UNavigator.bottomSheet(
                  child: Column(
                    children: [
                      LinearDatePicker(
                        startDate: "1330/01/01",
                        endDate: "1406/12/30",
                        initialDate: "${jalali.year}/${jalali.month}/${jalali.day}",
                        addLeadingZero: true,
                        dateChangeListener: (String selectedDate) {
                          jalali = Jalali(
                            selectedDate.getYear(),
                            selectedDate.getMonth(),
                            selectedDate.getDay(),
                          );
                        },
                        showDay: true,
                        yearText: "سال",
                        monthText: "ماه",
                        dayText: "روز",
                        showLabels: true,
                        columnWidth: 100,
                        showMonthName: true,
                        isJalaali: true,
                      ),
                      Row(
                        children: [
                          UElevatedButton(
                            title: widget.submitButtonText,
                            onTap: () {
                              setState(() {});
                              widget.onChange(jalali.toDateTime(), jalali);
                              UNavigator.back();
                            },
                          ).expanded(),
                          const SizedBox(width: 12),
                          UElevatedButton(
                            title: widget.cancelButtonText,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            onTap: () => UNavigator.back(),
                          ).expanded(),
                        ],
                      ).pOnly(top: 24, bottom: 12),
                    ],
                  ),
                  onDismiss: () async {
                    if (widget.time) {
                      TimeOfDay? timeOfDay = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 0, minute: 0),
                      );
                      jalali = Jalali(
                        jalali.year,
                        jalali.month,
                        jalali.day,
                        timeOfDay!.hour,
                        timeOfDay.minute,
                      );
                      setState(() => jalali = jalali);
                      widget.onChange(jalali.toDateTime(), jalali);
                    }
                  });
            }
          }
        },
      );
}

class UElevatedButton extends StatelessWidget {
  const UElevatedButton({
    super.key,
    this.title,
    this.titleColor,
    this.progressIndicatorColor,
    this.progressIndicatorStrokeWidth,
    this.titleWidget,
    this.isLoading = false,
    this.onTap,
    this.icon,
    this.width,
    this.height,
    this.textStyle,
    this.backgroundColor,
    this.horizontalPadding,
    this.borderRadius,
    this.borderWidth,
    this.borderColor = Colors.grey,
  });

  final String? title;
  final Color? titleColor;
  final Color? progressIndicatorColor;
  final double? progressIndicatorStrokeWidth;
  final Widget? titleWidget;
  final bool isLoading;
  final VoidCallback? onTap;
  final Widget? icon;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final double? horizontalPadding;
  final double? borderRadius;
  final double? borderWidth;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
          textStyle: textStyle == null ? null : WidgetStatePropertyAll<TextStyle>(textStyle!),
          backgroundColor: WidgetStateProperty.all(backgroundColor ?? navigatorKey.currentContext!.theme.primaryColor),
          padding: WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: horizontalPadding ?? 12)),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
              side: borderWidth != null ? BorderSide(width: borderWidth ?? 1, color: borderColor) : BorderSide.none,
            ),
          ),
        ),
        onPressed: () {
          if (!isLoading) {
            onTap?.call();
          }
        },
        child: Container(
          constraints: BoxConstraints(
            minWidth: width ?? 100,
            maxWidth: width ?? context.width,
            minHeight: height ?? 40,
            maxHeight: height ?? 40,
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: isLoading
                ? SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      color: progressIndicatorColor ?? Colors.white,
                      strokeCap: StrokeCap.round,
                      strokeWidth: progressIndicatorStrokeWidth ?? 3.0,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      if (icon != null) icon!,
                      titleWidget ??
                          Text(
                            title ?? '',
                            textAlign: TextAlign.center,
                          ).bodyMedium(color: titleColor ?? Colors.white),
                    ],
                  ),
          ),
        ),
      );
}

class UOutlinedButton extends StatelessWidget {
  const UOutlinedButton({
    super.key,
    this.title,
    this.titleWidget,
    this.onTap,
    this.icon,
    this.width,
    this.height,
    this.textStyle,
    this.padding,
  });

  final String? title;
  final Widget? titleWidget;
  final VoidCallback? onTap;
  final IconData? icon;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: ButtonStyle(
          textStyle: textStyle == null ? null : WidgetStatePropertyAll<TextStyle>(textStyle!),
          padding: WidgetStateProperty.all(padding),
        ),
        onPressed: onTap,
        child: SizedBox(
          height: height,
          width: width ?? MediaQuery.sizeOf(navigatorKey.currentContext!).width,
          child: Center(child: titleWidget ?? Text(title ?? '', textAlign: TextAlign.center)),
        ),
      );
}

class UTextFieldTypeAhead<T> extends StatelessWidget {
  const UTextFieldTypeAhead({
    required this.onSuggestionSelected,
    required this.suggestionsCallback,
    this.itemBuilder,
    this.prefix,
    this.onTap,
    this.suffix,
    this.labelText,
    this.hintText,
    this.contentPadding,
    this.controller,
    this.validator,
    this.onChanged,
    this.isDense = false,
    this.hideKeyboard = false,
    super.key,
  });

  final void Function(T) onSuggestionSelected;
  final FutureOr<List<T>?> Function(String) suggestionsCallback;
  final Widget Function(BuildContext context, T itemData)? itemBuilder;
  final Widget? prefix;
  final VoidCallback? onTap;
  final bool isDense;
  final Widget? suffix;
  final String? labelText;
  final String? hintText;
  final EdgeInsetsGeometry? contentPadding;
  final TextEditingController? controller;
  final bool hideKeyboard;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TypeAheadField<T>(
            hideKeyboardOnDrag: hideKeyboard,
            suggestionsCallback: suggestionsCallback,
            builder: (final BuildContext _, final TextEditingController __, final FocusNode ___) => UTextFormField(
              onTap: onTap,
              validator: validator,
              prefix: prefix,
              isDense: isDense,
              contentPadding: contentPadding,
              onChanged: onChanged,
              hintText: hintText,
              labelText: labelText,
              suffix: suffix,
              controller: controller,
            ),
            itemBuilder: itemBuilder ??
                (final BuildContext context, final Object? suggestion) => Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Text(suggestion.toString()),
                    ),
            onSelected: onSuggestionSelected,
          ),
        ],
      );
}

class UOtpField extends StatelessWidget {
  const UOtpField({
    this.length = 4,
    this.autoFocus = false,
    this.controller,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.hintCharacter,
    this.onCompleted,
    this.borderRadius = 8,
    this.shape = PinCodeFieldShape.box,
    this.fieldOuterPadding,
    this.fieldHeight = 64,
    this.fieldWidth = 60,
    this.fillColor,
    this.borderColor,
    this.activeColor,
    this.cursorColor,
    this.onTap,
    this.validator,
    this.errorAnimationController,
    this.errorTextDirection = TextDirection.ltr,
    this.textStyle,
    this.hintStyle,
    super.key,
  });

  final int length;
  final bool autoFocus;
  final TextEditingController? controller;
  final MainAxisAlignment mainAxisAlignment;
  final String? hintCharacter;
  final void Function(String)? onCompleted;
  final double borderRadius;
  final PinCodeFieldShape shape;
  final EdgeInsetsGeometry? fieldOuterPadding;
  final double fieldHeight;
  final double fieldWidth;
  final Color? fillColor;
  final Color? borderColor;
  final Color? activeColor;
  final Color? cursorColor;
  final Function? onTap;
  final String? Function(String?)? validator;
  final StreamController<ErrorAnimationType>? errorAnimationController;
  final TextDirection errorTextDirection;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  @override
  Widget build(BuildContext context) => PinCodeTextField(
        controller: controller,
        appContext: navigatorKey.currentContext!,
        length: length,
        cursorColor: cursorColor,
        onTap: onTap,
        autoFocus: autoFocus,
        mainAxisAlignment: mainAxisAlignment,
        hintCharacter: hintCharacter,
        validator: validator,
        errorAnimationController: errorAnimationController,
        errorTextSpace: 20,
        errorTextDirection: errorTextDirection,
        textStyle: textStyle,
        pastedTextStyle: textStyle,
        hintStyle: hintStyle,
        pinTheme: PinTheme(
          shape: shape,
          fieldOuterPadding: fieldOuterPadding,
          borderRadius: BorderRadius.circular(borderRadius),
          fieldHeight: fieldHeight,
          fieldWidth: fieldWidth,
          activeFillColor: fillColor,
          inactiveFillColor: fillColor,
          selectedFillColor: fillColor,
          inactiveColor: borderColor,
          selectedColor: activeColor,
          activeColor: activeColor,
          borderWidth: 1,
          activeBorderWidth: 1,
          errorBorderWidth: 1,
          inactiveBorderWidth: 1,
          disabledBorderWidth: 1,
        ),
        enableActiveFill: true,
        backgroundColor: Colors.transparent,
        keyboardType: TextInputType.number,
        onCompleted: onCompleted,
        onChanged: (final _) {},
      ).ltr();
}

Widget radioListTile<T>({
  required final T value,
  required final T groupValue,
  required final String title,
  required final String subTitle,
  required final Function(T?)? onChanged,
  final bool toggleable = true,
}) =>
    RadioListTile<T>(
      toggleable: toggleable,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(title),
      subtitle: FittedBox(alignment: Alignment.centerRight, fit: BoxFit.scaleDown, child: Text(subTitle)),
      groupValue: groupValue,
      value: value,
      onChanged: onChanged,
    ).container(
      radius: 20,
      borderColor: Theme.of(navigatorKey.currentContext!).colorScheme.onSurface.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );

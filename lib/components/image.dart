import 'package:u/utilities.dart';

class UImage extends StatelessWidget {
  const UImage(
    this.source, {
    super.key,
    this.fileData,
    this.color,
    this.size,
    this.width,
    this.height,
    this.placeholder,
    this.progressIndicatorBuilder,
    this.fit = BoxFit.contain,
    this.borderRadius = 1,
    this.border,
  });

  final String source;
  final FileData? fileData;
  final Color? color;
  final double? size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final String? placeholder;
  final BoxBorder? border;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  @override
  Widget build(final BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          border: border,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Builder(
          builder: (final BuildContext context) {
            if (fileData != null) {
              if (UApp.isWeb) {
                return UImageMemory(
                  fileData!.bytes!,
                  width: size ?? width,
                  height: size ?? height,
                  borderRadius: borderRadius,
                  color: color,
                  fit: fit,
                );
              } else {
                return UImageFile(
                  File(fileData!.path!),
                  width: size ?? width,
                  height: size ?? height,
                  borderRadius: borderRadius,
                  color: color,
                  fit: fit,
                );
              }
            } else if (source.length <= 5) {
              if (placeholder == null) {
                return SizedBox(width: size ?? width, height: size ?? height);
              } else {
                return UImageAsset(
                  placeholder!,
                  width: size ?? width,
                  height: size ?? height,
                  borderRadius: borderRadius,
                  color: color,
                  fit: fit,
                );
              }
            } else {
              if (source.startsWith("http")) {
                return UImageNetwork(
                  source,
                  width: size ?? width,
                  height: size ?? height,
                  fit: fit,
                  borderRadius: borderRadius,
                  color: color,
                  progressIndicatorBuilder: progressIndicatorBuilder,
                  placeholder: placeholder,
                );
              } else if (source.startsWith("http") && (source.endsWith(".json") || source.endsWith(".lottie"))) {
                return Lottie.network(
                  source,
                  width: size ?? width,
                  height: size ?? height,
                  fit: fit,
                  decoder: _customDecoder,
                  repeat: true,
                );
              } else if (source.endsWith(".json") || source.endsWith(".lottie")) {
                return Lottie.asset(
                  source,
                  width: size ?? width,
                  height: size ?? height,
                  fit: fit,
                  decoder: _customDecoder,
                  repeat: true,
                  animate: true,
                );
              } else {
                return UImageAsset(
                  source,
                  width: size ?? width,
                  height: size ?? height,
                  fit: fit,
                  borderRadius: borderRadius,
                  color: color,
                );
              }
            }
          },
        ),
      );

  Future<LottieComposition?> _customDecoder(List<int> bytes) {
    return LottieComposition.decodeZip(bytes, filePicker: (files) {
      return files.firstWhereOrNull((f) => f.name.startsWith('animations/') && f.name.endsWith('.json'));
    });
  }
}

class UIconPrimary extends StatelessWidget {
  const UIconPrimary(
    this.source, {
    super.key,
    this.color,
    this.width,
    this.height,
    this.placeholder,
    this.progressIndicatorBuilder,
    this.fit = BoxFit.contain,
    this.borderRadius = 1,
  });

  final String source;
  final Color? color;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final String? placeholder;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  @override
  Widget build(final BuildContext context) => UImage(
        source,
        color: color ?? Theme.of(navigatorKey.currentContext!).colorScheme.primary,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
        placeholder: placeholder,
        progressIndicatorBuilder: progressIndicatorBuilder,
      );
}

class UImageAsset extends StatelessWidget {
  const UImageAsset(
    this.path, {
    this.color,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.clipBehavior = Clip.hardEdge,
    this.borderRadius = 1,
    super.key,
  });

  final String path;
  final Color? color;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Clip clipBehavior;
  final double borderRadius;

  @override
  Widget build(final BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: path.endsWith("svg")
            ? SvgPicture.asset(
                path,
                width: width,
                height: height,
                fit: fit,
                color: color,
              )
            : Image.asset(
                path,
                color: color,
                width: width,
                height: height,
                fit: fit,
              ),
      );
}

class UImageNetwork extends StatelessWidget {
  const UImageNetwork(
    this.url, {
    this.color,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.clipBehavior = Clip.hardEdge,
    this.borderRadius = 1,
    this.placeholder,
    this.progressIndicatorBuilder,
    super.key,
  });

  final String url;
  final Color? color;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Clip clipBehavior;
  final double borderRadius;
  final String? placeholder;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  @override
  Widget build(final BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Builder(
          builder: (final BuildContext context) => url.length <= 10
              ? placeholder == null
                  ? SizedBox(width: width, height: height)
                  : UImageAsset(
                      placeholder!,
                      width: width,
                      height: height,
                      color: color,
                      fit: fit,
                      clipBehavior: clipBehavior,
                      borderRadius: borderRadius,
                    )
              : url.substring(url.length - 3) == "svg"
                  ? SvgPicture.network(
                      url,
                      width: width,
                      height: height,
                      fit: fit,
                      color: color,
                      placeholderBuilder: placeholder == null
                          ? null
                          : (final _) => UImageAsset(
                                placeholder!,
                                width: width,
                                height: height,
                                fit: fit,
                                clipBehavior: clipBehavior,
                                borderRadius: borderRadius,
                              ),
                    )
                  : CachedNetworkImage(
                      imageUrl: url,
                      color: color,
                      width: width,
                      height: height,
                      fit: fit,
                      progressIndicatorBuilder: progressIndicatorBuilder,
                      errorWidget: placeholder == null
                          ? null
                          : (final _, final __, final ___) => UImage(
                                placeholder!,
                                color: color,
                                width: width,
                                height: height,
                                fit: fit,
                              ),
                      placeholder: placeholder == null
                          ? null
                          : (final _, final __) => UImage(
                                placeholder!,
                                color: color,
                                width: width,
                                height: height,
                                fit: fit,
                              ),
                    ),
        ),
      );
}

class UImageFile extends StatelessWidget {
  const UImageFile(
    this.file, {
    this.color,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius = 1,
    super.key,
  });

  final File file;
  final Color? color;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(final BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          file,
          color: color,
          width: width,
          height: height,
          fit: fit,
        ),
      );
}

class UImageMemory extends StatelessWidget {
  const UImageMemory(
    this.file, {
    this.color,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius = 1,
    super.key,
  });

  final Uint8List file;
  final Color? color;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(final BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          file,
          color: color,
          width: width,
          height: height,
          fit: fit,
        ),
      );
}

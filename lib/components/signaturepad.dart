import 'dart:ui' as ui;

import 'package:u/utilities.dart';

class SignaturePad extends StatelessWidget {
  SignaturePad({
    required this.onSave,
    this.saveButtonText = "Save",
    this.clearButtonText = "Clear",
    this.pixelRatio = 1.0,
    super.key,
  });

  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  final Rx<bool> isNotEmpty = false.obs;
  final Function(FileData fileData, bool isEmpty) onSave;
  final String saveButtonText;
  final String clearButtonText;
  final double pixelRatio;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: SfSignaturePad(
              key: signatureGlobalKey,
              backgroundColor: Colors.grey[100],
              strokeColor: Colors.black,
              minimumStrokeWidth: 1.5,
              maximumStrokeWidth: 1.5,
              onDrawEnd: () {
                isNotEmpty(true);
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            spacing: 10,
            children: <Widget>[
              UElevatedButton(
                title: clearButtonText,
                backgroundColor: context.theme.hintColor,
                onTap: () {
                  signatureGlobalKey.currentState!.clear();
                  isNotEmpty(false);
                },
              ).expanded(),
              Obx(
                () => UElevatedButton(
                  title: saveButtonText,
                  backgroundColor: isNotEmpty.value ? null : context.theme.dividerColor,
                  onTap: handleSaveButtonPressed,
                ),
              ).expanded(),
            ],
          )
        ],
      );

  void handleSaveButtonPressed() async {
    final ui.Image data = await signatureGlobalKey.currentState!.toImage(pixelRatio: pixelRatio);
    final ByteData? bytes = await data.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List byte = bytes!.buffer.asUint8List();
    File file = await UFile.writeToFile(byte);
    onSave(FileData(path: file.path, bytes: byte, extension: "png"), !isNotEmpty.value);
  }
}

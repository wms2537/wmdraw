import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorDialog extends StatefulWidget {
  ColorDialog({Key? key, required this.initialColor});
  final Color initialColor;
  @override
  State<StatefulWidget> createState() => ColorDialogState();
}

class ColorDialogState extends State<ColorDialog> {
  late Color pickerColor;

  @override
  void initState() {
    pickerColor = widget.initialColor;
    super.initState();
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Brush color"),
      contentPadding: const EdgeInsets.all(12.0),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: changeColor,
          showLabel: true,
          pickerAreaHeightPercent: 0.8,
        ),
      ),
      // Use Material color picker:
      //
      // child: MaterialPicker(
      //   pickerColor: pickerColor,
      //   onColorChanged: changeColor,
      //   showLabel: true, // only on portrait mode
      // ),
      //
      // Use Block color picker:
      //
      // child: BlockPicker(
      //   pickerColor: currentColor,
      //   onColorChanged: changeColor,
      // ),
      //
      // child: MultipleChoiceBlockPicker(
      //   pickerColors: currentColors,
      //   onColorsChanged: changeColors,
      // ),

      actions: <Widget>[
        TextButton(
          child: const Text('Confirm'),
          onPressed: () {
            Navigator.of(context).pop(pickerColor);
          },
        ),
      ],
    );
  }
}

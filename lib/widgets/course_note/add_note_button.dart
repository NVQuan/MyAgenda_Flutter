import 'package:flutter/material.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/button/raised_button_colored.dart';

class AddNoteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddNoteButton({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: RaisedButtonColored(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        text: translations.text(StrKey.ADD_NOTE_BTN),
        onPressed: onPressed,
      ),
    );
  }
}

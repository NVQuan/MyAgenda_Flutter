import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';

class CourseListHeader extends StatelessWidget {
  final String text;
  final Color bgColor;

  const CourseListHeader(this.text, {Key key, this.bgColor}) : super(key: key);

  Future<Null> _onHeaderTap(BuildContext context) async {
    bool btnPositivePressed = await DialogPredefined.showTextDialog(
      context,
      translations.text(StrKey.CHANGE_AGENDA),
      translations.text(StrKey.CHANGE_AGENDA_TEXT),
      translations.text(StrKey.CHANGE),
      translations.text(StrKey.CANCEL),
    );

    if (btnPositivePressed)
      Navigator.of(context).pushNamed(RouteKey.SETTINGS);
  }

  @override
  Widget build(BuildContext context) {
    if (text == null) return const SizedBox.shrink();

    final textStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0, color: getColorDependOfBackground(bgColor ?? Theme.of(context).primaryColor));

    return GestureDetector(
      onTap: () => _onHeaderTap(context),
      child: Container(
        color: bgColor,
        padding: const EdgeInsets.all(12.0),
        alignment: Alignment.center,
        child: Text(text, style: textStyle, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

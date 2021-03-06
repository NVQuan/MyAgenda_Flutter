import 'package:flutter/material.dart';
import 'package:myagenda/keys/pref_key.dart';
import 'package:myagenda/keys/string_key.dart';
import 'package:myagenda/models/analytics.dart';
import 'package:myagenda/screens/appbar_screen.dart';
import 'package:myagenda/screens/base_state.dart';
import 'package:myagenda/screens/settings/manage_hidden_events.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/http/http_request.dart';
import 'package:myagenda/utils/ical.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:myagenda/widgets/settings/list_tile_choices.dart';
import 'package:myagenda/widgets/settings/list_tile_color.dart';
import 'package:myagenda/widgets/settings/list_tile_input.dart';
import 'package:myagenda/widgets/settings/list_tile_number.dart';
import 'package:myagenda/widgets/settings/list_tile_title.dart';
import 'package:myagenda/widgets/settings/setting_card.dart';
import 'package:myagenda/widgets/ui/dialog/dialog_predefined.dart';
import 'package:myagenda/widgets/ui/list_divider.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

enum MenuItem { REFRESH }

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends BaseState<SettingsScreen> {
  _forceRefreshResources() async {
    // Show progress dialog
    DialogPredefined.showProgressDialog(
      context,
      translations.text(StrKey.LOADING_RESOURCES),
    );

    final response = await HttpRequest.get(prefs.university.resourcesFile);

    if (response.isSuccess && mounted) {
      final resourcesGetStr = response.httpResponse.body;
      if (resourcesGetStr.trim().length > 0) {
        prefs.setResourcesDate();
        prefs.setResources(resourcesGetStr, true);
      }
    }
    // Send to analytics user force refresh calendar resources
    analyticsProvider.sendForceRefresh(AnalyticsValue.refreshResources);
    // Close loading dialog
    Navigator.pop(context);
  }

  Widget _buildSettingsGeneral() {
    final groupKeys = prefs.groupKeys;
    List<Widget> settingsGeneralElems;

    if (prefs.urlIcs == null) {
      settingsGeneralElems = [];

      List<List<String>> allGroupKeys = prefs.getAllGroupKeys(prefs.groupKeys);
      for (int level = 0; level < allGroupKeys.length; level++) {
        settingsGeneralElems.add(ListTileChoices(
          title: translations.text(
            StrKey.ELEMENT,
            {'number': (level + 1).toString()},
          ),
          selectedValue: groupKeys[level],
          values: allGroupKeys[level],
          onChange: (value) {
            groupKeys[level] = value;
            prefs.setGroupKeys(groupKeys, true);
          },
        ));
      }
    } else {
      settingsGeneralElems = [
        ListTileInput(
          title: translations.text(StrKey.URL_ICS),
          hintText: translations.text(StrKey.URL_ICS),
          defaultValue: prefs.urlIcs,
          onChange: (value) async {
            // Check before update prefs, if url is good
            DialogPredefined.showProgressDialog(
              context,
              translations.text(StrKey.CHECKING_ICS_URL),
            );

            final response = await HttpRequest.get(value);
            // Close progressDialog
            Navigator.of(context).pop();

            // If request failed, url is bad (or no internet)
            String error;
            if (!response.isSuccess) {
              error = translations.text(StrKey.FILE_404);
            } else if (!Ical.isValidIcal(response.httpResponse.body)) {
              error = translations.text(StrKey.WRONG_ICS_FORMAT);
            }

            // If error, display message
            if (error != null) {
              DialogPredefined.showSimpleMessage(
                context,
                translations.text(StrKey.ERROR),
                error,
              );
            } else {
              // If success request, update preferences
              prefs.setCachedIcal(PrefKey.defaultCachedIcal);
              prefs.setUrlIcs(value, true);
            }
          },
        )
      ];
    }

    return SettingCard(
      header: translations.text(StrKey.SETTINGS_GENERAL),
      children: settingsGeneralElems,
    );
  }

  Widget _buildSettingsDisplay() {
    List<Widget> settingsDisplayItems = [
      ListTileNumber(
        title: translations.text(StrKey.NUMBER_WEEK),
        subtitle: translations.text(
          prefs.numberWeeks > 1
              ? StrKey.NUMBER_WEEK_DESC_PLURAL
              : StrKey.NUMBER_WEEK_DESC_ONE,
          {'nbWeeks': prefs.numberWeeks},
        ),
        defaultValue: prefs.numberWeeks,
        minValue: 1,
        maxValue: 16,
        onChange: (value) => prefs.setNumberWeeks(value, true),
      ),
      SwitchListTile(
        title: ListTileTitle(translations.text(StrKey.DISPLAY_ALL_DAYS)),
        subtitle: Text(translations.text(StrKey.DISPLAY_ALL_DAYS_DESC)),
        value: prefs.isDisplayAllDays,
        activeColor: theme.accentColor,
        onChanged: (value) => prefs.setDisplayAllDays(value, true),
      ),
    ];

    settingsDisplayItems.addAll([
      SwitchListTile(
        title: ListTileTitle(translations.text(StrKey.HIDDEN_EVENT)),
        subtitle: Text(translations.text(StrKey.FULL_HIDDEN_EVENT_DESC)),
        value: prefs.isFullHiddenEvent,
        activeColor: theme.accentColor,
        onChanged: (value) => prefs.setFullHiddenEvent(value, true),
      ),
      ListTile(
        title: ListTileTitle(translations.text(StrKey.MANAGE_HIDDEN_EVENT)),
        subtitle: Text(translations.text(StrKey.MANAGE_HIDDEN_EVENT_DESC)),
        onTap: () {
          Navigator.of(context).push(
            CustomRoute(
              fullscreenDialog: true,
              builder: (_) => ManageHiddenEvents(),
            ),
          );
        },
      )
    ]);

    return SettingCard(
      header: translations.text(StrKey.SETTINGS_DISPLAY),
      children: settingsDisplayItems,
    );
  }

  Widget _buildSettingsColors() {
    return SettingCard(
      header: translations.text(StrKey.SETTINGS_COLORS),
      children: [
        SwitchListTile(
          title: ListTileTitle(translations.text(StrKey.DARK_THEME)),
          subtitle: Text(translations.text(StrKey.DARK_THEME_DESC)),
          value: prefs.theme.darkTheme,
          activeColor: theme.accentColor,
          onChanged: (value) => prefs.setDarkTheme(value, true),
        ),
        const ListDivider(),
        ListTileColor(
          title: translations.text(StrKey.PRIMARY_COLOR),
          description: translations.text(StrKey.PRIMARY_COLOR_DESC),
          selectedColor: Color(prefs.theme.primaryColor),
          onColorChange: (color) => prefs.setPrimaryColor(color.value, true),
        ),
        const ListDivider(),
        ListTileColor(
          title: translations.text(StrKey.ACCENT_COLOR),
          description: translations.text(StrKey.ACCENT_COLOR_DESC),
          selectedColor: Color(prefs.theme.accentColor),
          onColorChange: (color) => prefs.setAccentColor(color.value, true),
          colors: [
            Colors.redAccent,
            Colors.pinkAccent,
            Colors.purpleAccent,
            Colors.deepPurpleAccent,
            Colors.indigoAccent,
            Colors.blueAccent,
            Colors.lightBlueAccent,
            Colors.cyanAccent,
            Colors.tealAccent,
            Colors.greenAccent,
            Colors.lightGreenAccent,
            Colors.limeAccent,
            Colors.yellowAccent,
            Colors.amberAccent,
            Colors.orangeAccent,
            Colors.deepOrangeAccent,
            Colors.brown,
            Colors.grey,
            Colors.blueGrey
          ],
        ),
        const ListDivider(),
        ListTileColor(
          title: translations.text(StrKey.NOTE_COLOR),
          description: translations.text(StrKey.NOTE_COLOR_DESC),
          selectedColor: Color(prefs.theme.noteColor),
          onColorChange: (color) => prefs.setNoteColor(color.value, true),
        ),
        SwitchListTile(
          title: ListTileTitle(translations.text(StrKey.GENERATE_EVENT_COLOR)),
          subtitle: Text(translations.text(StrKey.GENERATE_EVENT_COLOR_TEXT)),
          value: prefs.isGenerateEventColor,
          activeColor: Theme.of(context).accentColor,
          onChanged: (value) => prefs.setGenerateEventColor(value, true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var actions;
    if (prefs.urlIcs == null) {
      actions = [
        PopupMenuButton<MenuItem>(
          icon: const Icon(OMIcons.moreVert),
          onSelected: (MenuItem result) {
            if (result == MenuItem.REFRESH) _forceRefreshResources();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
                PopupMenuItem<MenuItem>(
                  value: MenuItem.REFRESH,
                  child: Text(translations.text(StrKey.REFRESH_AGENDAS)),
                ),
              ],
        ),
      ];
    }

    return AppbarPage(
      title: translations.text(StrKey.SETTINGS),
      actions: actions,
      body: ListView(
        children: [
          _buildSettingsGeneral(),
          _buildSettingsDisplay(),
          _buildSettingsColors()
        ],
      ),
    );
  }
}

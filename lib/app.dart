import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myagenda/keys/route_key.dart';
import 'package:myagenda/screens/about/aboutscreen.dart';
import 'package:myagenda/screens/about/licences/licences.dart';
import 'package:myagenda/screens/find_schedules/find_schedules.dart';
import 'package:myagenda/screens/help/help.dart';
import 'package:myagenda/screens/home/home.dart';
import 'package:myagenda/screens/introduction/intro.dart';
import 'package:myagenda/screens/login/login.dart';
import 'package:myagenda/screens/settings/settings.dart';
import 'package:myagenda/screens/splashscreen/splashscreen.dart';
import 'package:myagenda/screens/supportme/supportme.dart';
import 'package:myagenda/utils/analytics.dart';
import 'package:myagenda/utils/custom_route.dart';
import 'package:myagenda/utils/functions.dart';
import 'package:myagenda/utils/preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:myagenda/utils/translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final routes = {
  RouteKey.SPLASHSCREEN: SplashScreen(),
  RouteKey.HOME: HomeScreen(),
  RouteKey.FINDSCHEDULES: FindSchedulesScreen(),
  RouteKey.SETTINGS: SettingsScreen(),
  RouteKey.HELP: HelpScreen(),
  RouteKey.ABOUT: AboutScreen(),
  RouteKey.LICENCES: LicencesScreen(),
  RouteKey.INTRO: IntroductionScreen(),
  RouteKey.LOGIN: LoginScreen(),
  RouteKey.SUPPORTME: SupportMeScreen(),
};

class App extends StatelessWidget {
  static var analytics = FirebaseAnalytics();
  static var observer = FirebaseAnalyticsObserver(analytics: analytics);

  Widget _buildMaterialApp(ThemeData theme) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MyAgenda",
      theme: theme,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: translations.supportedLocales(),
      navigatorObservers: [observer],
      initialRoute: RouteKey.SPLASHSCREEN,
      onGenerateRoute: (RouteSettings settings) {
        if (routes.containsKey(settings.name))
          return CustomRoute(
            builder: (_) => routes[settings.name],
            settings: settings,
          );
        assert(false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsProvider(
      analytics,
      observer,
      child: PreferencesProvider(
        child: Builder(
          builder: (context) {
            final themePrefs = PreferencesProvider.of(context).theme;
            final theme = ThemeData(
              platform: TargetPlatform.android,
              fontFamily: 'GoogleSans',
              brightness: getBrightness(themePrefs.darkTheme),
              primaryColor: Color(themePrefs.primaryColor),
              accentColor: Color(themePrefs.accentColor),
              toggleableActiveColor: Color(themePrefs.accentColor),
              textSelectionHandleColor: Color(themePrefs.accentColor),
            );

            SystemUiOverlayStyle style = theme.brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark;

            SystemChrome.setSystemUIOverlayStyle(style.copyWith(
              statusBarColor: Colors.transparent,
            ));

            return _buildMaterialApp(theme);
          },
        ),
      ),
    );
  }
}

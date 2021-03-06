class PrefsTheme {
  bool darkTheme;
  int primaryColor;
  int accentColor;
  int noteColor;

  PrefsTheme({
    this.darkTheme,
    this.primaryColor,
    this.accentColor,
    this.noteColor,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrefsTheme &&
          runtimeType == other.runtimeType &&
          darkTheme == other.darkTheme &&
          primaryColor == other.primaryColor &&
          accentColor == other.accentColor &&
          noteColor == other.noteColor;

  @override
  int get hashCode =>
      darkTheme.hashCode ^
      primaryColor.hashCode ^
      accentColor.hashCode ^
      noteColor.hashCode;
}

class Strings {
  static String emptyString = "";

  static String get homePageTitle => localized("IronBreeze");
  static String get imagesListScreen => localized("Images & words");

  static String localized(String original) {
    // TODO: Simply integrate that with the host OS system (could be iOS localization ".strings" file or the Android "strings.xml" file)
    return original;
  }

  static String localizedNotAvailableString() {
    return localized("N/A");
  }
}

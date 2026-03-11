extension AssetsUtils on String {
  /// assets/svg/$this.svg
  String get svg => 'assets/svg/$this.svg';

  // ignore: non_constant_identifier_names
  String get order_svg => 'assets/svg/order_svg/$this.svg';

  String get flagSvg => 'assets/flags/$this.svg';

  /// assets/images/$this.png
  String get png => 'assets/images/$this.png';

  /// assets/images/$this.jpg
  String get jpg => 'assets/images/$this.jpg';

  /// assets/animations/$this.json
  String get json => 'assets/animations/$this.json';

  /// assets/animations/$this.flr
  String get flr => 'assets/animations/$this.flr';

  /// assets/animations/$this.riv
  String get riv => 'assets/animations/$this.riv';
}

abstract class AppAssets {
  /// region SVG Section

  static String get rdb => 'rdb'.svg;
  static String get rammazDigitalBanking => 'rammaz_digital_banking'.svg;
  static String get rammaz => 'rammaz'.svg;
  static String get syriaFlagSvg => 'syria_flag'.svg;
  static String get kurdishFlagSvg => 'kurdish_flag'.svg;
  static String get cancelSvg => 'cancel'.svg;
  static String get editPenSvg => 'edit_pen'.svg;
  static String get enterSvg => 'enter'.svg;
  static String get phoneCallSvg => 'phone_call'.svg;
  static String get phoneCallOutlinedSvg => 'phone_call_outlined'.svg;
  static String get phoneOtpSvg => 'phone_otp'.svg;
  static String get privacySvg => 'privacy'.svg;
  static String get registerInfoSvg => 'register_info'.svg;
  static String get smsSvg => 'sms'.svg;
  static String get submitArrowSvg => 'submit_arrow'.svg;
  static String get whatsappSvg => 'whatsapp'.svg;
  static String get verifiedNumberSvg => 'verified_number'.svg;
  static String get termsSvg => 'terms'.svg;
  static String get trydosTextSvg => 'trydos_text'.svg;
}

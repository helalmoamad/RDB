import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
  String get _version => dotenv.env['CLOUDINARY_VERSION']!;
  String get _cloudinaryName => dotenv.env['CLOUDINARY_NAME']!;

  String noScope() => '$_version/$_cloudinaryName/$this';
}

abstract class CloudinaryEndPoints {
  static final uploadEP = 'upload'.noScope();
}

abstract class CloudinaryUrls {
  static final String _baseUri = dotenv.env['CLOUDINARY_URL']!;
  static final String _loadPreset = dotenv.env['CLOUDINARY_LOAD_PRESET']!;

  static Uri get baseUri => Uri.parse(_baseUri);

  // ignore: non_constant_identifier_names
  static String get LoadPreset => _loadPreset;
}

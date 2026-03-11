import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
  //  String noScope() => '$_version/$_cloudinaryName/$this';
}

abstract class WebAppEndPoints {
  static const imageSearchEP = "api/image-search";
  static const addLikeCommentEP = "public_comment/likes/like";
  static const addLikeOFProductEP = "products/like";
  static const removeLikeOFProductEP = "products/unlike";
  static const removeLikeCommentEP = "public_comment/likes/unlike";
  static String translateCommentsToAppLanEP(String commentId) =>
      "public_comment/comments/$commentId/translate";
  static const mainCategoriesEP = "api/home/mainCategories";
  static const editSocialProductEP = "api/editSocialProduct";
  static const homeBoutiquesEP = "api/home/boutiques";
  static const searchProductEP = "api/products/searchInCatalog";
  static const productFeaturedEP = "api/products/featured";
  static const createOrderRatingEP = "public_comment/comments/create";
  static String updateOrderRatingEP(String commentId) =>
      "public_comment/comments/$commentId/update";
  static String deleteOrderRatingEP(String commentId) =>
      "public_comment/comments/$commentId/delete";
  static const getFqaCommentsEP = "api/products/comments/fqa_comments";
  static const getBuyersCommentsEP = "api/products/comments/buyers_comments";
  static const generateTokenForCommentEP = "public_comment/auth/exchange_token";
  static const getOrderRatingEP = "api/products/comments/order_rating";
  static const getCommentsFromAnalyticsEP = "api/products/comments/comments";
  static const productRecommendedEP = "api/products/recomended";
  static String productDetailsEP(String slug) =>
      "api/mobile/product/details/$slug";
  static String getAuthProductDetailsEP(String slug) =>
      "api/mobile/product/qty/$slug";
  //  static final imageSearchEP = "api/image-search";
}

abstract class WebUrls {
  static final String _baseUri = dotenv.env['WEB_APP']!;
  static final String _loadPreset = dotenv.env['WEB_APP']!;

  static Uri get baseUri => Uri.parse(_baseUri);

  // ignore: non_constant_identifier_names
  static String get LoadPreset => _loadPreset;
}

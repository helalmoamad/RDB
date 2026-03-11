import 'package:json_annotation/json_annotation.dart';

class PayloadModel {
  factory PayloadModel.fromJson(Map<String,dynamic> json) {
    return const PayloadModel();
  }
  const PayloadModel();
}

enum NotificationTypeName {
  @JsonValue('Delivery')
  delivery,
}

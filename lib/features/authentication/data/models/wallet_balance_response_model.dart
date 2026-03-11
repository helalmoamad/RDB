import 'dart:convert';

WalletBalanceResponseModel walletBalanceResponseModelFromJson(String str) =>
    WalletBalanceResponseModel.fromJson(json.decode(str));

String walletBalanceResponseModelToJson(WalletBalanceResponseModel data) =>
    json.encode(data.toJson());

class WalletBalanceResponseModel {
  final String? id;
  final String? accountId;
  final String? assetType;
  final String? assetId;
  final String? assetSymbol;
  final num? available;
  final num? locked;
  final num? reserved;
  final String? createdAt;
  final String? updatedAt;
  final WalletBalanceAsset? asset;
  final String? accountSubtype;

  WalletBalanceResponseModel({
    this.id,
    this.accountId,
    this.assetType,
    this.assetId,
    this.assetSymbol,
    this.available,
    this.locked,
    this.reserved,
    this.createdAt,
    this.updatedAt,
    this.asset,
    this.accountSubtype,
  });

  factory WalletBalanceResponseModel.fromJson(Map<String, dynamic> json) =>
      WalletBalanceResponseModel(
        id: json["id"],
        accountId: json["accountId"],
        assetType: json["assetType"],
        assetId: json["assetId"],
        assetSymbol: json["assetSymbol"],
        available: json["available"],
        locked: json["locked"],
        reserved: json["reserved"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        asset: json["asset"] == null
            ? null
            : WalletBalanceAsset.fromJson(json["asset"]),
        accountSubtype: json["accountSubtype"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "accountId": accountId,
        "assetType": assetType,
        "assetId": assetId,
        "assetSymbol": assetSymbol,
        "available": available,
        "locked": locked,
        "reserved": reserved,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "asset": asset?.toJson(),
        "accountSubtype": accountSubtype,
      };
}

class WalletBalanceAsset {
  final String? id;
  final String? symbol;
  final String? name;

  WalletBalanceAsset({
    this.id,
    this.symbol,
    this.name,
  });

  factory WalletBalanceAsset.fromJson(Map<String, dynamic> json) =>
      WalletBalanceAsset(
        id: json["id"],
        symbol: json["symbol"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "symbol": symbol,
        "name": name,
      };
}

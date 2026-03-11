// To parse this JSON data, do
//
//     final getUserCountryResponseModel = getUserCountryResponseModelFromJson(jsonString);

import 'dart:convert';

GetUserCountryResponseModel getUserCountryResponseModelFromJson(String str) =>
    GetUserCountryResponseModel.fromJson(json.decode(str));

String getUserCountryResponseModelToJson(GetUserCountryResponseModel data) =>
    json.encode(data.toJson());

class GetUserCountryResponseModel {
  final String? aboutUs;
  final String? ip;
  final bool? success;
  final String? type;
  final String? continent;
  final String? continentCode;
  final String? country;
  final String? countryCode;
  final String? region;
  final String? regionCode;
  final String? city;
  final double? latitude;
  final double? longitude;
  final bool? isEu;
  final String? postal;
  final String? callingCode;
  final String? capital;
  final String? borders;
  final Flag? flag;
  final Connection? connection;
  final Timezone? timezone;

  GetUserCountryResponseModel({
    this.aboutUs,
    this.ip,
    this.success,
    this.type,
    this.continent,
    this.continentCode,
    this.country,
    this.countryCode,
    this.region,
    this.regionCode,
    this.city,
    this.latitude,
    this.longitude,
    this.isEu,
    this.postal,
    this.callingCode,
    this.capital,
    this.borders,
    this.flag,
    this.connection,
    this.timezone,
  });

  GetUserCountryResponseModel copyWith({
    String? aboutUs,
    String? ip,
    bool? success,
    String? type,
    String? continent,
    String? continentCode,
    String? country,
    String? countryCode,
    String? region,
    String? regionCode,
    String? city,
    double? latitude,
    double? longitude,
    bool? isEu,
    String? postal,
    String? callingCode,
    String? capital,
    String? borders,
    Flag? flag,
    Connection? connection,
    Timezone? timezone,
  }) =>
      GetUserCountryResponseModel(
        aboutUs: aboutUs ?? this.aboutUs,
        ip: ip ?? this.ip,
        success: success ?? this.success,
        type: type ?? this.type,
        continent: continent ?? this.continent,
        continentCode: continentCode ?? this.continentCode,
        country: country ?? this.country,
        countryCode: countryCode ?? this.countryCode,
        region: region ?? this.region,
        regionCode: regionCode ?? this.regionCode,
        city: city ?? this.city,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isEu: isEu ?? this.isEu,
        postal: postal ?? this.postal,
        callingCode: callingCode ?? this.callingCode,
        capital: capital ?? this.capital,
        borders: borders ?? this.borders,
        flag: flag ?? this.flag,
        connection: connection ?? this.connection,
        timezone: timezone ?? this.timezone,
      );

  factory GetUserCountryResponseModel.fromJson(Map<String, dynamic> json) =>
      GetUserCountryResponseModel(
        aboutUs: json["About_Us"],
        ip: json["ip"],
        success: json["success"],
        type: json["type"],
        continent: json["continent"],
        continentCode: json["continent_code"],
        country: json["country"],
        countryCode: json["country_code"],
        region: json["region"],
        regionCode: json["region_code"],
        city: json["city"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        isEu: json["is_eu"],
        postal: json["postal"],
        callingCode: json["calling_code"],
        capital: json["capital"],
        borders: json["borders"],
        flag: json["flag"] == null ? null : Flag.fromJson(json["flag"]),
        connection: json["connection"] == null
            ? null
            : Connection.fromJson(json["connection"]),
        timezone: json["timezone"] == null
            ? null
            : Timezone.fromJson(json["timezone"]),
      );

  Map<String, dynamic> toJson() => {
        "About_Us": aboutUs,
        "ip": ip,
        "success": success,
        "type": type,
        "continent": continent,
        "continent_code": continentCode,
        "country": country,
        "country_code": countryCode,
        "region": region,
        "region_code": regionCode,
        "city": city,
        "latitude": latitude,
        "longitude": longitude,
        "is_eu": isEu,
        "postal": postal,
        "calling_code": callingCode,
        "capital": capital,
        "borders": borders,
        "flag": flag?.toJson(),
        "connection": connection?.toJson(),
        "timezone": timezone?.toJson(),
      };
}

class Connection {
  final int? asn;
  final String? org;
  final String? isp;
  final String? domain;

  Connection({
    this.asn,
    this.org,
    this.isp,
    this.domain,
  });

  Connection copyWith({
    int? asn,
    String? org,
    String? isp,
    String? domain,
  }) =>
      Connection(
        asn: asn ?? this.asn,
        org: org ?? this.org,
        isp: isp ?? this.isp,
        domain: domain ?? this.domain,
      );

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        asn: json["asn"],
        org: json["org"],
        isp: json["isp"],
        domain: json["domain"],
      );

  Map<String, dynamic> toJson() => {
        "asn": asn,
        "org": org,
        "isp": isp,
        "domain": domain,
      };
}

class Flag {
  final String? img;
  final String? emoji;
  final String? emojiUnicode;

  Flag({
    this.img,
    this.emoji,
    this.emojiUnicode,
  });

  Flag copyWith({
    String? img,
    String? emoji,
    String? emojiUnicode,
  }) =>
      Flag(
        img: img ?? this.img,
        emoji: emoji ?? this.emoji,
        emojiUnicode: emojiUnicode ?? this.emojiUnicode,
      );

  factory Flag.fromJson(Map<String, dynamic> json) => Flag(
        img: json["img"],
        emoji: json["emoji"],
        emojiUnicode: json["emoji_unicode"],
      );

  Map<String, dynamic> toJson() => {
        "img": img,
        "emoji": emoji,
        "emoji_unicode": emojiUnicode,
      };
}

class Timezone {
  final String? id;
  final String? abbr;
  final bool? isDst;
  final int? offset;
  final String? utc;
  final DateTime? currentTime;

  Timezone({
    this.id,
    this.abbr,
    this.isDst,
    this.offset,
    this.utc,
    this.currentTime,
  });

  Timezone copyWith({
    String? id,
    String? abbr,
    bool? isDst,
    int? offset,
    String? utc,
    DateTime? currentTime,
  }) =>
      Timezone(
        id: id ?? this.id,
        abbr: abbr ?? this.abbr,
        isDst: isDst ?? this.isDst,
        offset: offset ?? this.offset,
        utc: utc ?? this.utc,
        currentTime: currentTime ?? this.currentTime,
      );

  factory Timezone.fromJson(Map<String, dynamic> json) => Timezone(
        id: json["id"],
        abbr: json["abbr"],
        isDst: json["is_dst"],
        offset: json["offset"],
        utc: json["utc"],
        currentTime: json["current_time"] == null
            ? null
            : DateTime.parse(json["current_time"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "abbr": abbr,
        "is_dst": isDst,
        "offset": offset,
        "utc": utc,
        "current_time": currentTime?.toIso8601String(),
      };
}

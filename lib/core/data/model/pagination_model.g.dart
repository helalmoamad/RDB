// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginationModel<T> _$PaginationModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PaginationModel<T>(
  items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
  page: (json['page'] as num).toInt(),
  offset: json['offset'] as String?,
  total: (json['total'] as num?)?.toInt(),
  paginationStatus: $enumDecode(
    _$PaginationStatusEnumMap,
    json['paginationStatus'],
  ),
  hasReachedMax: json['hasReachedMax'] as bool,
);

Map<String, dynamic> _$PaginationModelToJson<T>(
  PaginationModel<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'items': instance.items.map(toJsonT).toList(),
  'paginationStatus': _$PaginationStatusEnumMap[instance.paginationStatus]!,
  'page': instance.page,
  'total': instance.total,
  'offset': instance.offset,
  'hasReachedMax': instance.hasReachedMax,
};

const _$PaginationStatusEnumMap = {
  PaginationStatus.initial: 'initial',
  PaginationStatus.success: 'success',
  PaginationStatus.failure: 'failure',
  PaginationStatus.loading: 'loading',
};

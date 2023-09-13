// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CameraItem _$CameraItemFromJson(Map<String, dynamic> json) {
  return _CameraItem.fromJson(json);
}

/// @nodoc
mixin _$CameraItem {
  String get name => throw _privateConstructorUsedError;
  @Uint8ListConverter()
  Uint8List get bytes => throw _privateConstructorUsedError;
  int get width => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError;
  CameraItemType get type => throw _privateConstructorUsedError;
  CameraLensDirection get lensDirection => throw _privateConstructorUsedError;
  DeviceOrientation get orientation => throw _privateConstructorUsedError;
  @UtcDateTimeJsonConverter()
  DateTime get timeStamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CameraItemCopyWith<CameraItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CameraItemCopyWith<$Res> {
  factory $CameraItemCopyWith(
          CameraItem value, $Res Function(CameraItem) then) =
      _$CameraItemCopyWithImpl<$Res, CameraItem>;
  @useResult
  $Res call(
      {String name,
      @Uint8ListConverter() Uint8List bytes,
      int width,
      int height,
      CameraItemType type,
      CameraLensDirection lensDirection,
      DeviceOrientation orientation,
      @UtcDateTimeJsonConverter() DateTime timeStamp});
}

/// @nodoc
class _$CameraItemCopyWithImpl<$Res, $Val extends CameraItem>
    implements $CameraItemCopyWith<$Res> {
  _$CameraItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? bytes = null,
    Object? width = null,
    Object? height = null,
    Object? type = null,
    Object? lensDirection = null,
    Object? orientation = null,
    Object? timeStamp = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      bytes: null == bytes
          ? _value.bytes
          : bytes // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CameraItemType,
      lensDirection: null == lensDirection
          ? _value.lensDirection
          : lensDirection // ignore: cast_nullable_to_non_nullable
              as CameraLensDirection,
      orientation: null == orientation
          ? _value.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as DeviceOrientation,
      timeStamp: null == timeStamp
          ? _value.timeStamp
          : timeStamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CameraItemCopyWith<$Res>
    implements $CameraItemCopyWith<$Res> {
  factory _$$_CameraItemCopyWith(
          _$_CameraItem value, $Res Function(_$_CameraItem) then) =
      __$$_CameraItemCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      @Uint8ListConverter() Uint8List bytes,
      int width,
      int height,
      CameraItemType type,
      CameraLensDirection lensDirection,
      DeviceOrientation orientation,
      @UtcDateTimeJsonConverter() DateTime timeStamp});
}

/// @nodoc
class __$$_CameraItemCopyWithImpl<$Res>
    extends _$CameraItemCopyWithImpl<$Res, _$_CameraItem>
    implements _$$_CameraItemCopyWith<$Res> {
  __$$_CameraItemCopyWithImpl(
      _$_CameraItem _value, $Res Function(_$_CameraItem) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? bytes = null,
    Object? width = null,
    Object? height = null,
    Object? type = null,
    Object? lensDirection = null,
    Object? orientation = null,
    Object? timeStamp = null,
  }) {
    return _then(_$_CameraItem(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      bytes: null == bytes
          ? _value.bytes
          : bytes // ignore: cast_nullable_to_non_nullable
              as Uint8List,
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as int,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CameraItemType,
      lensDirection: null == lensDirection
          ? _value.lensDirection
          : lensDirection // ignore: cast_nullable_to_non_nullable
              as CameraLensDirection,
      orientation: null == orientation
          ? _value.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as DeviceOrientation,
      timeStamp: null == timeStamp
          ? _value.timeStamp
          : timeStamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CameraItem extends _CameraItem {
  const _$_CameraItem(
      {required this.name,
      @Uint8ListConverter() required this.bytes,
      required this.width,
      required this.height,
      required this.type,
      required this.lensDirection,
      required this.orientation,
      @UtcDateTimeJsonConverter() required this.timeStamp})
      : super._();

  factory _$_CameraItem.fromJson(Map<String, dynamic> json) =>
      _$$_CameraItemFromJson(json);

  @override
  final String name;
  @override
  @Uint8ListConverter()
  final Uint8List bytes;
  @override
  final int width;
  @override
  final int height;
  @override
  final CameraItemType type;
  @override
  final CameraLensDirection lensDirection;
  @override
  final DeviceOrientation orientation;
  @override
  @UtcDateTimeJsonConverter()
  final DateTime timeStamp;

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CameraItemCopyWith<_$_CameraItem> get copyWith =>
      __$$_CameraItemCopyWithImpl<_$_CameraItem>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CameraItemToJson(
      this,
    );
  }
}

abstract class _CameraItem extends CameraItem {
  const factory _CameraItem(
          {required final String name,
          @Uint8ListConverter() required final Uint8List bytes,
          required final int width,
          required final int height,
          required final CameraItemType type,
          required final CameraLensDirection lensDirection,
          required final DeviceOrientation orientation,
          @UtcDateTimeJsonConverter() required final DateTime timeStamp}) =
      _$_CameraItem;
  const _CameraItem._() : super._();

  factory _CameraItem.fromJson(Map<String, dynamic> json) =
      _$_CameraItem.fromJson;

  @override
  String get name;
  @override
  @Uint8ListConverter()
  Uint8List get bytes;
  @override
  int get width;
  @override
  int get height;
  @override
  CameraItemType get type;
  @override
  CameraLensDirection get lensDirection;
  @override
  DeviceOrientation get orientation;
  @override
  @UtcDateTimeJsonConverter()
  DateTime get timeStamp;
  @override
  @JsonKey(ignore: true)
  _$$_CameraItemCopyWith<_$_CameraItem> get copyWith =>
      throw _privateConstructorUsedError;
}

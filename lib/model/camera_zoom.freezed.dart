// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_zoom.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CameraZoom _$CameraZoomFromJson(Map<String, dynamic> json) {
  return _CameraZoom.fromJson(json);
}

/// @nodoc
mixin _$CameraZoom {
  double get min => throw _privateConstructorUsedError;
  double get max => throw _privateConstructorUsedError;
  double get previous => throw _privateConstructorUsedError;
  double get current => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CameraZoomCopyWith<CameraZoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CameraZoomCopyWith<$Res> {
  factory $CameraZoomCopyWith(
          CameraZoom value, $Res Function(CameraZoom) then) =
      _$CameraZoomCopyWithImpl<$Res, CameraZoom>;
  @useResult
  $Res call({double min, double max, double previous, double current});
}

/// @nodoc
class _$CameraZoomCopyWithImpl<$Res, $Val extends CameraZoom>
    implements $CameraZoomCopyWith<$Res> {
  _$CameraZoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = null,
    Object? previous = null,
    Object? current = null,
  }) {
    return _then(_value.copyWith(
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double,
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as double,
      previous: null == previous
          ? _value.previous
          : previous // ignore: cast_nullable_to_non_nullable
              as double,
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CameraZoomImplCopyWith<$Res>
    implements $CameraZoomCopyWith<$Res> {
  factory _$$CameraZoomImplCopyWith(
          _$CameraZoomImpl value, $Res Function(_$CameraZoomImpl) then) =
      __$$CameraZoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double min, double max, double previous, double current});
}

/// @nodoc
class __$$CameraZoomImplCopyWithImpl<$Res>
    extends _$CameraZoomCopyWithImpl<$Res, _$CameraZoomImpl>
    implements _$$CameraZoomImplCopyWith<$Res> {
  __$$CameraZoomImplCopyWithImpl(
      _$CameraZoomImpl _value, $Res Function(_$CameraZoomImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? min = null,
    Object? max = null,
    Object? previous = null,
    Object? current = null,
  }) {
    return _then(_$CameraZoomImpl(
      min: null == min
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as double,
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as double,
      previous: null == previous
          ? _value.previous
          : previous // ignore: cast_nullable_to_non_nullable
              as double,
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CameraZoomImpl implements _CameraZoom {
  const _$CameraZoomImpl(
      {required this.min,
      required this.max,
      required this.previous,
      required this.current});

  factory _$CameraZoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$CameraZoomImplFromJson(json);

  @override
  final double min;
  @override
  final double max;
  @override
  final double previous;
  @override
  final double current;

  @override
  String toString() {
    return 'CameraZoom(min: $min, max: $max, previous: $previous, current: $current)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CameraZoomImpl &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.previous, previous) ||
                other.previous == previous) &&
            (identical(other.current, current) || other.current == current));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, min, max, previous, current);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CameraZoomImplCopyWith<_$CameraZoomImpl> get copyWith =>
      __$$CameraZoomImplCopyWithImpl<_$CameraZoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CameraZoomImplToJson(
      this,
    );
  }
}

abstract class _CameraZoom implements CameraZoom {
  const factory _CameraZoom(
      {required final double min,
      required final double max,
      required final double previous,
      required final double current}) = _$CameraZoomImpl;

  factory _CameraZoom.fromJson(Map<String, dynamic> json) =
      _$CameraZoomImpl.fromJson;

  @override
  double get min;
  @override
  double get max;
  @override
  double get previous;
  @override
  double get current;
  @override
  @JsonKey(ignore: true)
  _$$CameraZoomImplCopyWith<_$CameraZoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

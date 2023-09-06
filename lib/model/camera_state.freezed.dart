// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'camera_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CameraState _$CameraStateFromJson(Map<String, dynamic> json) {
  return _CameraState.fromJson(json);
}

/// @nodoc
mixin _$CameraState {
  @CameraControllerConverter()
  CameraController? get controller => throw _privateConstructorUsedError;
  CameraStatus get status => throw _privateConstructorUsedError;
  DeviceOrientation get orientation => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CameraStateCopyWith<CameraState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CameraStateCopyWith<$Res> {
  factory $CameraStateCopyWith(
          CameraState value, $Res Function(CameraState) then) =
      _$CameraStateCopyWithImpl<$Res, CameraState>;
  @useResult
  $Res call(
      {@CameraControllerConverter() CameraController? controller,
      CameraStatus status,
      DeviceOrientation orientation});
}

/// @nodoc
class _$CameraStateCopyWithImpl<$Res, $Val extends CameraState>
    implements $CameraStateCopyWith<$Res> {
  _$CameraStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controller = freezed,
    Object? status = null,
    Object? orientation = null,
  }) {
    return _then(_value.copyWith(
      controller: freezed == controller
          ? _value.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as CameraController?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CameraStatus,
      orientation: null == orientation
          ? _value.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as DeviceOrientation,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CameraStateCopyWith<$Res>
    implements $CameraStateCopyWith<$Res> {
  factory _$$_CameraStateCopyWith(
          _$_CameraState value, $Res Function(_$_CameraState) then) =
      __$$_CameraStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@CameraControllerConverter() CameraController? controller,
      CameraStatus status,
      DeviceOrientation orientation});
}

/// @nodoc
class __$$_CameraStateCopyWithImpl<$Res>
    extends _$CameraStateCopyWithImpl<$Res, _$_CameraState>
    implements _$$_CameraStateCopyWith<$Res> {
  __$$_CameraStateCopyWithImpl(
      _$_CameraState _value, $Res Function(_$_CameraState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controller = freezed,
    Object? status = null,
    Object? orientation = null,
  }) {
    return _then(_$_CameraState(
      controller: freezed == controller
          ? _value.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as CameraController?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CameraStatus,
      orientation: null == orientation
          ? _value.orientation
          : orientation // ignore: cast_nullable_to_non_nullable
              as DeviceOrientation,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_CameraState extends _CameraState {
  const _$_CameraState(
      {@CameraControllerConverter() required this.controller,
      required this.status,
      required this.orientation})
      : super._();

  factory _$_CameraState.fromJson(Map<String, dynamic> json) =>
      _$$_CameraStateFromJson(json);

  @override
  @CameraControllerConverter()
  final CameraController? controller;
  @override
  final CameraStatus status;
  @override
  final DeviceOrientation orientation;

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CameraStateCopyWith<_$_CameraState> get copyWith =>
      __$$_CameraStateCopyWithImpl<_$_CameraState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CameraStateToJson(
      this,
    );
  }
}

abstract class _CameraState extends CameraState {
  const factory _CameraState(
      {@CameraControllerConverter() required final CameraController? controller,
      required final CameraStatus status,
      required final DeviceOrientation orientation}) = _$_CameraState;
  const _CameraState._() : super._();

  factory _CameraState.fromJson(Map<String, dynamic> json) =
      _$_CameraState.fromJson;

  @override
  @CameraControllerConverter()
  CameraController? get controller;
  @override
  CameraStatus get status;
  @override
  DeviceOrientation get orientation;
  @override
  @JsonKey(ignore: true)
  _$$_CameraStateCopyWith<_$_CameraState> get copyWith =>
      throw _privateConstructorUsedError;
}

// This is a generated file - do not edit.
//
// Generated from updates.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'updates.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'updates.pbenum.dart';

/// Request to subscribe to data updates
class SubscribeRequest extends $pb.GeneratedMessage {
  factory SubscribeRequest({
    $core.String? dataType,
    $core.String? filter,
    $core.String? token,
  }) {
    final result = create();
    if (dataType != null) result.dataType = dataType;
    if (filter != null) result.filter = filter;
    if (token != null) result.token = token;
    return result;
  }

  SubscribeRequest._();

  factory SubscribeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubscribeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dataType', protoName: 'dataType')
    ..aOS(2, _omitFieldNames ? '' : 'filter')
    ..aOS(3, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeRequest copyWith(void Function(SubscribeRequest) updates) =>
      super.copyWith((message) => updates(message as SubscribeRequest))
          as SubscribeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeRequest create() => SubscribeRequest._();
  @$core.override
  SubscribeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubscribeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeRequest>(create);
  static SubscribeRequest? _defaultInstance;

  /// Type of data to subscribe to (e.g., "users", "orders", "stats")
  @$pb.TagNumber(1)
  $core.String get dataType => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDataType() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataType() => $_clearField(1);

  /// Optional filter criteria (JSON format)
  @$pb.TagNumber(2)
  $core.String get filter => $_getSZ(1);
  @$pb.TagNumber(2)
  set filter($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFilter() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilter() => $_clearField(2);

  /// Authentication token
  @$pb.TagNumber(3)
  $core.String get token => $_getSZ(2);
  @$pb.TagNumber(3)
  set token($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearToken() => $_clearField(3);
}

/// Request to unsubscribe from updates
class UnsubscribeRequest extends $pb.GeneratedMessage {
  factory UnsubscribeRequest({
    $core.String? subscriptionId,
  }) {
    final result = create();
    if (subscriptionId != null) result.subscriptionId = subscriptionId;
    return result;
  }

  UnsubscribeRequest._();

  factory UnsubscribeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnsubscribeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnsubscribeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'subscriptionId',
        protoName: 'subscriptionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnsubscribeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnsubscribeRequest copyWith(void Function(UnsubscribeRequest) updates) =>
      super.copyWith((message) => updates(message as UnsubscribeRequest))
          as UnsubscribeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnsubscribeRequest create() => UnsubscribeRequest._();
  @$core.override
  UnsubscribeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnsubscribeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnsubscribeRequest>(create);
  static UnsubscribeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get subscriptionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set subscriptionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSubscriptionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSubscriptionId() => $_clearField(1);
}

/// Response for unsubscribe
class UnsubscribeResponse extends $pb.GeneratedMessage {
  factory UnsubscribeResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    return result;
  }

  UnsubscribeResponse._();

  factory UnsubscribeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnsubscribeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnsubscribeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnsubscribeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnsubscribeResponse copyWith(void Function(UnsubscribeResponse) updates) =>
      super.copyWith((message) => updates(message as UnsubscribeResponse))
          as UnsubscribeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnsubscribeResponse create() => UnsubscribeResponse._();
  @$core.override
  UnsubscribeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnsubscribeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnsubscribeResponse>(create);
  static UnsubscribeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

/// Update message sent to subscribers
class UpdateMessage extends $pb.GeneratedMessage {
  factory UpdateMessage({
    $core.String? updateId,
    $core.String? dataType,
    ChangeType? changeType,
    $core.String? data,
    $fixnum.Int64? timestamp,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (updateId != null) result.updateId = updateId;
    if (dataType != null) result.dataType = dataType;
    if (changeType != null) result.changeType = changeType;
    if (data != null) result.data = data;
    if (timestamp != null) result.timestamp = timestamp;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  UpdateMessage._();

  factory UpdateMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'updateId', protoName: 'updateId')
    ..aOS(2, _omitFieldNames ? '' : 'dataType', protoName: 'dataType')
    ..aE<ChangeType>(3, _omitFieldNames ? '' : 'changeType',
        protoName: 'changeType', enumValues: ChangeType.values)
    ..aOS(4, _omitFieldNames ? '' : 'data')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'UpdateMessage.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('axle'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateMessage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateMessage copyWith(void Function(UpdateMessage) updates) =>
      super.copyWith((message) => updates(message as UpdateMessage))
          as UpdateMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateMessage create() => UpdateMessage._();
  @$core.override
  UpdateMessage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateMessage>(create);
  static UpdateMessage? _defaultInstance;

  /// Unique ID for this update
  @$pb.TagNumber(1)
  $core.String get updateId => $_getSZ(0);
  @$pb.TagNumber(1)
  set updateId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUpdateId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUpdateId() => $_clearField(1);

  /// Type of data being updated
  @$pb.TagNumber(2)
  $core.String get dataType => $_getSZ(1);
  @$pb.TagNumber(2)
  set dataType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDataType() => $_has(1);
  @$pb.TagNumber(2)
  void clearDataType() => $_clearField(2);

  /// Type of change (created, updated, deleted)
  @$pb.TagNumber(3)
  ChangeType get changeType => $_getN(2);
  @$pb.TagNumber(3)
  set changeType(ChangeType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasChangeType() => $_has(2);
  @$pb.TagNumber(3)
  void clearChangeType() => $_clearField(3);

  /// The actual data (JSON format for flexibility)
  @$pb.TagNumber(4)
  $core.String get data => $_getSZ(3);
  @$pb.TagNumber(4)
  set data($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasData() => $_has(3);
  @$pb.TagNumber(4)
  void clearData() => $_clearField(4);

  /// Timestamp of the change
  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);

  /// Optional metadata
  @$pb.TagNumber(6)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(5);
}

/// Predefined data types for common use cases
class UserCountUpdate extends $pb.GeneratedMessage {
  factory UserCountUpdate({
    $core.int? totalUsers,
    $core.int? activeUsers,
    $core.int? newUsersToday,
  }) {
    final result = create();
    if (totalUsers != null) result.totalUsers = totalUsers;
    if (activeUsers != null) result.activeUsers = activeUsers;
    if (newUsersToday != null) result.newUsersToday = newUsersToday;
    return result;
  }

  UserCountUpdate._();

  factory UserCountUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserCountUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UserCountUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'totalUsers', protoName: 'totalUsers')
    ..aI(2, _omitFieldNames ? '' : 'activeUsers', protoName: 'activeUsers')
    ..aI(3, _omitFieldNames ? '' : 'newUsersToday', protoName: 'newUsersToday')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserCountUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserCountUpdate copyWith(void Function(UserCountUpdate) updates) =>
      super.copyWith((message) => updates(message as UserCountUpdate))
          as UserCountUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserCountUpdate create() => UserCountUpdate._();
  @$core.override
  UserCountUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserCountUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UserCountUpdate>(create);
  static UserCountUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get totalUsers => $_getIZ(0);
  @$pb.TagNumber(1)
  set totalUsers($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalUsers() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalUsers() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get activeUsers => $_getIZ(1);
  @$pb.TagNumber(2)
  set activeUsers($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActiveUsers() => $_has(1);
  @$pb.TagNumber(2)
  void clearActiveUsers() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get newUsersToday => $_getIZ(2);
  @$pb.TagNumber(3)
  set newUsersToday($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNewUsersToday() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewUsersToday() => $_clearField(3);
}

class StatsUpdate extends $pb.GeneratedMessage {
  factory StatsUpdate({
    $core.String? statName,
    $core.double? value,
    $core.String? unit,
  }) {
    final result = create();
    if (statName != null) result.statName = statName;
    if (value != null) result.value = value;
    if (unit != null) result.unit = unit;
    return result;
  }

  StatsUpdate._();

  factory StatsUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StatsUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatsUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'statName', protoName: 'statName')
    ..aD(2, _omitFieldNames ? '' : 'value')
    ..aOS(3, _omitFieldNames ? '' : 'unit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatsUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatsUpdate copyWith(void Function(StatsUpdate) updates) =>
      super.copyWith((message) => updates(message as StatsUpdate))
          as StatsUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatsUpdate create() => StatsUpdate._();
  @$core.override
  StatsUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StatsUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StatsUpdate>(create);
  static StatsUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get statName => $_getSZ(0);
  @$pb.TagNumber(1)
  set statName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStatName() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get unit => $_getSZ(2);
  @$pb.TagNumber(3)
  set unit($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnit() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnit() => $_clearField(3);
}

class EntityUpdate extends $pb.GeneratedMessage {
  factory EntityUpdate({
    $core.String? entityId,
    $core.String? entityType,
    $core.String? jsonData,
  }) {
    final result = create();
    if (entityId != null) result.entityId = entityId;
    if (entityType != null) result.entityType = entityType;
    if (jsonData != null) result.jsonData = jsonData;
    return result;
  }

  EntityUpdate._();

  factory EntityUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EntityUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EntityUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'entityId', protoName: 'entityId')
    ..aOS(2, _omitFieldNames ? '' : 'entityType', protoName: 'entityType')
    ..aOS(3, _omitFieldNames ? '' : 'jsonData', protoName: 'jsonData')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntityUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EntityUpdate copyWith(void Function(EntityUpdate) updates) =>
      super.copyWith((message) => updates(message as EntityUpdate))
          as EntityUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EntityUpdate create() => EntityUpdate._();
  @$core.override
  EntityUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EntityUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EntityUpdate>(create);
  static EntityUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entityId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get entityType => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEntityType() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get jsonData => $_getSZ(2);
  @$pb.TagNumber(3)
  set jsonData($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasJsonData() => $_has(2);
  @$pb.TagNumber(3)
  void clearJsonData() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');

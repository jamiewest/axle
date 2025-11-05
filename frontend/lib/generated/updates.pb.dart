//
//  Generated code. Do not modify.
//  source: updates.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'updates.pbenum.dart';

export 'updates.pbenum.dart';

/// Request to subscribe to data updates
class SubscribeRequest extends $pb.GeneratedMessage {
  factory SubscribeRequest({
    $core.String? dataType,
    $core.String? filter,
    $core.String? token,
  }) {
    final $result = create();
    if (dataType != null) {
      $result.dataType = dataType;
    }
    if (filter != null) {
      $result.filter = filter;
    }
    if (token != null) {
      $result.token = token;
    }
    return $result;
  }
  SubscribeRequest._() : super();
  factory SubscribeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'dataType')
    ..aOS(2, _omitFieldNames ? '' : 'filter')
    ..aOS(3, _omitFieldNames ? '' : 'token')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeRequest clone() => SubscribeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeRequest copyWith(void Function(SubscribeRequest) updates) => super.copyWith((message) => updates(message as SubscribeRequest)) as SubscribeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeRequest create() => SubscribeRequest._();
  SubscribeRequest createEmptyInstance() => create();
  static $pb.PbList<SubscribeRequest> createRepeated() => $pb.PbList<SubscribeRequest>();
  @$core.pragma('dart2js:noInline')
  static SubscribeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeRequest>(create);
  static SubscribeRequest? _defaultInstance;

  /// Type of data to subscribe to (e.g., "users", "orders", "stats")
  @$pb.TagNumber(1)
  $core.String get dataType => $_getSZ(0);
  @$pb.TagNumber(1)
  set dataType($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDataType() => $_has(0);
  @$pb.TagNumber(1)
  void clearDataType() => clearField(1);

  /// Optional filter criteria (JSON format)
  @$pb.TagNumber(2)
  $core.String get filter => $_getSZ(1);
  @$pb.TagNumber(2)
  set filter($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFilter() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilter() => clearField(2);

  /// Authentication token
  @$pb.TagNumber(3)
  $core.String get token => $_getSZ(2);
  @$pb.TagNumber(3)
  set token($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearToken() => clearField(3);
}

/// Request to unsubscribe from updates
class UnsubscribeRequest extends $pb.GeneratedMessage {
  factory UnsubscribeRequest({
    $core.String? subscriptionId,
  }) {
    final $result = create();
    if (subscriptionId != null) {
      $result.subscriptionId = subscriptionId;
    }
    return $result;
  }
  UnsubscribeRequest._() : super();
  factory UnsubscribeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnsubscribeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnsubscribeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'subscriptionId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnsubscribeRequest clone() => UnsubscribeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnsubscribeRequest copyWith(void Function(UnsubscribeRequest) updates) => super.copyWith((message) => updates(message as UnsubscribeRequest)) as UnsubscribeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnsubscribeRequest create() => UnsubscribeRequest._();
  UnsubscribeRequest createEmptyInstance() => create();
  static $pb.PbList<UnsubscribeRequest> createRepeated() => $pb.PbList<UnsubscribeRequest>();
  @$core.pragma('dart2js:noInline')
  static UnsubscribeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnsubscribeRequest>(create);
  static UnsubscribeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get subscriptionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set subscriptionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSubscriptionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSubscriptionId() => clearField(1);
}

/// Response for unsubscribe
class UnsubscribeResponse extends $pb.GeneratedMessage {
  factory UnsubscribeResponse({
    $core.bool? success,
    $core.String? message,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  UnsubscribeResponse._() : super();
  factory UnsubscribeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnsubscribeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnsubscribeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnsubscribeResponse clone() => UnsubscribeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnsubscribeResponse copyWith(void Function(UnsubscribeResponse) updates) => super.copyWith((message) => updates(message as UnsubscribeResponse)) as UnsubscribeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnsubscribeResponse create() => UnsubscribeResponse._();
  UnsubscribeResponse createEmptyInstance() => create();
  static $pb.PbList<UnsubscribeResponse> createRepeated() => $pb.PbList<UnsubscribeResponse>();
  @$core.pragma('dart2js:noInline')
  static UnsubscribeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnsubscribeResponse>(create);
  static UnsubscribeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

/// Update message sent to subscribers
class UpdateMessage extends $pb.GeneratedMessage {
  factory UpdateMessage({
    $core.String? updateId,
    $core.String? dataType,
    ChangeType? changeType,
    $core.String? data,
    $fixnum.Int64? timestamp,
    $core.Map<$core.String, $core.String>? metadata,
  }) {
    final $result = create();
    if (updateId != null) {
      $result.updateId = updateId;
    }
    if (dataType != null) {
      $result.dataType = dataType;
    }
    if (changeType != null) {
      $result.changeType = changeType;
    }
    if (data != null) {
      $result.data = data;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (metadata != null) {
      $result.metadata.addAll(metadata);
    }
    return $result;
  }
  UpdateMessage._() : super();
  factory UpdateMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'updateId')
    ..aOS(2, _omitFieldNames ? '' : 'dataType')
    ..e<ChangeType>(3, _omitFieldNames ? '' : 'changeType', $pb.PbFieldType.OE, defaultOrMaker: ChangeType.UNKNOWN, valueOf: ChangeType.valueOf, enumValues: ChangeType.values)
    ..aOS(4, _omitFieldNames ? '' : 'data')
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..m<$core.String, $core.String>(6, _omitFieldNames ? '' : 'metadata', entryClassName: 'UpdateMessage.MetadataEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('axle'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateMessage clone() => UpdateMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateMessage copyWith(void Function(UpdateMessage) updates) => super.copyWith((message) => updates(message as UpdateMessage)) as UpdateMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateMessage create() => UpdateMessage._();
  UpdateMessage createEmptyInstance() => create();
  static $pb.PbList<UpdateMessage> createRepeated() => $pb.PbList<UpdateMessage>();
  @$core.pragma('dart2js:noInline')
  static UpdateMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateMessage>(create);
  static UpdateMessage? _defaultInstance;

  /// Unique ID for this update
  @$pb.TagNumber(1)
  $core.String get updateId => $_getSZ(0);
  @$pb.TagNumber(1)
  set updateId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUpdateId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUpdateId() => clearField(1);

  /// Type of data being updated
  @$pb.TagNumber(2)
  $core.String get dataType => $_getSZ(1);
  @$pb.TagNumber(2)
  set dataType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDataType() => $_has(1);
  @$pb.TagNumber(2)
  void clearDataType() => clearField(2);

  /// Type of change (created, updated, deleted)
  @$pb.TagNumber(3)
  ChangeType get changeType => $_getN(2);
  @$pb.TagNumber(3)
  set changeType(ChangeType v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasChangeType() => $_has(2);
  @$pb.TagNumber(3)
  void clearChangeType() => clearField(3);

  /// The actual data (JSON format for flexibility)
  @$pb.TagNumber(4)
  $core.String get data => $_getSZ(3);
  @$pb.TagNumber(4)
  set data($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasData() => $_has(3);
  @$pb.TagNumber(4)
  void clearData() => clearField(4);

  /// Timestamp of the change
  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => clearField(5);

  /// Optional metadata
  @$pb.TagNumber(6)
  $core.Map<$core.String, $core.String> get metadata => $_getMap(5);
}

/// Predefined data types for common use cases
class UserCountUpdate extends $pb.GeneratedMessage {
  factory UserCountUpdate({
    $core.int? totalUsers,
    $core.int? activeUsers,
    $core.int? newUsersToday,
  }) {
    final $result = create();
    if (totalUsers != null) {
      $result.totalUsers = totalUsers;
    }
    if (activeUsers != null) {
      $result.activeUsers = activeUsers;
    }
    if (newUsersToday != null) {
      $result.newUsersToday = newUsersToday;
    }
    return $result;
  }
  UserCountUpdate._() : super();
  factory UserCountUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UserCountUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserCountUpdate', package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'totalUsers', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'activeUsers', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'newUsersToday', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UserCountUpdate clone() => UserCountUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UserCountUpdate copyWith(void Function(UserCountUpdate) updates) => super.copyWith((message) => updates(message as UserCountUpdate)) as UserCountUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserCountUpdate create() => UserCountUpdate._();
  UserCountUpdate createEmptyInstance() => create();
  static $pb.PbList<UserCountUpdate> createRepeated() => $pb.PbList<UserCountUpdate>();
  @$core.pragma('dart2js:noInline')
  static UserCountUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserCountUpdate>(create);
  static UserCountUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get totalUsers => $_getIZ(0);
  @$pb.TagNumber(1)
  set totalUsers($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTotalUsers() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalUsers() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get activeUsers => $_getIZ(1);
  @$pb.TagNumber(2)
  set activeUsers($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasActiveUsers() => $_has(1);
  @$pb.TagNumber(2)
  void clearActiveUsers() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get newUsersToday => $_getIZ(2);
  @$pb.TagNumber(3)
  set newUsersToday($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNewUsersToday() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewUsersToday() => clearField(3);
}

class StatsUpdate extends $pb.GeneratedMessage {
  factory StatsUpdate({
    $core.String? statName,
    $core.double? value,
    $core.String? unit,
  }) {
    final $result = create();
    if (statName != null) {
      $result.statName = statName;
    }
    if (value != null) {
      $result.value = value;
    }
    if (unit != null) {
      $result.unit = unit;
    }
    return $result;
  }
  StatsUpdate._() : super();
  factory StatsUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StatsUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StatsUpdate', package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'statName')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OD)
    ..aOS(3, _omitFieldNames ? '' : 'unit')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StatsUpdate clone() => StatsUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StatsUpdate copyWith(void Function(StatsUpdate) updates) => super.copyWith((message) => updates(message as StatsUpdate)) as StatsUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatsUpdate create() => StatsUpdate._();
  StatsUpdate createEmptyInstance() => create();
  static $pb.PbList<StatsUpdate> createRepeated() => $pb.PbList<StatsUpdate>();
  @$core.pragma('dart2js:noInline')
  static StatsUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StatsUpdate>(create);
  static StatsUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get statName => $_getSZ(0);
  @$pb.TagNumber(1)
  set statName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStatName() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatName() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get unit => $_getSZ(2);
  @$pb.TagNumber(3)
  set unit($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUnit() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnit() => clearField(3);
}

class EntityUpdate extends $pb.GeneratedMessage {
  factory EntityUpdate({
    $core.String? entityId,
    $core.String? entityType,
    $core.String? jsonData,
  }) {
    final $result = create();
    if (entityId != null) {
      $result.entityId = entityId;
    }
    if (entityType != null) {
      $result.entityType = entityType;
    }
    if (jsonData != null) {
      $result.jsonData = jsonData;
    }
    return $result;
  }
  EntityUpdate._() : super();
  factory EntityUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EntityUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EntityUpdate', package: const $pb.PackageName(_omitMessageNames ? '' : 'axle'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'entityId')
    ..aOS(2, _omitFieldNames ? '' : 'entityType')
    ..aOS(3, _omitFieldNames ? '' : 'jsonData')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EntityUpdate clone() => EntityUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EntityUpdate copyWith(void Function(EntityUpdate) updates) => super.copyWith((message) => updates(message as EntityUpdate)) as EntityUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EntityUpdate create() => EntityUpdate._();
  EntityUpdate createEmptyInstance() => create();
  static $pb.PbList<EntityUpdate> createRepeated() => $pb.PbList<EntityUpdate>();
  @$core.pragma('dart2js:noInline')
  static EntityUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EntityUpdate>(create);
  static EntityUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get entityId => $_getSZ(0);
  @$pb.TagNumber(1)
  set entityId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEntityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntityId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get entityType => $_getSZ(1);
  @$pb.TagNumber(2)
  set entityType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEntityType() => $_has(1);
  @$pb.TagNumber(2)
  void clearEntityType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get jsonData => $_getSZ(2);
  @$pb.TagNumber(3)
  set jsonData($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasJsonData() => $_has(2);
  @$pb.TagNumber(3)
  void clearJsonData() => clearField(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');

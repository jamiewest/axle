//
//  Generated code. Do not modify.
//  source: updates.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use changeTypeDescriptor instead')
const ChangeType$json = {
  '1': 'ChangeType',
  '2': [
    {'1': 'UNKNOWN', '2': 0},
    {'1': 'CREATED', '2': 1},
    {'1': 'UPDATED', '2': 2},
    {'1': 'DELETED', '2': 3},
    {'1': 'BATCH_UPDATE', '2': 4},
  ],
};

/// Descriptor for `ChangeType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List changeTypeDescriptor = $convert.base64Decode(
    'CgpDaGFuZ2VUeXBlEgsKB1VOS05PV04QABILCgdDUkVBVEVEEAESCwoHVVBEQVRFRBACEgsKB0'
    'RFTEVURUQQAxIQCgxCQVRDSF9VUERBVEUQBA==');

@$core.Deprecated('Use subscribeRequestDescriptor instead')
const SubscribeRequest$json = {
  '1': 'SubscribeRequest',
  '2': [
    {'1': 'dataType', '3': 1, '4': 1, '5': 9, '10': 'dataType'},
    {'1': 'filter', '3': 2, '4': 1, '5': 9, '10': 'filter'},
    {'1': 'token', '3': 3, '4': 1, '5': 9, '10': 'token'},
  ],
};

/// Descriptor for `SubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List subscribeRequestDescriptor = $convert.base64Decode(
    'ChBTdWJzY3JpYmVSZXF1ZXN0EhoKCGRhdGFUeXBlGAEgASgJUghkYXRhVHlwZRIWCgZmaWx0ZX'
    'IYAiABKAlSBmZpbHRlchIUCgV0b2tlbhgDIAEoCVIFdG9rZW4=');

@$core.Deprecated('Use unsubscribeRequestDescriptor instead')
const UnsubscribeRequest$json = {
  '1': 'UnsubscribeRequest',
  '2': [
    {'1': 'subscriptionId', '3': 1, '4': 1, '5': 9, '10': 'subscriptionId'},
  ],
};

/// Descriptor for `UnsubscribeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unsubscribeRequestDescriptor = $convert.base64Decode(
    'ChJVbnN1YnNjcmliZVJlcXVlc3QSJgoOc3Vic2NyaXB0aW9uSWQYASABKAlSDnN1YnNjcmlwdG'
    'lvbklk');

@$core.Deprecated('Use unsubscribeResponseDescriptor instead')
const UnsubscribeResponse$json = {
  '1': 'UnsubscribeResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `UnsubscribeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unsubscribeResponseDescriptor = $convert.base64Decode(
    'ChNVbnN1YnNjcmliZVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbWVzc2'
    'FnZRgCIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use updateMessageDescriptor instead')
const UpdateMessage$json = {
  '1': 'UpdateMessage',
  '2': [
    {'1': 'updateId', '3': 1, '4': 1, '5': 9, '10': 'updateId'},
    {'1': 'dataType', '3': 2, '4': 1, '5': 9, '10': 'dataType'},
    {'1': 'changeType', '3': 3, '4': 1, '5': 14, '6': '.axle.ChangeType', '10': 'changeType'},
    {'1': 'data', '3': 4, '4': 1, '5': 9, '10': 'data'},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'metadata', '3': 6, '4': 3, '5': 11, '6': '.axle.UpdateMessage.MetadataEntry', '10': 'metadata'},
  ],
  '3': [UpdateMessage_MetadataEntry$json],
};

@$core.Deprecated('Use updateMessageDescriptor instead')
const UpdateMessage_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `UpdateMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateMessageDescriptor = $convert.base64Decode(
    'Cg1VcGRhdGVNZXNzYWdlEhoKCHVwZGF0ZUlkGAEgASgJUgh1cGRhdGVJZBIaCghkYXRhVHlwZR'
    'gCIAEoCVIIZGF0YVR5cGUSMAoKY2hhbmdlVHlwZRgDIAEoDjIQLmF4bGUuQ2hhbmdlVHlwZVIK'
    'Y2hhbmdlVHlwZRISCgRkYXRhGAQgASgJUgRkYXRhEhwKCXRpbWVzdGFtcBgFIAEoA1IJdGltZX'
    'N0YW1wEj0KCG1ldGFkYXRhGAYgAygLMiEuYXhsZS5VcGRhdGVNZXNzYWdlLk1ldGFkYXRhRW50'
    'cnlSCG1ldGFkYXRhGjsKDU1ldGFkYXRhRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdW'
    'UYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use userCountUpdateDescriptor instead')
const UserCountUpdate$json = {
  '1': 'UserCountUpdate',
  '2': [
    {'1': 'totalUsers', '3': 1, '4': 1, '5': 5, '10': 'totalUsers'},
    {'1': 'activeUsers', '3': 2, '4': 1, '5': 5, '10': 'activeUsers'},
    {'1': 'newUsersToday', '3': 3, '4': 1, '5': 5, '10': 'newUsersToday'},
  ],
};

/// Descriptor for `UserCountUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userCountUpdateDescriptor = $convert.base64Decode(
    'Cg9Vc2VyQ291bnRVcGRhdGUSHgoKdG90YWxVc2VycxgBIAEoBVIKdG90YWxVc2VycxIgCgthY3'
    'RpdmVVc2VycxgCIAEoBVILYWN0aXZlVXNlcnMSJAoNbmV3VXNlcnNUb2RheRgDIAEoBVINbmV3'
    'VXNlcnNUb2RheQ==');

@$core.Deprecated('Use statsUpdateDescriptor instead')
const StatsUpdate$json = {
  '1': 'StatsUpdate',
  '2': [
    {'1': 'statName', '3': 1, '4': 1, '5': 9, '10': 'statName'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
    {'1': 'unit', '3': 3, '4': 1, '5': 9, '10': 'unit'},
  ],
};

/// Descriptor for `StatsUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statsUpdateDescriptor = $convert.base64Decode(
    'CgtTdGF0c1VwZGF0ZRIaCghzdGF0TmFtZRgBIAEoCVIIc3RhdE5hbWUSFAoFdmFsdWUYAiABKA'
    'FSBXZhbHVlEhIKBHVuaXQYAyABKAlSBHVuaXQ=');

@$core.Deprecated('Use entityUpdateDescriptor instead')
const EntityUpdate$json = {
  '1': 'EntityUpdate',
  '2': [
    {'1': 'entityId', '3': 1, '4': 1, '5': 9, '10': 'entityId'},
    {'1': 'entityType', '3': 2, '4': 1, '5': 9, '10': 'entityType'},
    {'1': 'jsonData', '3': 3, '4': 1, '5': 9, '10': 'jsonData'},
  ],
};

/// Descriptor for `EntityUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List entityUpdateDescriptor = $convert.base64Decode(
    'CgxFbnRpdHlVcGRhdGUSGgoIZW50aXR5SWQYASABKAlSCGVudGl0eUlkEh4KCmVudGl0eVR5cG'
    'UYAiABKAlSCmVudGl0eVR5cGUSGgoIanNvbkRhdGEYAyABKAlSCGpzb25EYXRh');


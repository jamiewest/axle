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

import 'package:protobuf/protobuf.dart' as $pb;

/// Types of changes
class ChangeType extends $pb.ProtobufEnum {
  static const ChangeType UNKNOWN = ChangeType._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const ChangeType CREATED = ChangeType._(1, _omitEnumNames ? '' : 'CREATED');
  static const ChangeType UPDATED = ChangeType._(2, _omitEnumNames ? '' : 'UPDATED');
  static const ChangeType DELETED = ChangeType._(3, _omitEnumNames ? '' : 'DELETED');
  static const ChangeType BATCH_UPDATE = ChangeType._(4, _omitEnumNames ? '' : 'BATCH_UPDATE');

  static const $core.List<ChangeType> values = <ChangeType> [
    UNKNOWN,
    CREATED,
    UPDATED,
    DELETED,
    BATCH_UPDATE,
  ];

  static final $core.Map<$core.int, ChangeType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ChangeType? valueOf($core.int value) => _byValue[value];

  const ChangeType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');

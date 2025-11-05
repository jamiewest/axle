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

import 'package:protobuf/protobuf.dart' as $pb;

/// Types of changes
class ChangeType extends $pb.ProtobufEnum {
  static const ChangeType UNKNOWN =
      ChangeType._(0, _omitEnumNames ? '' : 'UNKNOWN');
  static const ChangeType CREATED =
      ChangeType._(1, _omitEnumNames ? '' : 'CREATED');
  static const ChangeType UPDATED =
      ChangeType._(2, _omitEnumNames ? '' : 'UPDATED');
  static const ChangeType DELETED =
      ChangeType._(3, _omitEnumNames ? '' : 'DELETED');
  static const ChangeType BATCH_UPDATE =
      ChangeType._(4, _omitEnumNames ? '' : 'BATCH_UPDATE');

  static const $core.List<ChangeType> values = <ChangeType>[
    UNKNOWN,
    CREATED,
    UPDATED,
    DELETED,
    BATCH_UPDATE,
  ];

  static final $core.List<ChangeType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static ChangeType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ChangeType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');

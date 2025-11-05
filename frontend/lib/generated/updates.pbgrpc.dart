// This is a generated file - do not edit.
//
// Generated from updates.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'updates.pb.dart' as $0;

export 'updates.pb.dart';

/// Service for real-time data updates
@$pb.GrpcServiceName('axle.UpdateStream')
class UpdateStreamClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  UpdateStreamClient(super.channel, {super.options, super.interceptors});

  /// Subscribe to specific data stream updates
  $grpc.ResponseStream<$0.UpdateMessage> subscribe(
    $0.SubscribeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$subscribe, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Unsubscribe from a data stream
  $grpc.ResponseFuture<$0.UnsubscribeResponse> unsubscribe(
    $0.UnsubscribeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unsubscribe, request, options: options);
  }

  // method descriptors

  static final _$subscribe =
      $grpc.ClientMethod<$0.SubscribeRequest, $0.UpdateMessage>(
          '/axle.UpdateStream/Subscribe',
          ($0.SubscribeRequest value) => value.writeToBuffer(),
          $0.UpdateMessage.fromBuffer);
  static final _$unsubscribe =
      $grpc.ClientMethod<$0.UnsubscribeRequest, $0.UnsubscribeResponse>(
          '/axle.UpdateStream/Unsubscribe',
          ($0.UnsubscribeRequest value) => value.writeToBuffer(),
          $0.UnsubscribeResponse.fromBuffer);
}

@$pb.GrpcServiceName('axle.UpdateStream')
abstract class UpdateStreamServiceBase extends $grpc.Service {
  $core.String get $name => 'axle.UpdateStream';

  UpdateStreamServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SubscribeRequest, $0.UpdateMessage>(
        'Subscribe',
        subscribe_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.SubscribeRequest.fromBuffer(value),
        ($0.UpdateMessage value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.UnsubscribeRequest, $0.UnsubscribeResponse>(
            'Unsubscribe',
            unsubscribe_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.UnsubscribeRequest.fromBuffer(value),
            ($0.UnsubscribeResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.UpdateMessage> subscribe_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SubscribeRequest> $request) async* {
    yield* subscribe($call, await $request);
  }

  $async.Stream<$0.UpdateMessage> subscribe(
      $grpc.ServiceCall call, $0.SubscribeRequest request);

  $async.Future<$0.UnsubscribeResponse> unsubscribe_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UnsubscribeRequest> $request) async {
    return unsubscribe($call, await $request);
  }

  $async.Future<$0.UnsubscribeResponse> unsubscribe(
      $grpc.ServiceCall call, $0.UnsubscribeRequest request);
}

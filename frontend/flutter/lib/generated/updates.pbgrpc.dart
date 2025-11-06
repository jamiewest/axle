//
//  Generated code. Do not modify.
//  source: updates.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'updates.pb.dart' as $0;

export 'updates.pb.dart';

@$pb.GrpcServiceName('axle.UpdateStream')
class UpdateStreamClient extends $grpc.Client {
  static final _$subscribe = $grpc.ClientMethod<$0.SubscribeRequest, $0.UpdateMessage>(
      '/axle.UpdateStream/Subscribe',
      ($0.SubscribeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.UpdateMessage.fromBuffer(value));
  static final _$unsubscribe = $grpc.ClientMethod<$0.UnsubscribeRequest, $0.UnsubscribeResponse>(
      '/axle.UpdateStream/Unsubscribe',
      ($0.UnsubscribeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.UnsubscribeResponse.fromBuffer(value));

  UpdateStreamClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseStream<$0.UpdateMessage> subscribe($0.SubscribeRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$subscribe, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseFuture<$0.UnsubscribeResponse> unsubscribe($0.UnsubscribeRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$unsubscribe, request, options: options);
  }
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
    $addMethod($grpc.ServiceMethod<$0.UnsubscribeRequest, $0.UnsubscribeResponse>(
        'Unsubscribe',
        unsubscribe_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UnsubscribeRequest.fromBuffer(value),
        ($0.UnsubscribeResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.UpdateMessage> subscribe_Pre($grpc.ServiceCall call, $async.Future<$0.SubscribeRequest> request) async* {
    yield* subscribe(call, await request);
  }

  $async.Future<$0.UnsubscribeResponse> unsubscribe_Pre($grpc.ServiceCall call, $async.Future<$0.UnsubscribeRequest> request) async {
    return unsubscribe(call, await request);
  }

  $async.Stream<$0.UpdateMessage> subscribe($grpc.ServiceCall call, $0.SubscribeRequest request);
  $async.Future<$0.UnsubscribeResponse> unsubscribe($grpc.ServiceCall call, $0.UnsubscribeRequest request);
}

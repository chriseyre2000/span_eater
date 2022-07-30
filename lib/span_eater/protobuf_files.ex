defmodule ProtobufFiles do
  use Protox, schema: """
  syntax = "proto3";

  // AnyValue is used to represent any type of attribute value. AnyValue may contain a
  // primitive value such as a string or integer or it may contain an arbitrary nested
  // object containing arrays, key-value lists and primitives.
  message AnyValue {
    // The value is one of the listed fields. It is valid for all values to be unspecified
    // in which case this AnyValue is considered to be "empty".
    oneof value {
      string string_value = 1;
      bool bool_value = 2;
      int64 int_value = 3;
      double double_value = 4;
      ArrayValue array_value = 5;
      KeyValueList kvlist_value = 6;
      bytes bytes_value = 7;
    }
  }

  // ArrayValue is a list of AnyValue messages. We need ArrayValue as a message
  // since oneof in AnyValue does not allow repeated fields.
  message ArrayValue {
    // Array of values. The array may be empty (contain 0 elements).
    repeated AnyValue values = 1;
  }

  // KeyValueList is a list of KeyValue messages. We need KeyValueList as a message
  // since `oneof` in AnyValue does not allow repeated fields. Everywhere else where we need
  // a list of KeyValue messages (e.g. in Span) we use `repeated KeyValue` directly to
  // avoid unnecessary extra wrapping (which slows down the protocol). The 2 approaches
  // are semantically equivalent.
  message KeyValueList {
    // A collection of key/value pairs of key-value pairs. The list may be empty (may
    // contain 0 elements).
    // The keys MUST be unique (it is not allowed to have more than one
    // value with the same key).
    repeated KeyValue values = 1;
  }

  // KeyValue is a key-value pair that is used to store Span attributes, Link
  // attributes, etc.
  message KeyValue {
    string key = 1;
    AnyValue value = 2;
  }

  // InstrumentationScope is a message representing the instrumentation scope information
  // such as the fully qualified name and version.
  message InstrumentationScope {
    // An empty instrumentation scope name means the name is unknown.
    string name = 1;
    string version = 2;
    repeated KeyValue attributes = 3;
    uint32 dropped_attributes_count = 4;
  }

  message Resource {
    // Set of attributes that describe the resource.
    // Attribute keys MUST be unique (it is not allowed to have more than one
    // attribute with the same key).
    repeated KeyValue attributes = 1;

    // dropped_attributes_count is the number of dropped attributes. If the value is 0, then
    // no attributes were dropped.
    uint32 dropped_attributes_count = 2;
  }

  // TracesData represents the traces data that can be stored in a persistent storage,
  // OR can be embedded by other protocols that transfer OTLP traces data but do
  // not implement the OTLP protocol.
  //
  // The main difference between this message and collector protocol is that
  // in this message there will not be any "control" or "metadata" specific to
  // OTLP protocol.
  //
  // When new fields are added into this message, the OTLP request MUST be updated
  // as well.
  message TracesData {
    // An array of ResourceSpans.
    // For data coming from a single resource this array will typically contain
    // one element. Intermediary nodes that receive data from multiple origins
    // typically batch the data before forwarding further and in that case this
    // array will contain multiple elements.
    repeated ResourceSpans resource_spans = 1;
  }

  // A collection of ScopeSpans from a Resource.
  message ResourceSpans {
    reserved 1000;

    // The resource for the spans in this message.
    // If this field is not set then no resource info is known.
    Resource resource = 1;

    // A list of ScopeSpans that originate from a resource.
    repeated ScopeSpans scope_spans = 2;

    // This schema_url applies to the data in the "resource" field. It does not apply
    // to the data in the "scope_spans" field which have their own schema_url field.
    string schema_url = 3;
  }

  // A collection of Spans produced by an InstrumentationScope.
  message ScopeSpans {
    // The instrumentation scope information for the spans in this message.
    // Semantically when InstrumentationScope isn't set, it is equivalent with
    // an empty instrumentation scope name (unknown).
    InstrumentationScope scope = 1;

    // A list of Spans that originate from an instrumentation scope.
    repeated Span spans = 2;

    // This schema_url applies to all spans and span events in the "spans" field.
    string schema_url = 3;
  }

  // A Span represents a single operation performed by a single component of the system.
  //
  // The next available field id is 17.
  message Span {
    // A unique identifier for a trace. All spans from the same trace share
    // the same `trace_id`. The ID is a 16-byte array. An ID with all zeroes
    // is considered invalid.
    //
    // This field is semantically required. Receiver should generate new
    // random trace_id if empty or invalid trace_id was received.
    //
    // This field is required.
    bytes trace_id = 1;

    // A unique identifier for a span within a trace, assigned when the span
    // is created. The ID is an 8-byte array. An ID with all zeroes is considered
    // invalid.
    //
    // This field is semantically required. Receiver should generate new
    // random span_id if empty or invalid span_id was received.
    //
    // This field is required.
    bytes span_id = 2;

    // trace_state conveys information about request position in multiple distributed tracing graphs.
    // It is a trace_state in w3c-trace-context format: https://www.w3.org/TR/trace-context/#tracestate-header
    // See also https://github.com/w3c/distributed-tracing for more details about this field.
    string trace_state = 3;

    // The `span_id` of this span's parent span. If this is a root span, then this
    // field must be empty. The ID is an 8-byte array.
    bytes parent_span_id = 4;

    // A description of the span's operation.
    //
    // For example, the name can be a qualified method name or a file name
    // and a line number where the operation is called. A best practice is to use
    // the same display name at the same call point in an application.
    // This makes it easier to correlate spans in different traces.
    //
    // This field is semantically required to be set to non-empty string.
    // Empty value is equivalent to an unknown span name.
    //
    // This field is required.
    string name = 5;

    // SpanKind is the type of span. Can be used to specify additional relationships between spans
    // in addition to a parent/child relationship.
    enum SpanKind {
      // Unspecified. Do NOT use as default.
      // Implementations MAY assume SpanKind to be INTERNAL when receiving UNSPECIFIED.
      SPAN_KIND_UNSPECIFIED = 0;

      // Indicates that the span represents an internal operation within an application,
      // as opposed to an operation happening at the boundaries. Default value.
      SPAN_KIND_INTERNAL = 1;

      // Indicates that the span covers server-side handling of an RPC or other
      // remote network request.
      SPAN_KIND_SERVER = 2;

      // Indicates that the span describes a request to some remote service.
      SPAN_KIND_CLIENT = 3;

      // Indicates that the span describes a producer sending a message to a broker.
      // Unlike CLIENT and SERVER, there is often no direct critical path latency relationship
      // between producer and consumer spans. A PRODUCER span ends when the message was accepted
      // by the broker while the logical processing of the message might span a much longer time.
      SPAN_KIND_PRODUCER = 4;

      // Indicates that the span describes consumer receiving a message from a broker.
      // Like the PRODUCER kind, there is often no direct critical path latency relationship
      // between producer and consumer spans.
      SPAN_KIND_CONSUMER = 5;
    }

    // Distinguishes between spans generated in a particular context. For example,
    // two spans with the same name may be distinguished using `CLIENT` (caller)
    // and `SERVER` (callee) to identify queueing latency associated with the span.
    SpanKind kind = 6;

    // start_time_unix_nano is the start time of the span. On the client side, this is the time
    // kept by the local machine where the span execution starts. On the server side, this
    // is the time when the server's application handler starts running.
    // Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January 1970.
    //
    // This field is semantically required and it is expected that end_time >= start_time.
    fixed64 start_time_unix_nano = 7;

    // end_time_unix_nano is the end time of the span. On the client side, this is the time
    // kept by the local machine where the span execution ends. On the server side, this
    // is the time when the server application handler stops running.
    // Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January 1970.
    //
    // This field is semantically required and it is expected that end_time >= start_time.
    fixed64 end_time_unix_nano = 8;

    // attributes is a collection of key/value pairs. Note, global attributes
    // like server name can be set using the resource API. Examples of attributes:
    //
    //     "/http/user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36"
    //     "/http/server_latency": 300
    //     "abc.com/myattribute": true
    //     "abc.com/score": 10.239
    //
    // The OpenTelemetry API specification further restricts the allowed value types:
    // https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/common/README.md#attribute
    // Attribute keys MUST be unique (it is not allowed to have more than one
    // attribute with the same key).
    repeated KeyValue attributes = 9;

    // dropped_attributes_count is the number of attributes that were discarded. Attributes
    // can be discarded because their keys are too long or because there are too many
    // attributes. If this value is 0, then no attributes were dropped.
    uint32 dropped_attributes_count = 10;

    // Event is a time-stamped annotation of the span, consisting of user-supplied
    // text description and key-value pairs.
    message Event {
      // time_unix_nano is the time the event occurred.
      fixed64 time_unix_nano = 1;

      // name of the event.
      // This field is semantically required to be set to non-empty string.
      string name = 2;

      // attributes is a collection of attribute key/value pairs on the event.
      // Attribute keys MUST be unique (it is not allowed to have more than one
      // attribute with the same key).
      repeated KeyValue attributes = 3;

      // dropped_attributes_count is the number of dropped attributes. If the value is 0,
      // then no attributes were dropped.
      uint32 dropped_attributes_count = 4;
    }

    // events is a collection of Event items.
    repeated Event events = 11;

    // dropped_events_count is the number of dropped events. If the value is 0, then no
    // events were dropped.
    uint32 dropped_events_count = 12;

    // A pointer from the current span to another span in the same trace or in a
    // different trace. For example, this can be used in batching operations,
    // where a single batch handler processes multiple requests from different
    // traces or when the handler receives a request from a different project.
    message Link {
      // A unique identifier of a trace that this linked span is part of. The ID is a
      // 16-byte array.
      bytes trace_id = 1;

      // A unique identifier for the linked span. The ID is an 8-byte array.
      bytes span_id = 2;

      // The trace_state associated with the link.
      string trace_state = 3;

      // attributes is a collection of attribute key/value pairs on the link.
      // Attribute keys MUST be unique (it is not allowed to have more than one
      // attribute with the same key).
      repeated KeyValue attributes = 4;

      // dropped_attributes_count is the number of dropped attributes. If the value is 0,
      // then no attributes were dropped.
      uint32 dropped_attributes_count = 5;
    }

    // links is a collection of Links, which are references from this span to a span
    // in the same or different trace.
    repeated Link links = 13;

    // dropped_links_count is the number of dropped links after the maximum size was
    // enforced. If this value is 0, then no links were dropped.
    uint32 dropped_links_count = 14;

    // An optional final status for this span. Semantically when Status isn't set, it means
    // span's status code is unset, i.e. assume STATUS_CODE_UNSET (code = 0).
    Status status = 15;
  }

  // The Status type defines a logical error model that is suitable for different
  // programming environments, including REST APIs and RPC APIs.
  message Status {
    reserved 1;

    // A developer-facing human readable error message.
    string message = 2;

    // For the semantics of status codes see
    // https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md#set-status
    enum StatusCode {
      // The default status.
      STATUS_CODE_UNSET               = 0;
      // The Span has been validated by an Application developers or Operator to have
      // completed successfully.
      STATUS_CODE_OK                  = 1;
      // The Span contains an error.
      STATUS_CODE_ERROR               = 2;
    };

    // The status code.
    StatusCode code = 3;
  }

  // Service that can be used to push spans between one Application instrumented with
  // OpenTelemetry and a collector, or between a collector and a central collector (in this
  // case spans are sent/received to/from multiple Applications).
  service TraceService {
    // For performance reasons, it is recommended to keep this RPC
    // alive for the entire life of the application.
    rpc Export(ExportTraceServiceRequest) returns (ExportTraceServiceResponse) {}
  }

  message ExportTraceServiceRequest {
    // An array of ResourceSpans.
    // For data coming from a single resource this array will typically contain one
    // element. Intermediary nodes (such as OpenTelemetry Collector) that receive
    // data from multiple origins typically batch the data before forwarding further and
    // in that case this array will contain multiple elements.
    repeated ResourceSpans resource_spans = 1;
  }

  message ExportTraceServiceResponse {
  }

  """
end

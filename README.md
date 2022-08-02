# SpanEater

This is an app that consumes spans sent by OpenTelemetry.

I have used the protobuf definitions from: https://github.com/open-telemetry/opentelemetry-proto

It can currently decode the protobuf messages sent via open telemetry.

Currently it just dumps the raw message.

This allows you to watch the OpenTelemetry spans that are generated on your local machine.

This could be useful as an aid to debugging or understanding an instumented codebase.

This is the output from my something_to_measure repo:

```
 %TracesData{
  __uf__: [],
  resource_spans: [
    %ResourceSpans{
      __uf__: [],
      resource: %Resource{
        __uf__: [],
        attributes: [
          %KeyValue{
            __uf__: [],
            key: "service.name",
            value: %AnyValue{
              __uf__: [],
              value: {:string_value, "SOMETHING_TO_MEASURE"}
            }
          },
          %KeyValue{
            __uf__: [],
            key: "process.runtime.version",
            value: %AnyValue{__uf__: [], value: {:string_value, "13.0.2"}}
          },
          %KeyValue{
            __uf__: [],
            key: "process.runtime.name",
            value: %AnyValue{__uf__: [], value: {:string_value, "BEAM"}}
          },
          %KeyValue{
            __uf__: [],
            key: "process.runtime.description",
            value: %AnyValue{
              __uf__: [],
              value: {:string_value, "Erlang/OTP 25 erts-13.0.2"}
            }
          },
          %KeyValue{
            __uf__: [],
            key: "process.executable.name",
            value: %AnyValue{__uf__: [], value: {:string_value, "erl"}}
          }
        ],
        dropped_attributes_count: 0
      },
      schema_url: "",
      scope_spans: [
        %ScopeSpans{
          __uf__: [],
          schema_url: "",
          scope: %InstrumentationScope{
            __uf__: [],
            attributes: [],
            dropped_attributes_count: 0,
            name: "something_to_measure",
            version: "0.1.0"
          },
          spans: [
            %Span{
              __uf__: [],
              attributes: [
                %KeyValue{
                  __uf__: [],
                  key: "my-key-1",
                  value: %AnyValue{
                    __uf__: [],
                    value: {:string_value, "my-value-1"}
                  }
                },
                %KeyValue{
                  __uf__: [],
                  key: "another-key-1",
                  value: %AnyValue{
                    __uf__: [],
                    value: {:string_value, "another-value-1"}
                  }
                }
              ],
              dropped_attributes_count: 0,
              dropped_events_count: 0,
              dropped_links_count: 0,
              end_time_unix_nano: 1659271051344663768,
              events: [],
              kind: :SPAN_KIND_INTERNAL,
              links: [],
              name: "my-span",
              parent_span_id: "",
              span_id: <<209, 121, 141, 128, 225, 60, 226, 197>>,
              start_time_unix_nano: 1659271051334480120,
              status: %Status{__uf__: [], code: :STATUS_CODE_UNSET, message: ""},
              trace_id: <<21, 205, 72, 95, 95, 94, 128, 31, 31, 214, 69, 200,
                117, 163, 42, 128>>,
              trace_state: ""
            }
          ]
        }
      ]
    }
  ]
}

```

Note that the span_id and trace_id are binary values, and have not been failed to translate as it appears. 

If you are an asdf user you need to install protoc first: 

```
asdf plugin-add protoc https://github.com/paxosglobal/asdf-protoc.git
asdf global protoc 3.20.0
asdf install protoc 3.20.0
```


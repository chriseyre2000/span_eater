# SpanEater

This is an app that consumes spans sent by OpenTelemetry.

I have used the protobuf definitions from: https://github.com/open-telemetry/opentelemetry-proto

It can currently decode the protobuf messages sent via open telemetry.

Currently it just dumps the raw message.

This allows you to watch the OpenTelemetry spans that are generated on your local machine.

This could be useful as an aid to debugging or understanding an instumented codebase.

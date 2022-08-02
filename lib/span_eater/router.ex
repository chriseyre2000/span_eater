defmodule SpanEater.Router do
  use Plug.Router
  require Logger

  def child_spec do
    {
      Plug.Cowboy,
      scheme: :http,
      plug: SpanEater.Router,
      options: [port: (System.get_env("PORT") || "4318") |> String.to_integer()]
    }
  end

  plug(:match)
  plug(:dispatch)

  post "/v1/traces"  do
    Logger.info("Span recieved")
    for x <- conn.req_headers, do: IO.inspect(x)
    {:ok, data, conn} = read_body(conn)
    msg = Protox.decode!(data, OpenTelemetryProtobuf.TracesData)
    IO.inspect(msg, label: "Decoded trace")
    send_resp(conn, 200, "OK")
  end

  match _ do
    IO.puts("span")
    send_resp(conn, 200, "OK?")
  end
end

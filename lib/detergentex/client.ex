# https://github.com/danxexe/detergentex/commit/d83c6d09f3161f9ae4f873230596e28a4d0d28ed
defmodule Detergentex.Client do
  use GenServer

  require Record
  import Record, only: [defrecord: 2, extract: 2]

  # https://hexdocs.pm/elixir/Record.html#defrecord/3-defining-extracted-records-with-anonymous-functions-in-the-values
  defrecord :call_opts,
    extract(:call_opts, from_lib: "detergent/include/detergent.hrl")
    |> Keyword.merge(
      request_logger: &__MODULE__.default_logger/1,
      response_logger: &__MODULE__.default_logger/1
    )

  def default_logger(_), do: :ok

  def start_link do
    :ssl.start()
    :inets.start()
    GenServer.start_link(__MODULE__, {}, [name: :detergent_client])
  end

  def call_service(wsdl, method, params, call_options) do
    wsdl = if not is_wsdl(wsdl), do: to_charlist(wsdl)

    method_to_call = to_charlist(method)
    params = convert_to_detergent_params(params)

    call_options =
      call_options
      |> convert_to_detergent_params
      |> call_opts_from_klist

    :detergent.call(wsdl, method_to_call, params, call_options)
  end

  def init_model(wsdl_url, prefix, http_client_options) do
    wsdl_url = to_charlist(wsdl_url)
    prefix = to_charlist(prefix)

    http_client_options = convert_to_detergent_params(http_client_options)
    :detergent.initModel(wsdl_url, prefix, http_client_options)
  end

  def is_wsdl(wsdl), do: :detergent.is_wsdl(wsdl)

  def wsdl_operations(wsdl), do: :detergent.wsdl_operations(wsdl)

  def convert_to_detergent_params(params) do
    Enum.map(params, fn(elem) ->
        case elem do
          elem when is_list(elem) ->
            convert_to_detergent_params(elem)
          elem when is_tuple(elem) ->
            elem
              |> Tuple.to_list
              |> convert_to_detergent_params
              |> List.to_tuple
          elem when is_binary(elem) ->
            to_charlist(elem)
          _ ->
            elem
        end
    end)
  end

  defp call_opts_from_klist(klist) do
    Enum.reduce(klist, call_opts(), fn({k, v}, acc) ->
      case k do
        :url -> call_opts(acc, url: v)
        :prefix -> call_opts(acc, prefix: v)
        :http_headers -> call_opts(acc, http_headers: v)
        :http_client_options -> call_opts(acc, http_client_options: v)
        :request_logger -> call_opts(acc, request_logger: v)
        :response_logger -> call_opts(acc, response_logger: v)
      end
    end)
  end
end

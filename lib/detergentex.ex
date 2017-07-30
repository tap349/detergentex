defmodule Detergentex do
  use Application

  def start(_type, _args) do
      import Supervisor.Spec, warn: false
      children = [
        worker(Detergentex.Client, []),
      ]
      opts = [strategy: :one_for_one, name: Detergentex.Supervisor]
      Supervisor.start_link(children, opts)
  end

  def call(wsdl, method, params, call_options \\ []) do
    Detergentex.Client.call_service(wsdl, method, params, call_options)
  end

  def init_model(wsdl_url) do
    init_model(wsdl_url, 'p', [])
  end
  def init_model(wsdl_url, http_client_options) when is_list(http_client_options) do
    init_model(wsdl_url, 'p', http_client_options)
  end
  def init_model(wsdl_url, prefix) do
    init_model(wsdl_url, prefix, [])
  end
  def init_model(wsdl_url, prefix, http_client_options) do
    Detergentex.Client.init_model(wsdl_url, prefix, http_client_options)
  end

  def is_wsdl(wsdl) do
    Detergentex.Client.is_wsdl(wsdl)
  end

  def wsdl_operations(wsdl) do
    Detergentex.Client.wsdl_operations(wsdl)
  end
end

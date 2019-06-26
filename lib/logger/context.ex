defmodule EctoJobScheduler.Logger.Context do
  @moduledoc """
  Module responsible to get and set the request context from Logger metadata.
  """

  require Logger

  @type context :: keyword
  @type key :: atom

  @spec get() :: context
  def get, do: Logger.metadata()

  @spec get(key) :: any()
  def get(key), do: Keyword.get(get(), key)

  @spec put(context | map) :: :ok
  def put(context)

  def put(%{} = context) do
    context
    |> to_keyword_list()
    |> put()
  end

  def put(nil), do: :ok

  def put(context) do
    get()
    |> Keyword.merge(context)
    |> Logger.metadata()
  end

  defp to_keyword_list(%{} = map) do
    Enum.map(map, fn
      {key, value} when is_atom(key) -> {key, value}
      {key, value} -> {String.to_atom(key), value}
    end)
  end
end

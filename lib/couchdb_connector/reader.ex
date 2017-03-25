defmodule Couchdb.Connector.Reader do
  @moduledoc """
  The Reader module provides functions to retrieve documents or uuids from
  CouchDB.

  ## Examples

      db_props = %{protocol: "http", hostname: "localhost",database: "couchdb_connector_test", port: 5984}
      %{database: "couchdb_connector_test", hostname: "localhost", port: 5984, protocol: "http"}

      Couchdb.Connector.Reader.get(db_props, "_not_there_")
      {:error, "{\\"error\\":\\"not_found\\",\\"reason\\":\\"missing\\"}\\n"}

      Couchdb.Connector.Reader.get(db_props, "ca922a07263524e2feb5fe398303ecf8")
      {:ok,
        "{\\"_id\\":\\"ca922a07263524e2feb5fe398303ecf8\\",\\"_rev\\":\\"1-59414...\\",\\"key\\":\\"value\\"}\\n"}

      Couchdb.Connector.Reader.fetch_uuid(db_props)
      {:ok, "{\\"uuids\\":[\\"1a013a4ce3...\\"]}\\n"}

  """

  alias Couchdb.Connector.Types
  alias Couchdb.Connector.UrlHelper
  alias Couchdb.Connector.ResponseHandler, as: Handler
  alias Couchdb.Connector.Headers
  
  @doc """
  Retrieve the document given by database properties and id.
  """
  @spec get(Types.db_properties, String.t) :: {:ok, String.t} | {:error, String.t}
  def get(db_props, id) do
    db_props
    |> UrlHelper.document_url(id)
    |> do_get
  end

  @doc """
  Fetch a single uuid from CouchDB for use in a a subsequent create operation.
  This operation requires no authentication.
  """
  @spec fetch_uuid(Types.db_properties) :: {:ok, String.t} | {:error, String.t}
  def fetch_uuid(db_props) do
    db_props
    |> UrlHelper.fetch_uuid_url
    |> do_get
  end

  defp do_get(url) do
    url
    |> HTTPoison.get!
    |> Handler.handle_get
  end

  @spec db_query(Types.db_properties, atom, map) :: {:ok, map} | {:error, map}
  def db_query(db_props, db_query_command, db_query_params) do
    case db_query_command do
      :find ->
        db_props
        |> UrlHelper.db_query_url(db_query_command, db_query_params)
        |> do_db_query(:post, db_query_params)
        _ -> {:error, %{}}
    end
  end

  def do_db_query(url, :post, db_query_params) do
    IO.puts(db_query_params)
    url
    |> HTTPoison.post!(db_query_params, [Headers.json_header])
    |> Handler.handle_post
  end
end

defmodule Mortar.Ecto do
  @moduledoc """
  Ecto utility function
  """

  @doc """
  Helper function for unloading the association on a specified record.

  It can be used to undo a preload on the record.

  It's main usecase is to trim the size of a context record before serialization to reduce the
  payload size.
  """
  @spec unload_association(Ecto.Schema.t(), atom()) :: Ecto.Schema.t()
  def unload_association(%schema{} = record, field) do
    nl = to_association_not_loaded(schema.__schema__(:association, field))

    %{
      record
      | field => nl
    }
  end

  @doc """
  Unloads every association on the specified schema.

  Args:
  * `record` - the record to unload the associations on
  """
  @spec unload_associations(Ecto.Schema.t()) :: Ecto.Schema.t()
  def unload_associations(%schema{} = record) do
    unload_associations(record, schema.__schema__(:associations))
  end

  @doc """
  Does the same thing as unload_association/2 but unloads a list of fields
  """
  @spec unload_associations(Ecto.Schema.t(), [atom()]) :: Ecto.Schema.t()
  def unload_associations(record, fields) do
    Enum.reduce(fields, record, &unload_association(&2, &1))
  end

  def to_association_not_loaded(%Ecto.Association.NotLoaded{} = nl) do
    nl
  end

  def to_association_not_loaded(%_{cardinality: cardinality, field: field, owner: owner}) do
    %Ecto.Association.NotLoaded{
      __cardinality__: cardinality,
      __field__: field,
      __owner__: owner
    }
  end

  def maybe_embedded_dump(nil, _type) do
    nil
  end

  def maybe_embedded_dump(value, type) do
    Ecto.embedded_dump(value, type)
  end

  @doc """
  Generates a valid ID for specified schema

  Args:
  * `module` :: the ecto schema
  """
  @spec generate_id(module()) :: binary() | integer()
  def generate_id(module) do
    case module.__schema__(:primary_key) do
      [] ->
        raise "expected module schema to have a primary key"

      [field] ->
        generate_id(module, field)
    end
  end

  @doc """
  Generates a valid ID for specified record schema and field

  Args:
  * `module` - the ecto schema
  * `field` - the field to generate the id for
  """
  @spec generate_id(module(), atom()) :: binary() | integer()
  def generate_id(module, field) do
    case module.__schema__(:type, field) do
      :binary_id ->
        Ecto.UUID.generate()

      Ecto.ULID ->
        Ecto.ULID.generate()
    end
  end

  @doc """
  Attempts to cast the specified value into the schema's respective ID field

  Args:
  * `module` - the ecto schema
  * `field` - the field to cast the id as
  * `value` - the value to cast
  """
  @spec cast_id(module, atom, term) :: {:ok, binary} | :error
  def cast_id(module, field, value) when is_atom(module) do
    case module.__schema__(:type, field) do
      :binary_id ->
        Ecto.UUID.cast(value)

      Ecto.ULID ->
        Ecto.ULID.cast(value)
    end
  end

  def ulid_to_uuid(ulid) when is_binary(ulid) do
    case Ecto.ULID.dump(ulid) do
      {:ok, binary_id} ->
        Ecto.UUID.load(binary_id)

      :error ->
        :error
    end
  end

  def ulid_to_uuid!(ulid) when is_binary(ulid) do
    {:ok, uuid} = ulid_to_uuid(ulid)
    uuid
  end

  def uuid_to_ulid(uuid) when is_binary(uuid) do
    case Ecto.UUID.dump(uuid) do
      {:ok, binary_id} ->
        Ecto.ULID.load(binary_id)

      :error ->
        :error
    end
  end

  def uuid_to_ulid!(uuid) when is_binary(uuid) do
    {:ok, ulid} = uuid_to_ulid(uuid)
    ulid
  end

  @doc """
  Determines if the given value is a valid ID for the specified schema and field
  """
  @spec valid_id?(module(), atom(), term()) :: boolean()
  def valid_id?(schema, field, value) do
    case cast_id(schema, field, value) do
      {:ok, _} ->
        true

      :error ->
        false
    end
  end

  @doc """
  Determines if the given list of ids are valid for the given schema and field
  """
  @spec valid_ids?(module(), atom(), [term()]) :: boolean()
  def valid_ids?(schema, field, values) when is_list(values) do
    Enum.all?(values, &valid_id?(schema, field, &1))
  end
end

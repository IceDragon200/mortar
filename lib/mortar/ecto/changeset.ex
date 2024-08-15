defmodule Mortar.Ecto.Changeset do
  @moduledoc """
  Any additional utility functions for Ecto.Changeset
  """
  import Ecto.Changeset

  def maybe_put_change_lazy(changeset, field, callback) do
    case fetch_change(changeset, field) do
      {:ok, _} ->
        changeset

      :error ->
        put_change(changeset, field, callback.())
    end
  end

  def maybe_put_change(changeset, field, value) do
    case fetch_change(changeset, field) do
      {:ok, _} ->
        changeset

      :error ->
        put_change(changeset, field, value)
    end
  end

  @doc """
  Helper function for using the changeset function of the underlying record
  """
  def change_record(%Ecto.Changeset{data: %schema{}} = changeset, params, type) do
    changeset
    |> schema.changeset(params, type)
  end

  def change_record(%schema{} = record, params, type) do
    record
    |> schema.changeset(params, type)
  end

  def apply_auto(%Ecto.Changeset{data: %schema{}} = changeset, type) do
    autogen_fields = schema.__schema__(type)

    changes = changeset.changes

    changes =
      Enum.reduce(autogen_fields, changes, fn {fields, {mod, fun, args}}, acc ->
        case Enum.reject(fields, &Map.has_key?(changes, &1)) do
          [] ->
            acc

          fields ->
            generated = apply(mod, fun, args)
            Enum.reduce(fields, acc, &Map.put(&2, &1, generated))
        end
      end)

    #schema.__schema__(:autogenerate_id)
    %{changeset | changes: changes}
  end

  def apply_autogenerate(changeset) do
    apply_auto(changeset, :autogenerate)
  end

  def apply_autoupdate(changeset) do
    apply_auto(changeset, :autoupdate)
  end

  def simulate_insert(changeset) do
    changeset
    |> apply_autogenerate()
    |> Ecto.Changeset.apply_action(:insert)
  end

  def simulate_update(changeset) do
    changeset
    |> apply_autoupdate()
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Sometimes you just want the entire changeset errors as a nice compact string.
  """
  @spec changeset_errors_as_string(Ecto.Changeset.t()) :: String.t()
  def changeset_errors_as_string(%Ecto.Changeset{} = changeset) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, msg ->
          String.replace(msg, "%{#{key}}", to_string(value))
        end)
      end)

    errors
    |> Enum.map(fn {key, msg} ->
      "#{key}: (#{msg})"
    end)
    |> Enum.join("; ")
  end

  @spec cast_with_nils(any(), map(), [atom()]) :: Ecto.Changeset.t()
  def cast_with_nils(%Ecto.Changeset{} = changeset, params, allowed_fields) do
    changes =
      Enum.reduce(allowed_fields, %{}, fn key, acc when is_atom(key) ->
        str_key = Atom.to_string(key)

        res =
          case Map.fetch(params, key) do
            {:ok, _value} = res ->
              res

            :error ->
              Map.fetch(params, str_key)
          end

        case res do
          {:ok, value} ->
            Map.put(acc, key, value)

          :error ->
            acc
        end
      end)

    # first try cast, this will correctly populate top-level fields
    changeset = cast(changeset, params, allowed_fields)

    # then try to patch in nils
    Enum.reduce(changes, changeset, fn
      {key, value}, changeset ->
        case Map.fetch(changeset.changes, key) do
          {:ok, _} ->
            changeset

          :error ->
            # this was suppose to be nil then, or nil like
            put_in(changeset.changes[key], value)
        end
    end)
  end

  def cast_with_nils(record, params, allowed_fields) do
    record
    |> change()
    |> cast_with_nils(params, allowed_fields)
  end

  @doc """
  Converts ecto changesets or schemas into parameter maps, this will work by extracting only
  changes from a changeset, rather than the entire schema.

  The purpose is to avoid implicit nils
  """
  @spec unroll_params(Ecto.Changeset.t() | Ecto.Schema.t()) ::
    {:ok, map()}
    | {:error, Ecto.Changeset.t()}
  def unroll_params(%Ecto.Changeset{data: %schema{}} = changeset) do
    if changeset.valid? do
      try do
        primary_keys = schema.__schema__(:primary_key)

        primary_params =
          primary_keys
          |> Enum.map(fn key ->
            {key, Ecto.Changeset.get_field(changeset, key)}
          end)
          |> Enum.into(%{})

        params =
          Enum.map(changeset.changes, fn {key, value} ->
            case schema.__schema__(:embed, key) do
              nil ->
                {key, value}

              %Ecto.Embedded{cardinality: :one} ->
                case unroll_params(value) do
                  {:ok, sub_params} ->
                    {key, sub_params}

                  {:error, _} = err ->
                    throw err
                end

              %Ecto.Embedded{cardinality: :many} ->
                result =
                  Enum.map(value, fn cd ->
                    case unroll_params(cd) do
                      {:ok, sub_params} ->
                        sub_params

                      {:error, _} = err ->
                        throw err
                    end
                  end)

                {key, result}
            end
          end)

        {:ok, Enum.into(params, primary_params)}
      catch {:error, %Ecto.Changeset{}} = err ->
        err
      end
    else
      {:error, changeset}
    end
  end

  def unroll_params(%{__schema__: _} = record) do
    {:ok, Ecto.embedded_dump(record, :json)}
  end
end

defmodule Mortar.Ecto.ChangesetTest do
  defmodule TestSchema do
    use Ecto.Schema

    import Ecto.Changeset

    schema "test_schema" do
      field :name, :string
      field :notes, :string
    end

    def changeset(record, params) do
      changeset(record, params, :create)
    end

    def changeset(record, params, :create) do
      record
      |> cast(params, [
        :name,
      ])
    end
  end

  use ExUnit.Case

  alias Mortar.Ecto.Changeset, as: Subject
  import Ecto.Changeset

  describe "put_new_change_lazy/3" do
    test "can put a change in a changeset if it hasn't already changed" do
      changeset =
        %TestSchema{}
        |> change()
        |> Subject.put_new_change_lazy(:name, fn -> "ABC" end)
        |> Subject.put_new_change_lazy(:name, fn -> "DEF" end)

      assert "ABC" == get_field(changeset, :name)
    end
  end

  describe "put_new_change/3" do
    test "can put a change in a changeset if it hasn't already changed" do
      changeset =
        %TestSchema{}
        |> change()
        |> Subject.put_new_change(:name, "ABC")
        |> Subject.put_new_change(:name, "DEF")

      assert "ABC" == get_field(changeset, :name)
    end
  end

  describe "change_record/3" do
    test "can apply changeset from a given schema" do
      changeset =
        %TestSchema{}
        |> Subject.change_record(%{
          name: "ABC"
        }, :create)

      assert "ABC" == get_field(changeset, :name)
    end

    test "can apply changeset from a given changeset" do
      changeset =
        %TestSchema{}
        |> change()
        |> Subject.change_record(%{
          name: "ABC"
        }, :create)

      assert "ABC" == get_field(changeset, :name)
    end
  end
end

defmodule Mortar.EctoTest do
  defmodule UUIDTestSchema do
    use Ecto.Schema

    @primary_key {:id, :binary_id, autogenerate: true}

    schema "test_schema" do
      timestamps()
    end
  end

  defmodule ULIDTestSchema do
    use Ecto.Schema

    @primary_key {:id, Ecto.ULID, autogenerate: true}

    schema "test_schema" do
      timestamps()
    end
  end

  use ExUnit.Case

  alias Mortar.Ecto, as: Subject

  describe "generate_id/1" do
    test "can generate a UUID" do
      assert {:ok, _} = Ecto.UUID.cast(Subject.generate_id(UUIDTestSchema))
    end

    test "can generate a ULID" do
      assert {:ok, _} = Ecto.ULID.cast(Subject.generate_id(ULIDTestSchema))
    end
  end

  describe "cast_id/3" do
    test "can cast the primary_key of a given schema" do
      uuid = Subject.generate_id(UUIDTestSchema)
      ulid = Subject.generate_id(ULIDTestSchema)

      assert {:ok, _} = Subject.cast_id(UUIDTestSchema, :id, uuid)
      assert :error = Subject.cast_id(UUIDTestSchema, :id, ulid)

      assert {:ok, _} = Subject.cast_id(ULIDTestSchema, :id, ulid)
      assert :error = Subject.cast_id(ULIDTestSchema, :id, uuid)
    end
  end

  describe "valid_id?/3" do
    test "can validate a UUID or ULID" do
      uuid = Subject.generate_id(UUIDTestSchema)
      ulid = Subject.generate_id(ULIDTestSchema)

      assert Subject.valid_id?(UUIDTestSchema, :id, uuid)
      refute Subject.valid_id?(UUIDTestSchema, :id, ulid)
      assert Subject.valid_id?(ULIDTestSchema, :id, ulid)
      refute Subject.valid_id?(ULIDTestSchema, :id, uuid)
    end
  end

  describe "uuid_to_ulid!/1" do
    test "can convert UUID to ULID" do
      uuid = Subject.generate_id(UUIDTestSchema)
      assert _ulid = Subject.uuid_to_ulid!(uuid)
    end
  end

  describe "ulid_to_uuid!/1" do
    test "can convert ULID to UUID" do
      ulid = Subject.generate_id(ULIDTestSchema)
      assert _uuid = Subject.ulid_to_uuid!(ulid)
    end
  end
end

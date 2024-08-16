defmodule Mortar.CryptoTest do
  use ExUnit.Case

  alias Mortar.Crypto, as: Subject

  describe "hmac_sha1/2" do
    test "calculates hmac for a given key and blob as sha1" do
      assert _sha1 = Subject.hmac_sha1("my_key", "Some data")
    end
  end

  describe "hmac_sha256/2" do
    test "calculates hmac for a given key and blob as sha256" do
      assert _sha256 = Subject.hmac_sha256("my_key", "Some data")
    end
  end

  describe "hmac_sha512/2" do
    test "calculates hmac for a given key and blob as sha512" do
      assert _sha512 = Subject.hmac_sha512("my_key", "Some data")
    end
  end
end

defmodule Mortar.NetTest do
  use ExUnit.Case

  alias Mortar.Net, as: Subject

  describe "guess_host_fqdn/0" do
    test "can guess host's fully qualified domain name" do
      # we aren't checking the value
      assert {:ok, _} =  Subject.guess_host_fqdn()
    end
  end

  describe "guess_host_fqdn!/0" do
    test "can guess host's fully qualified domain name" do
      # we aren't checking the value
      assert _ =  Subject.guess_host_fqdn!()
    end
  end

  describe "dns_resolve/3" do
    test "can resolve localhost" do
      assert {:ok, result} = Subject.dns_resolve("localhost", :in, :a)
      assert [entry] = result[:anlist]
      assert ~c"localhost" == entry[:domain]
      assert {127, 0, 0, 1} == entry[:data]
    end
  end

  describe "integer_to_ipv4/1" do
    test "can convert a 32 bit integer to an ip address" do
      assert {:ok, {127, 0, 0, 1}} = Subject.integer_to_ipv4(0x7F000001)
    end
  end

  describe "string_to_ip/1" do
    test "can convert a string to an ipv4 address" do
      assert {:ok, {127, 0, 0, 1}} = Subject.string_to_ip("127.0.0.1")
    end

    test "can convert a string to an ipv6 address" do
      assert {:ok, {0, 0, 0, 0, 0, 0, 0, 1}} = Subject.string_to_ip("::1")
    end
  end

  describe "ip_to_string/1" do
    test "can convert a ipv4 to a string" do
      assert {:ok, "127.0.0.1"} == Subject.ip_to_string({127, 0, 0, 1})
    end
  end

  describe "maybe_ip_to_string/1" do
    test "can handle nil" do
      assert {:ok, nil} == Subject.maybe_ip_to_string(nil)
    end
  end
end

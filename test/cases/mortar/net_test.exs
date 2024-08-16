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
end

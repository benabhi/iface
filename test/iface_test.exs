defmodule IfaceTest do
  use ExUnit.Case
  doctest Iface
  doctest Iface.Ldap.Users

  test "greets the world" do
    assert Iface.hello() == :world
  end
end

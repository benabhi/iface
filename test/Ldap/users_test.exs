defmodule Iface.Ldap.UsersTest do
  use ExUnit.Case
  alias Iface.Ldap.Users

  doctest Iface.Ldap.Users, except: [user_create: 5]

  # test "El ultimo uid debe ser 131204" do
  #  assert Users.user_last_uid(Paddle) == 131_204
  # end
end

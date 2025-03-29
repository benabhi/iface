# defmodule Iface.Ldap.Users2 do
#   @moduledoc """

#     ! TODO: Documentar
#     ! TODO: Crear una funcion que cree el usuario de prueba para hacer los tests

#   """

#   alias Iface.Ldap.Ldap
#   alias Iface.Ldap.Utils

#   # @default_mail_quota 230
#   # @default_groups ["Domain Users", "impresion"]

#   @spec user_valid_credentials?(String.t(), String.t()) :: boolean
#   @doc """
#   Chequea si las credenciales de un usuario de ldap son validas

#   ## Examples

#       iex> Iface.Ldap.Users.user_valid_credentials?("jcbatman", "123456")
#       true
#   """
#   def user_valid_credentials?(username, password) do
#     case Paddle.authenticate([uid: username, ou: "Users"], password) do
#       :ok -> true
#       _ -> false
#     end
#   end

#   # def user_create(username, password, name, lastname, groups \\ [], samba \\ true, mail \\ true) do
#   #   objectclass = [
#   #     "top",
#   #     "policeOrgPerson",
#   #     "posixAccount",
#   #     "inetOrgPerson",
#   #     "organizationalPerson",
#   #     "person",
#   #     # "CourierMailAccount",
#   #     # "fetchmailUser",
#   #     # "usereboxmail",
#   #     "passwordHolder"
#   #   ]

#   #   Ldap.run_as_admin(fn ->
#   #     Paddle.add(
#   #       [uid: username, ou: "Users"],
#   #       # uid: username,
#   #       objectclass: objectclass,
#   #       cn: "#{name} #{lastname}",
#   #       sn: lastname,
#   #       givenName: name,
#   #       userPassword: hash(password),
#   #       homeDirectory: "/home/#{username}",
#   #       loginShell: "/bin/bash",
#   #       mail: "#{username}@example.com",
#   #       mailQuota: @mail_quota
#   #     )
#   #   end)
#   # end

#   @spec user_get_all() :: {:ok, [map()]} | Ldap.ldap_error()
#   @doc ~S"""
#   Obtiene la informacion de todos los usuarios

#   ## Examples

#       iex> {:ok, users} = Iface.Ldap.Users.user_get_all()
#       iex> batman = Enum.find(users, fn user -> user["uid"] == "jcbatman" end)
#       iex> "#{batman["sn"]}, #{batman["givenName"]}"
#       "Batman, Juan Carlos"
#   """
#   def user_get_all() do
#     Ldap.run_as_admin(fn ->
#       # * NOTA: Fue necesario ejecutar el get con un timeout por eso no use
#       # *       Paddle.get y en su lugar use GenServer.call, por otro lado
#       # *       el timeout del config no funciono :S
#       case GenServer.call(
#              Paddle,
#              {:get, [objectClass: "posixAccount"], [ou: "Users"], :base},
#              :infinity
#            ) do
#         {:ok, entries} ->
#           {:ok,
#            entries
#            |> Enum.map(&flatten_lists_values/1)}

#         err ->
#           err
#       end
#     end)
#   end

#   @spec user_list() :: {:ok, [String.t()]} | Ldap.ldap_error()
#   @doc """
#   Obtiene la lista de usuarios

#   ## Examples

#       iex> {:ok, users} = Iface.Ldap.Users.user_list()
#       iex> Enum.any?(users, fn user -> user == "jcbatman" end)
#       true
#   """
#   def user_list() do
#     case user_get_all() do
#       {:ok, entries} ->
#         {:ok,
#          entries
#          |> Enum.map(&Map.get(&1, "uid"))}

#       err ->
#         err
#     end
#   end

#   @spec user_exists?(String.t()) :: boolean
#   @doc """
#   Verifica si un usuario existe

#   ## Examples

#       iex> Iface.Ldap.Users.user_exists?("jcbatman")
#       true
#   """
#   def user_exists?(username) do
#     Ldap.run_as_admin(fn ->
#       case user_list() do
#         {:ok, users} ->
#           users
#           |> Enum.member?(username)

#         err ->
#           err
#       end
#     end)
#   end

#   @spec user_info(String.t()) :: {:ok, map()} | Ldap.ldap_error()
#   @doc ~S"""
#   Obtiene la informacion de un usuario

#   ## Examples

#       iex> {:ok, user} = Iface.Ldap.Users.user_info("jcbatman")
#       iex> "#{user["sn"]}, #{user["givenName"]}"
#       "Batman, Juan Carlos"
#   """
#   def user_info(username) do
#     Ldap.run_as_admin(fn ->
#       case Paddle.get(base: [ou: "Users"], filter: [uid: username]) do
#         {:ok, entries} ->
#           {:ok,
#            entries
#            |> hd
#            |> flatten_lists_values}

#         err ->
#           err
#       end
#     end)
#   end

#   @spec user_change_password(String.t(), String.t()) :: :ok | Ldap.ldap_error()
#   @doc """
#   Cambia la password de un usuario

#   ## Examples

#       iex> Iface.Ldap.Users.user_change_password("jcbatman", "123456")
#       :ok

#       iex> Iface.Ldap.Users.user_valid_credentials?("jcbatman", "123456")
#       true
#   """
#   def user_change_password(username, new_password) do
#     Ldap.run_as_admin(fn ->
#       Paddle.modify([uid: username, ou: "Users"],
#         replace: {"userPassword", Utils.hash_password(new_password)}
#       )
#     end)
#   end

#   @doc """
#   Obtiene los grupos de un usuario

#   """
#   def user_groups(username) do
#     Ldap.run_as_admin(fn ->
#       case Paddle.get(base: [ou: "Groups"], filter: [memberUid: username]) do
#         {:ok, entries} ->
#           {:ok,
#            entries
#            |> Enum.map(&hd(&1["cn"]))}

#         err ->
#           err
#       end
#     end)
#   end

#   @spec user_add_to_groups(String.t(), [String.t()]) :: :ok | Ldap.ldap_error()
#   @doc """
#   Agrega un usuario a un grupo

#   ## Examples

#       iex> Iface.Ldap.Users.user_add_to_groups("jcbatman", ["Domain Users"])
#       :ok

#       iex> Iface.Ldap.Users.user_add_to_groups("jcbatman", ["Domain Users", "Domain Admins"])
#       :ok
#   """
#   def user_add_to_groups(username, groups) do
#     Ldap.run_as_admin(fn ->
#       Enum.each(groups, fn group ->
#         case Paddle.modify([cn: group, ou: "Groups"], add: {"memberUid", username}) do
#           {:ok, _} -> :ok
#           err -> err
#         end
#       end)
#     end)
#   end

#   @spec user_in_groups?(String.t(), [String.t()]) :: boolean
#   @doc """
#   Verifica si un usuario pertenece a un grupo o conjunto de grupos

#   ## Examples

#       iex> Iface.Ldap.Users.user_in_groups?("jcbatman", ["Domain Users"])
#       true

#       iex> Iface.Ldap.Users.user_in_groups?("jcbatman", ["Domain Users", "Domain Admins"])
#       true

#       iex> Iface.Ldap.Users.user_in_groups?("jcbatman", ["NO_EXISTE"])
#       false
#   """
#   def user_in_groups?(username, groups) do
#     case user_groups(username) do
#       {:ok, current_groups} ->
#         groups
#         |> Enum.all?(&Enum.member?(current_groups, &1))

#       err ->
#         err
#     end
#   end

#   def user_last_uid(next \\ true) do
#     case user_get_all() do
#       {:ok, users} ->
#         if next do
#           # 1. Ordeno por uidNumber
#           # 2. Obtengo el valor del campo uidNumber (string)
#           # 3. Lo convierto a entero
#           # 4. Le sumo 1
#           Enum.max_by(users, fn user -> user["uidNumber"] end)
#           |> Map.get("uidNumber")
#           |> String.to_integer()
#           |> Kernel.+(1)
#         else
#           Enum.max_by(users, fn user -> user["uidNumber"] end)
#           |> Map.get("uidNumber")
#           |> String.to_integer()
#         end

#       err ->
#         err
#     end
#   end

#   # HELPERS

#   # Los mapas que vienen de LDAP tienen el formato {key: [value]} en vez de
#   # {key: value}, esta funcion lo convierte pero solo si el value es una lista
#   # de un solo elemento.
#   defp flatten_lists_values(result) do
#     result
#     |> Enum.map(fn {key, value} ->
#       new_value =
#         case value do
#           [single] -> single
#           _ -> value
#         end

#       {key, new_value}
#     end)
#     |> Enum.into(%{})
#   end
# end

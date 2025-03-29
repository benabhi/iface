defmodule Iface.Ldap.Users do
  @moduledoc """
    Este modulo contiene funciones para interactuar con los usuarios de ldap

    Listado de funciones y sus usos:

    # ! Ordenar las funciones tal cual el modulo

    - `user_valid_credentials?/3` - Chequea si las credenciales de un usuario de ldap son validas
    - # ! Agregar user_create
    - `user_get_all/1` - Obtiene la informacion de todos los usuarios
    - `user_list/1` - Obtiene la lista de usuarios
    - `user_exists?/2` - Verifica si un usuario existe
    - `user_info/2` - Obtiene la informacion de un usuario
    - `user_change_password/3` - Cambia la contraseña de un usuario
    - `user_in_groups?/3` - Verifica si un usuario pertenece a un grupo o conjunto de grupos
    - `user_add_to_groups/3` - Agrega un usuario a un grupo
    - `user_groups/2` - Obtiene los grupos de un usuario
    - `user_last_uid/2` - Obtiene el ultimo uid de un usuario
    - `user_delete/2` - Elimina un usuario

  """

  alias Iface.Ldap
  alias Iface.Ldap.Utils

  @spec user_valid_credentials?(String.t(), String.t(), module()) :: boolean
  @doc """
  Chequea si las credenciales de un usuario de ldap son validas

  ## Examples

      iex> Iface.Ldap.Users.user_valid_credentials?("jcbatman", "123456", Paddle)
      true
  """
  def user_valid_credentials?(username, password, ldap_client) do
    case ldap_client.authenticate([uid: username, ou: "Users"], password) do
      :ok -> true
      _ -> false
    end
  end

  # ! TODO: Crear esta funcion
  def user_create() do
    :todo
  end

  @spec user_get_all(module()) :: {:ok, [map()]} | Ldap.ldap_error()
  @doc ~S"""
  Obtiene la informacion de todos los usuarios

  ## Examples

      iex> {:ok, users} = Iface.Ldap.Users.user_get_all(Paddle)
      iex> batman = Enum.find(users, fn user -> user["uid"] == "jcbatman" end)
      iex> "#{batman["sn"]}, #{batman["givenName"]}"
      "Batman, Juan Carlos"
  """
  def user_get_all(ldap_client) do
    Ldap.run_as_admin(ldap_client, fn ->
      # * NOTA: Fue necesario ejecutar el get con un timeout por eso no use
      # *       Paddle.get y en su lugar use GenServer.call, por otro lado
      # *       el timeout del config (de Paddle) no funciono :S
      case GenServer.call(
             ldap_client,
             {:get, [objectClass: "posixAccount"], [ou: "Users"], :base},
             :infinity
           ) do
        {:ok, entries} ->
          {:ok,
           entries
           |> Enum.map(&flatten_lists_values/1)}

        err ->
          err
      end
    end)
  end

  @spec user_list(module()) :: {:ok, [String.t()]} | Ldap.ldap_error()
  @doc """
  Obtiene la lista de usuarios

  ## Examples

      iex> {:ok, users} = Iface.Ldap.Users.user_list(Paddle)
      iex> Enum.any?(users, fn user -> user == "jcbatman" end)
      true
  """
  def user_list(ldap_client) do
    case user_get_all(ldap_client) do
      {:ok, entries} ->
        {:ok,
         entries
         |> Enum.map(&Map.get(&1, "uid"))}

      err ->
        err
    end
  end

  @spec user_exists?(String.t(), module()) :: boolean
  @doc """
  Verifica si un usuario existe

  ## Examples

      iex> Iface.Ldap.Users.user_exists?("jcbatman", Paddle)
      true
  """
  def user_exists?(username, ldap_client) do
    Ldap.run_as_admin(ldap_client, fn ->
      case user_list(ldap_client) do
        {:ok, users} ->
          users
          |> Enum.member?(username)

        err ->
          err
      end
    end)
  end

  @spec user_info(String.t(), module()) :: {:ok, map()} | Ldap.ldap_error()
  @doc ~S"""
  Obtiene la informacion de un usuario

  ## Examples

      iex> {:ok, user} = Iface.Ldap.Users.user_info("jcbatman", Paddle)
      iex> "#{user["sn"]}, #{user["givenName"]}"
      "Batman, Juan Carlos"
  """
  def user_info(username, ldap_client) do
    Ldap.run_as_admin(ldap_client, fn ->
      case ldap_client.get(base: [ou: "Users"], filter: [uid: username]) do
        {:ok, entries} ->
          {:ok,
           entries
           |> hd
           |> flatten_lists_values}

        err ->
          err
      end
    end)
  end

  @spec user_change_password(String.t(), String.t(), module()) :: :ok | Ldap.ldap_error()
  @doc """
  Cambia la password de un usuario

  ## Examples

      iex> Iface.Ldap.Users.user_change_password("jcbatman", "123456", Paddle)
      :ok

      iex> Iface.Ldap.Users.user_valid_credentials?("jcbatman", "123456", Paddle)
      true
  """
  def user_change_password(username, new_password, ldap_client) do
    Ldap.run_as_admin(ldap_client, fn ->
      ldap_client.modify([uid: username, ou: "Users"],
        replace: {"userPassword", Utils.hash_password(new_password)}
      )
    end)
  end

  @spec user_add_to_groups(String.t(), [String.t()], module()) :: :ok | Ldap.ldap_error()
  @doc """
  Agrega un usuario a un grupo

  ## Examples

      iex> Iface.Ldap.Users.user_add_to_groups("jcbatman", ["Domain Users"], Paddle)
      :ok

      iex> Iface.Ldap.Users.user_add_to_groups("jcbatman", ["Domain Users", "Domain Admins"], Paddle)
      :ok
  """
  def user_add_to_groups(username, groups, ldap_client) do
    Ldap.run_as_admin(ldap_client, fn ->
      Enum.each(groups, fn group ->
        case ldap_client.modify([cn: group, ou: "Groups"], add: {"memberUid", username}) do
          {:ok, _} -> :ok
          err -> err
        end
      end)
    end)
  end

  @spec user_groups(String.t(), module()) :: {:ok, [String.t()]} | Ldap.ldap_error()
  @doc """
  Obtiene los grupos de un usuario

  ## Examples

      iex> {:ok, groups} = Iface.Ldap.Users.user_groups("jcbatman", Paddle)
      iex> Enum.any?(groups, fn group -> group == "Domain Users" end)
      true

  """
  def user_groups(username, ldap_client) do
    Ldap.run_as_admin(ldap_client, fn ->
      case ldap_client.get(base: [ou: "Groups"], filter: [memberUid: username]) do
        {:ok, entries} ->
          {:ok,
           entries
           |> Enum.map(&hd(&1["cn"]))}

        err ->
          err
      end
    end)
  end

  @spec user_in_groups?(String.t(), [String.t()], module()) :: boolean
  @doc """
  Verifica si un usuario pertenece a un grupo o conjunto de grupos

  ## Examples

      iex> Iface.Ldap.Users.user_in_groups?("jcbatman", ["Domain Users"], Paddle)
      true

      iex> Iface.Ldap.Users.user_in_groups?("jcbatman", ["Domain Users", "Domain Admins"], Paddle)
      true

      iex> Iface.Ldap.Users.user_in_groups?("jcbatman", ["NO_EXISTE"], Paddle)
      false
  """
  def user_in_groups?(username, groups, ldap_client) do
    case user_groups(username, ldap_client) do
      {:ok, current_groups} ->
        groups
        |> Enum.all?(&Enum.member?(current_groups, &1))

      err ->
        err
    end
  end

  # ! TODO: Crear esta funcion
  def user_delete() do
    :todo
  end

  @doc """
  Obtiene el uidNumber del ultimo usuario creado

  # ! TODO: Doctest, y Verificar si realmenter el numero es el ultimo
  """
  def user_last_uid(next \\ true, ldap_client) do
    case user_get_all(ldap_client) do
      {:ok, users} ->
        if next do
          # 1. Ordeno por uidNumber
          # 2. Obtengo el valor del campo uidNumber (string)
          # 3. Lo convierto a entero
          # 4. Le sumo 1
          Enum.max_by(users, fn user -> user["uidNumber"] end)
          |> Map.get("uidNumber")
          |> String.to_integer()
          |> Kernel.+(1)
        else
          Enum.max_by(users, fn user -> user["uidNumber"] end)
          |> Map.get("uidNumber")
          |> String.to_integer()
        end

      err ->
        err
    end
  end

  # HELPERS

  # Los mapas que vienen de LDAP tienen el formato {key: [value]} en vez de
  # {key: value}, esta funcion lo convierte pero solo si el value es una lista
  # de un solo elemento.
  # ! TODO: Ver si lo dejo aca o lo muevo a utils (sobretodo si lo usa groups)
  defp flatten_lists_values(result) do
    result
    |> Enum.map(fn {key, value} ->
      new_value =
        case value do
          [single] -> single
          _ -> value
        end

      {key, new_value}
    end)
    |> Enum.into(%{})
  end
end

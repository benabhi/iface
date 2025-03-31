defmodule Iface.Ldap.Users do
  @moduledoc """
    Este modulo contiene funciones para interactuar con los usuarios de ldap

    Listado de funciones sus usos:

    # ! TODO: Completar el listado

  """

  alias Iface.Ldap
  alias Iface.Ldap.Utils

  # * Iface.Ldap.Users.user_create("jcbatman", "123456", "Juan Carlos", "Batman", Paddle)
  @spec user_create(String.t(), String.t(), String.t(), String.t(), module()) ::
          :ok | Ldap.ldap_error()
  @spec user_create(String.t(), String.t(), String.t(), String.t(), module(), [atom()]) ::
          :ok | Ldap.ldap_error()
  @doc """
  Crea un nuevo usuario en ldap

  Por defecto lo crea con todos los objectClass (`mail`, `samba`, `shadow`)

  ## Examples

      iex> Iface.Ldap.Users.user_create("jcbatman", "123456", "Juan Carlos", "Batman", Paddle)
      :ok

  """
  def user_create(username, password, name, lastname, ldap_client) do
    user_create(username, password, name, lastname, ldap_client, [:samba, :shadow, :mail])
  end

  @doc """
  Crea un nuevo usuario en ldap

  Se pueden pasar parametros adicionales con `opts`

  ## Options

    - `:mail` - Agrega el objectClass `CourierMailAccount`, `fetchmailUser` y `usereboxmail`
    - `:samba` - Agrega el objectClass `sambaSamAccount`
    - `:shadow` - Agrega el objectClass `shadowAccount`

  ## Examples

      iex> Iface.Ldap.Users.user_create("jcbatman", "123456", "Juan Carlos", "Batman", Paddle, [:shadow])
      :ok

  """
  # ? NOTA: Esta excluida de los doctest para evitar que vuelva a crear un usuario
  def user_create(username, password, name, lastname, ldap_client, opts) do
    # Validar que todos los parámetros sean ASCII imprimibles
    if Enum.any?([username, password, name, lastname], &(!Utils.is_ascii?(&1))) do
      {:error, :nonASCIIArguments}
    else
      # Base objectClass para cualquier usuario
      base_objectclass = [
        "top",
        "policeOrgPerson",
        "posixAccount",
        "inetOrgPerson",
        "organizationalPerson",
        "person",
        "passwordHolder"
      ]

      # Agrega dinámicamente objectClass según las opciones
      dynamic_objectclass =
        opts
        |> Enum.reduce([], fn
          :mail, acc -> ["CourierMailAccount", "fetchmailUser", "usereboxmail" | acc]
          :samba, acc -> ["sambaSamAccount" | acc]
          :shadow, acc -> ["shadowAccount" | acc]
          _, acc -> acc
        end)

      objectclass = base_objectclass ++ dynamic_objectclass

      # Calcular atributos comunes
      user_password = Utils.hash_password(password)
      last_uid = user_last_uid(true, ldap_client)
      samba_sid = "S-1-5-21-2536628940-703160423-1994053749"
      domain = "policia.rionegro.gov.ar"

      default_attributes = %{
        objectclass: objectclass,
        uidNumber: last_uid,
        gidNumber: 1901,
        cn: "#{name} #{lastname}",
        sn: lastname,
        givenName: name,
        gecos: "#{name} #{lastname}",
        loginShell: "/bin/bash",
        userPassword: user_password,
        hasMoodleAccess: "FALSE",
        homeDirectory: "/var/vmail"
      }

      # Agrega dinámicamente atributos según las opciones
      dynamic_attributes =
        opts
        |> Enum.reduce(default_attributes, fn
          :mail, acc ->
            Map.merge(acc, %{
              quota: 230,
              mail: "#{username}@#{domain}",
              mailbox: "#{username}@#{domain}",
              mailHomeDirectory: "/home/#{username}",
              userMailDirSize: 1
            })

          :samba, acc ->
            Map.merge(acc, %{
              sambaDomainName: "POLICIA",
              sambaSID: "#{samba_sid}-#{last_uid}",
              sambaNTPassword: Utils.gen_samba_password(password),
              sambaAcctFlags: "[U          ]",
              sambaPasswordHistory: String.duplicate("0", 65),
              sambaPrimaryGroupSID: "#{samba_sid}-513",
              sambaKickoffTime: "2147483647",
              sambaPwdCanChange: "2147483647",
              sambaPwdMustChange: "2147483647",
              sambaPwdLastSet: "2147483647"
            })

          :shadow, acc ->
            Map.merge(acc, %{
              shadowFlag: "0",
              shadowExpire: "-1",
              shadowMax: "999999",
              shadowMin: "8",
              shadowWarning: "7"
            })

          _, acc ->
            acc
        end)

      # Ejecuta la operación LDAP para agregar el usuario
      Ldap.run_as_admin(
        fn ->
          ldap_client.add([uid: username, ou: "Users"], dynamic_attributes)
        end,
        ldap_client
      )
    end
  end

  @spec user_valid_credentials?(String.t(), String.t(), module()) :: boolean()
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
    Ldap.run_as_admin(
      fn ->
        case ldap_client.get(base: [ou: "Users"]) do
          {:ok, entries} ->
            {:ok,
             entries
             |> Enum.map(&Utils.flatten_lists_values/1)}

          err ->
            err
        end
      end,
      ldap_client
    )
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

  @spec user_exists?(String.t(), module()) :: boolean()
  @doc """
  Verifica si un usuario existe

  ## Examples

      iex> Iface.Ldap.Users.user_exists?("jcbatman", Paddle)
      true
  """
  def user_exists?(username, ldap_client) do
    Ldap.run_as_admin(
      fn ->
        case user_list(ldap_client) do
          {:ok, users} ->
            users
            |> Enum.member?(username)

          err ->
            err
        end
      end,
      ldap_client
    )
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
    Ldap.run_as_admin(
      fn ->
        case ldap_client.get(base: [ou: "Users"], filter: [uid: username]) do
          {:ok, entries} ->
            # ! TODO: case nil?
            {:ok,
             entries
             |> hd
             |> Utils.flatten_lists_values()}

          err ->
            err
        end
      end,
      ldap_client
    )
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
    Ldap.run_as_admin(
      fn ->
        ldap_client.modify([uid: username, ou: "Users"],
          replace: {"userPassword", Utils.hash_password(new_password)}
        )
      end,
      ldap_client
    )
  end

  @spec user_add_to_group(String.t(), String.t(), module()) :: :ok | Ldap.ldap_error()
  @doc """
  Agrega un usuario a un grupo

  ## Examples

      iex> Iface.Ldap.Users.user_add_to_group("jcbatman", "Domain Users", Paddle)
      :ok
  """
  def user_add_to_group(username, group, ldap_client) do
    Ldap.run_as_admin(
      fn ->
        ldap_client.modify([cn: group, ou: "Groups"], add: {"memberUid", username})
      end,
      ldap_client
    )
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
    Ldap.run_as_admin(
      fn ->
        case ldap_client.get(base: [ou: "Groups"], filter: [memberUid: username]) do
          {:ok, entries} ->
            {:ok,
             entries
             |> Enum.map(&hd(&1["cn"]))}

          err ->
            err
        end
      end,
      ldap_client
    )
  end

  @spec user_in_groups?(String.t(), [String.t()], module()) :: boolean()
  @doc """
  Verifica si un usuario pertenece a un grupo o conjunto de grupos

  ## Examples

      iex> Iface.Ldap.Users.user_in_groups?("jcbatman", ["Domain Users"], Paddle)
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

  @doc """
  Quita un usuario de un grupo

  ## Examples

      iex> Iface.Ldap.Users.user_remove_from_group("jcbatman", "Domain Users", Paddle)
      :ok

  # * La unica forma que encontre de hacer esto es obteniendo la lista de usuarios,
  # * quitandole el username y luego modificando el grupo
  """
  def user_remove_from_group(username, group, ldap_client) do
    Ldap.run_as_admin(
      fn ->
        # obtenemos todos los memberUid como lista
        case ldap_client.get(base: [ou: "Groups"], filter: [cn: group]) do
          {:ok, entries} ->
            case entries
                 |> hd
                 |> Map.get("memberUid") do
              # Si el usuario no pertenece al grupo
              nil ->
                :ok

              memberUids ->
                # Quito el username de la lista de memberUid del grupo y lo modifico
                case ldap_client.modify([cn: group, ou: "Groups"],
                       replace: {"memberUid", memberUids -- [username]}
                     ) do
                  {:ok, _} -> :ok
                  err -> err
                end
            end

          err ->
            err
        end
      end,
      ldap_client
    )
  end

  @spec user_modify(String.t(), [{atom(), String.t()}], module()) :: :ok | Ldap.ldap_error()
  @doc """
  Modifica un usuario

  ## Examples

      iex> Iface.Ldap.Users.user_modify("jcbatman", {"givenName", "Juan Pedro"}, Paddle)
      :ok
  """
  def user_modify(username, attrs, ldap_client) do
    Ldap.run_as_admin(
      fn ->
        ldap_client.modify([uid: username, ou: "Users"], replace: attrs)
      end,
      ldap_client
    )
  end

  @spec user_delete(String.t(), module()) :: :ok | Ldap.ldap_error()
  @doc """
  Elimina un usuario

  ## Examples

      iex> Iface.Ldap.Users.user_delete("jcbatman", Paddle)
      :ok
  """
  def user_delete(username, ldap_client) do
    Ldap.run_as_admin(
      fn ->
        ldap_client.delete(uid: username, ou: "Users")
      end,
      ldap_client
    )
  end

  @doc """
  Obtiene el uidNumber del ultimo usuario creado

  # ! TODO: Doctest, y Verificar si realmenter el numero es el ultimo
  """
  def user_last_uid(next \\ true, ldap_client) do
    # Funcion anonima para evitar repeticion
    parsed_uids = fn users ->
      users
      |> Enum.map(fn user -> user["uidNumber"] end)
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&String.to_integer/1)
      |> Enum.max()
    end

    case user_get_all(ldap_client) do
      {:ok, users} ->
        if next do
          users
          |> parsed_uids.()
          |> Kernel.+(1)
        else
          users
          |> parsed_uids.()
        end

      err ->
        err
    end
  end
end

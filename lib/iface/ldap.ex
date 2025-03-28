defmodule Iface.Ldap do
  @moduledoc """

    ! TODO: Documentar
    ! TODO: Crear una funcion que cree el usuario de prueba para hacer los tests

  """

  @spec user_list() :: {:ok, list(String.t())} | {:error, String.t()}
  @doc """
  Obtiene la lista de usuarios

  ## Examples

      iex> {:ok, users} = Iface.Ldap.user_list()
      iex> Enum.count(users) > 0
      true
  """
  def user_list() do
    run_as_admin(fn ->
      # * NOTA: Fue necesario ejecutar el get con un timeout por eso no use
      # *       Paddle.get y en su lugar use GenServer.call, por otro lado
      # *       el timeout del config no funciono :S
      case GenServer.call(
             Paddle,
             {:get, [objectClass: "posixAccount"], [ou: "Users"], :base},
             10000
           ) do
        {:ok, entries} ->
          {:ok, Enum.map(entries, &hd(&1["uid"]))}

        err ->
          err
      end
    end)
  end

  @spec user_exists?(String.t()) :: boolean
  @doc """
  Verifica si un usuario existe

  ## Examples

      iex> Iface.Ldap.user_exists?("netsistpolrn")
      true
  """
  def user_exists?(username) do
    run_as_admin(fn ->
      case user_list() do
        {:ok, users} -> users |> Enum.member?(username)
        err -> err
      end
    end)
  end

  @spec user_info(String.t()) :: {:ok, map()} | {:error, String.t()}
  @doc """
  Obtiene la informacion de un usuario
  """
  def user_info(username) do
    run_as_admin(fn ->
      case Paddle.get(base: [ou: "Users"], filter: [uid: username]) do
        {:ok, entries} ->
          {:ok, hd(entries)}

        err ->
          err
      end
    end)
  end

  @spec change_password(String.t(), String.t()) :: :ok | {:error, String.t()}
  @doc """
  Cambia la contraseña de un usuario
  """
  def change_password(username, new_password) do
    run_as_admin(fn ->
      Paddle.modify([uid: username, ou: "Users"],
        replace: {"userPassword", hash(new_password)}
      )
    end)
  end

  @spec user_groups(String.t()) :: list(String.t())
  @doc """
  Obtiene los grupos de un usuario
  """
  def user_groups(username) do
    run_as_admin(fn ->
      case Paddle.get(base: [ou: "Groups"], filter: [memberUid: username]) do
        {:ok, entries} ->
          Enum.map(entries, &hd(&1["cn"]))

        err ->
          err
      end
    end)
  end

  @spec user_in_group?(String.t(), String.t()) :: boolean
  @doc """
  Verifica si un usuario pertenece a un grupo
  """
  def user_in_group?(username, group) do
    Enum.member?(user_groups(username), group)
  end

  @spec authenticate?(String.t(), String.t()) :: boolean
  @doc """
  Autentica un usuario

  ## Examples

      iex> Iface.Ldap.authenticate?("netsistpolrn", "daledaledale123")
      true
  """
  def authenticate?(username, password) do
    case Paddle.authenticate([uid: username, ou: "Users"], password) do
      :ok -> true
      _ -> false
    end
  end

  # ! Funcion importante, toma una funcion anonima como parametro que se ejecuta
  # ! luego de la autenticacion, para evitar la repeticion de codigo
  defp run_as_admin(fun) do
    # .env
    %{"LDAP_ADM_USER" => admuser, "LDAP_ADM_PASS" => admpass} = Dotenv.env().values

    case Paddle.authenticate([cn: admuser], admpass) do
      :ok -> fun.()
      err -> err
    end
  end

  # TODO: Parametro opcional para seleccionar otro Hash
  defp hash(password) do
    # Genera un salt aleatorio de 4 bytes
    salt = :crypto.strong_rand_bytes(4)
    # Hash SHA-1 con el salt
    hash = :crypto.hash(:sha, password <> salt)
    # Codifica en Base64 (formato típico de SSHA)
    hash = "{SSHA}" <> Base.encode64(hash <> salt)
    # Elimina los caracteres "=" del final
    String.trim_trailing(hash, "=")
  end
end

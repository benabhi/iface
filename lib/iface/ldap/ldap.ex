defmodule Iface.Ldap do
  @type ldap_error :: {:error, tuple()}

  @spec run_as_admin(module(), function()) :: any() | no_return()
  @doc """
  Se ejecuta una funcion con permisos de administrador

  ## Examples

      iex> Iface.Ldap.Ldap.run_as_admin(Paddle, fn -> ldap_client.get_single(base: [ou: "Users"]) end)
      {:ok, %{ "dn" => "ou=Users", "objectClass" => ["organizationalUnit"], "ou" => ["Users"] }}

  """
  # ! Funcion importante, toma una funcion anonima como parametro que se ejecuta
  # ! luego de la autenticacion, para evitar la repeticion de codigo
  def run_as_admin(ldap_client, fun) when is_function(fun) do
    # TODO: Es necesario chequear cada variable? o dejo esto que es general?
    if(Enum.empty?(Dotenv.env().values)) do
      raise("No se pudo cargar el archivo .env!")
    end

    # .env
    %{"LDAP_ADM_USER" => admuser, "LDAP_ADM_PASS" => admpass} = Dotenv.env().values

    case ldap_client.authenticate([cn: admuser], admpass) do
      :ok -> fun.()
      err -> err
    end
  end
end

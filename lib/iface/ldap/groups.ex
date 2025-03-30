defmodule Iface.Ldap.Groups do
  alias Iface.Ldap
  alias Iface.Ldap.Utils

  def group_create(name, ldap_client) do
    if !Utils.is_ascii?(name) do
      {:error, :nonASCIIArguments}
    else
      attrs = [
        gidNumber: group_last_gid(Paddle),
        objectClass: ["posixGroup", "sambaGroupMapping"],
        displayName: name,
        sambaGroupType: "2",
        sambaSID: "S-1-5-21-2536628940-703160423-1994053749-#{group_last_gid(Paddle)}",
        description: name
      ]

      Ldap.run_as_admin(
        fn ->
          case ldap_client.add([cn: name, ou: "Groups"], attrs) do
            {:ok, _} -> :ok
            err -> err
          end
        end,
        ldap_client
      )
    end
  end

  def group_get_all(ldap_client) do
    Ldap.run_as_admin(
      fn ->
        case ldap_client.get(base: [ou: "Groups"], filter: [objectClass: "posixGroup"]) do
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

  def group_last_gid(next \\ true, ldap_client) do
    # Funcion anonima para evitar repeticion
    parsed_gids = fn groups ->
      groups
      |> Enum.map(fn group -> group["gidNumber"] end)
      |> Enum.map(&String.to_integer/1)
      |> Enum.max()
    end

    case group_get_all(ldap_client) do
      {:ok, groups} ->
        if next do
          groups
          |> parsed_gids.()
          |> Kernel.+(1)
        else
          groups
          |> parsed_gids.()
        end

      err ->
        err
    end
  end
end

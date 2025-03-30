defmodule Iface.Ldap.Utils do
  # Los mapas que vienen de LDAP tienen el formato {key: [value]} en vez de
  # {key: value}, esta funcion lo convierte pero solo si el value es una lista
  # de un solo elemento.
  # ! TODO: Ver si lo dejo aca o lo muevo a utils (sobretodo si lo usa groups)
  def flatten_lists_values(result) do
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

  def is_ascii?(string) when is_binary(string) do
    string
    # Convierte la cadena a una lista de caracteres
    |> String.to_charlist()
    # Verifica que todos los caracteres estén en el rango ASCII
    |> Enum.all?(&(0 <= &1 and &1 <= 127))
  end

  # Hash password con un parámetro opcional para elegir el tipo de hash
  @spec hash_password(String.t(), atom()) :: String.t()
  def hash_password(password, type \\ :ssha) do
    salt = :crypto.strong_rand_bytes(4)

    # Lógica dependiendo del tipo de hash seleccionado
    case type do
      :plain ->
        # Devuelve el password plano (sin salt ni codificación)
        password

      :sha ->
        # Usar SHA1 directamente
        hash = :crypto.hash(:sha, password <> salt)
        Base.encode64(hash)

      :ssha ->
        # Usar SHA1 con salt y formato SSHA
        hash = :crypto.hash(:sha, password <> salt)
        hash = "{SSHA}" <> Base.encode64(hash <> salt)
        String.trim_trailing(hash, "=")

      _ ->
        # Si el tipo no es reconocido, lanzar un error o devolver un valor por defecto
        raise "Tipo de hash no soportado"
    end
  end

  # ! Importante! guardar esta funcion, es dificil de reproducir luego
  def gen_samba_password(password) do
    password
    # Convertir de UTF-8 a binario
    |> :unicode.characters_to_binary(:utf8)
    # Convertir a lista de bytes
    |> :binary.bin_to_list()
    # Inyectar 0 bytes para lograr formato UTF-16LE
    |> Enum.flat_map(&[&1, 0])
    # Convertir de nuevo a binario
    |> :binary.list_to_bin()
    # Aplicar el hash MD4
    |> (&:crypto.hash(:md4, &1)).()
    # Codificar en hexadecimal mayúsculas
    |> Base.encode16(case: :upper)
  end
end

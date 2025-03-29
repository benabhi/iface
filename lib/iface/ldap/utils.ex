defmodule Iface.Ldap.Utils do
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
end

defmodule MsnrApi.Accounts.Password do
  import Pbkdf2
  def hash(password), do: hash_pwd_salt(password)
  def verify_with_hash(password, hash), do: verify_pass(password, hash)
end

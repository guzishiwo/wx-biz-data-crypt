defmodule WXBizDataCrypt do
  def unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end

  def aes_decrypt(data, key, init_iv) do
    padded = :crypto.block_decrypt(:aes_cbc128, key, init_iv, data)
    unpad(padded)
  end

  def decrypt(session_key, iv, encrpyt_data, app_id) do
    data =
      aes_decrypt(
        Base.decode64!(encrpyt_data),
        Base.decode64!(session_key),
        Base.decode64!(iv)
      )

    body = Jason.decode!(data)

    if body |> Map.get("watermark") |> Map.get("appid") != app_id do
      raise "Invalid Buffer"
    end

    body
  end
end

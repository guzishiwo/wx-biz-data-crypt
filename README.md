# 小程序数据解密算法 Elixir版

> 微信小程序官方文档—解密说明

> <http://mp.weixin.qq.com/debug/wxadoc/dev/api/signature.html?t=20161107>

### 使用方法

erlang 已经有现成的`crypto`算法包， elixir直接调用就行。

#### 1. 添加crypto的库

```elixir
# mix.exs
  def application do
    [
      extra_applications: [:crypto]
    ]
  end
```

#### 2. 解析json的库、添加依赖

```elixir
 # mix.exs
 defp deps do
    [{:jason, "~> 1.1"}]
  end
```

#### 3. 解析算法

   ```elixir
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
   ```

#### 4. 测试用例

```elixir
  test "wx_bizdata_crpyt" do
    key = "tiihtNczf5v6AKRyjwEUhQ=="
    data = "CiyLU1Aw2KjvrjMdj8YKliAjtP4gsMZMQmRzooG2xrDcvSnxIMXFufNstNGTyaGS9uT5geRa0W4oTOb1WT7fJlAC+oNPdbB+3hVbJSRgv+4lGOETKUQz6OYStslQ142dNCuabNPGBzlooOmB231qMM85d2/fV6ChevvXvQP8Hkue1poOFtnEtpyxVLW1zAo6/1Xx1COxFvrc2d7UL/lmHInNlxuacJXwu0fjpXfz/YqYzBIBzD6WUfTIF9GRHpOn/Hz7saL8xz+W//FRAUid1OksQaQx4CMs8LOddcQhULW4ucetDf96JcR3g0gfRK4PC7E/r7Z6xNrXd2UIeorGj5Ef7b1pJAYB6Y5anaHqZ9J6nKEBvB4DnNLIVWSgARns/8wR2SiRS7MNACwTyrGvt9ts8p12PKFdlqYTopNHR1Vf7XjfhQlVsAJdNiKdYmYVoKlaRv85IfVunYzO0IKXsyl7JCUjCpoG20f0a04COwfneQAGGwd5oa+T8yO5hzuyDb/XcxxmK01EpqOyuxINew=="
    iv = "r7BXXKkLb8qrSNn05n0qiA=="
    app_id = "wx4f4bc4dec97d474b"
    expected_data = %{
      "avatarUrl" => "http://wx.qlogo.cn/mmopen/vi_32/aSKcBBPpibyKNicHNTMM0qJVh8Kjgiak2AHWr8MHM4WgMEm7GFhsf8OYrySdbvAMvTsw3mo8ibKicsnfN5pRjl1p8HQ/0",
      "city" => "Guangzhou",
      "country" => "CN",
      "gender" => 1,
      "language" => "zh_CN",
      "nickName" => "Band",
      "openId" => "oGZUI0egBJY1zhBYw2KhdUfwVJJE",
      "province" => "Guangdong",
      "unionId" => "ocMvos6NjeKLIBqg5Mr9QjxrP1FA",
      "watermark" => %{
        "appid" => "wx4f4bc4dec97d474b",
        "timestamp" => 1477314187
      }
    }
    assert WXBizDataCrypt.decrypt(key, iv, data, app_id) == expected_data
  end
```


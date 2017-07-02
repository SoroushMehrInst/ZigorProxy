use Mix.Config

config :zigor_proxy, bindings: [
  {:sslcrypt, {192, 168, 1, 244}, 8082, 'origin', 443, 'pem file address', 'key file address', :mnmssl},
  {:zigcrypt, {192, 168, 1, 244}, 8442, 'origin', 901, :mnmzig}
]

config :logger, level: :debug

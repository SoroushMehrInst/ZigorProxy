# Zigor Proxy
[![Build Status](https://travis-ci.org/SoroushMehrInst/ZigorProxy.svg?branch=master)](https://travis-ci.org/SoroushMehrInst/ZigorProxy)

ZigorProxy is a highly scalable Zigor Protocole reverse proxy on Zigor packet level.
this proxy server can be used to load balance and maintain stability around zigor connections over TCP

## Configuration

Since zigor proxy is not maintained with package managers, it only can be used from building source code on your machine.

While building your code, you can provide your binding configs in config/config.exs (Or config/{Mix.env}.exs if you want to vary your test bindings from production bindings)

For configuring a binding in zigor_proxy (version < 0.2) you can use:
```elixir
  config :zigor_proxy, bindings: [{:zigcrypt, {192, 168, 100, 20}, 1234, 'realaddr.example.com', 1234, :unique_name}]

  # First argument of each binding is an atom determining what type of encryption should be used
  # Second and third arguments of each binding determines ip and port you wish proxy to run on
  # Fourth and fifth arguments of each binding determines the real zigor server to redirect user packets to
  # Sixth argument is the unique name of worker
```


## Deployment

ZigorProxy is deployed via ExRM and upgraded using Hot Code Upgrade even under load.

# Virtually Human Notifier

An app using this source code is up and running on Heroku.

## Api Endpoints:

### - Add new transaction:
```
https://vhs-notifier.herokuapp.com/addtx/?id=<ethereum-transaction-hash>
```

## - Get all transactions:
```
https://vhs-notifier.herokuapp.com/alltx
```

### Webhook:
```
https://vhs-notifier.herokuapp.com/webhook
```

Currently the status is pushed on slack webhook provided by VHS.



## Libraries Used

### Hex Dependencies:

```elixir
defp deps do
    [
      {:plug, "~> 1.6"},
      {:cowboy, "~> 2.4"},
      {:plug_cowboy, "~> 2.0"},   #  Plug & cowboy are used to provide api endpoints
      {:jason, "~> 1.2"}          #  To encode and decode json
    ]
end
```
### Erlang/OTP builtin libraries used:

```
mnesia - For storing process id and Hash
httpc - To make http requests
```

### Erlang and Elixir Version:

```
erlang_version=22.0   
elixir_version=1.9.1
```
import Config

config :logger, level: :warning

config :paddle, Paddle,
  host: "zmaster.policia.rionegro.gov.ar",
  base: "dc=vs-zmaster,dc=policia,dc=rionegro,dc=gov,dc=ar",
  ssl: false,
  port: 389,
  timeout: nil

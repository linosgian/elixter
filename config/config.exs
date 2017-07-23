# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :elixter,
  headers: [
      {"User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36
      (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"},
      {"Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,
      image/webp,*/*;q=0.8"},
      {"Accept-Language", "en-US,en;q=0.8"},
  ],
  engines: [
    Elixter.Enumerator.GoogleEnum,
  ],
  timeout: 25000
# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :elixter, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:elixter, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

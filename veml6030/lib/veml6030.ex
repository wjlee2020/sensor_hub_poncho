defmodule Veml6030 do
  @moduledoc """
  Top GenServer for VEML6030
  """

  use GenServer
  require Logger

  alias Veml6030.{Comm, Config}

  def init(%{address: address, i2c_bus_name: bus_name} = args) do
    i2c = Comm.open(bus_name)

    config =
      args
      |> Map.take([:gain, :int_time, :shutdown, :interrupt])
      |> Config.new()

    Comm.write_config(config, i2c, address)
    :timer.send_interval(1_000, :measure)

    state = %{
      i2c: i2c,
      address: address,
      config: config,
      last_reading: :no_reading
    }

    {:ok, state}
  end
end

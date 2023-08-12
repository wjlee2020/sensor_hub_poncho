defmodule Veml6030 do
  @moduledoc """
  Top GenServer for VEML6030
  """

  use GenServer
  require Logger

  alias Veml6030.{Comm, Config}

  def start_link(options \\ %{}) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

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

  def init(args) do
    {bus_name, address} = Comm.discover()
    transport = "bus: #{bus_name}, address: #{address}"

    Logger.info("Started VEML6030. Needs an address and a bus")
    Logger.info("Starting on " <> transport)

    defaults =
      args
      |> Map.put(:address, address)
      |> Map.put(:i2c_bus_name, bus_name)

    init(defaults)
  end

  def handle_info(:measure, %{i2c: i2c, address: address, config: config} = state) do
    last_reading = Comm.read(i2c, address, config)

    updated_with_reading = %{state | last_reading: last_reading}

    {:noreply, updated_with_reading}
  end

  def handle_call(:get_measurement, _from, state) do
    {:reply, state.last_reading, state}
  end

  # public
  def get_measurement do
    GenServer.call(__MODULE__, :get_measurement)
  end
end

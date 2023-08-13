defmodule SensorHub.Sensor do
  defstruct ~w(name fields read convert)a

  @bmp280_key ~w(altitude_m dew_point_c humidity_rh pressure_pa temperature_c)a
  @sgp40_key ~w(voc_index timestamp_ms)a

  def new(name) do
    %__MODULE__{
      read: read_fn(name),
      convert: convert_fn(name),
      fields: fields(name),
      name: name
    }
  end

  def fields(SGP40), do: SGP40.start_link(bus_name: "i2c-1")
  def fields(BMP280), do: [:altitude_m, :pressure_pa, :temperature_c]
  def fields(Veml6080), do: [:light_lumens]

  def read_fn(sgp), do: fn -> SGP40.measure(sgp) end
  def read_fn(BMP280), do: fn -> BMP280.measure(BMP280) end
  def read_fn(Veml6080), do: fn -> Veml6080.get_measurement() end

  def convert_fn(SGP40) do
    fn reading ->
      Map.take(reading, [:voc_index, :timestamp_ms])
    end
  end

  def convert_fn(BMP280) do
    fn reading ->
      case reading do
        {:ok, measurement} ->
          Map.take(measurement, [:altitude_m, :pressure_pa, :temperature_c])

        _ ->
          %{}
      end
    end
  end

  def convert_fn(Veml6080) do
    fn data -> %{light_lumens: data} end
  end

  def convert({:ok, sgp40_measurement}) do
    sgp40_measurement
    |> Map.take(@sgp40_key)
  end

  def measure(sensor = %SensorHub.Sensor{}) do
    sensor.read.()
    |> sensor.convert.()
  end

  def measure(sensor_pid) do
    read_fn(sensor_pid).()
    |> convert()
  end
end

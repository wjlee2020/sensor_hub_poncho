defmodule SensorHub.Sensor do
  defstruct ~w(name fields read convert)a

  @bmp280_key ~w(altitude_m dew_point_c humidity_rh pressure_pa temperature_c)a
  @sgp40_key ~w(voc_index timestamp_ms)a
  @veml6030_key ~w(light_lumens)a

  def new(name) when is_pid(name), do: name
  def new(name) do
    %__MODULE__{
      read: read_fn(name),
      convert: convert_fn(name),
      fields: fields(name),
      name: name
    }
  end

  def fields(SGP40), do: @sgp40_key
  def fields(BMP280), do: @bmp280_key
  def fields(Veml6030), do: @veml6030_key

  def read_fn(BMP280), do: fn -> BMP280.measure(BMP280) end
  def read_fn(Veml6030), do: fn -> Veml6030.get_measurement() end
  def read_fn(sgp), do: fn -> SGP40.measure(sgp) end

  def convert_fn(SGP40) do
    fn reading ->
      Map.take(reading, [:voc_index, :timestamp_ms])
    end
  end

  def convert_fn(BMP280) do
    fn reading ->
      case reading do
        {:ok, measurement} ->
          Map.take(measurement, @bmp280_key)

        _ ->
          %{}
      end
    end
  end

  def convert_fn(Veml6030) do
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

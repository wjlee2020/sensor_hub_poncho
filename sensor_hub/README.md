# SensorHub

## Getting Started

To start
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi3`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix burn`

SSH
```bash
ssh "nervessystem-NAME".local

# instead of burning, send via ssh
mix upload
```

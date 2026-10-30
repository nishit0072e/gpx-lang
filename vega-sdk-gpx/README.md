# VEGA RISC-V SDK for GPX (Guided Programming eXperience)

The official bare-metal RISC-V SDK port for the **GPX Programming Language**, targeting CDAC's **THEJAS32** microprocessor core and **ARIES v2.0** development boards.

With this SDK, developers can write high-performance embedded systems firmware directly in GPX instead of C/C++, taking advantage of GPX's clean, modern syntax, strong typing, pattern matching, and struct methods while compiling natively to bare-metal RISC-V ELF, binary, and Intel HEX firmware.

---

## Architecture Overview

- **Target Core:** THEJAS32 (CDAC Microprocessor Development Programme)
- **Instruction Set Architecture (ISA):** RISC-V `rv32im`
- **Application Binary Interface (ABI):** `ilp32`
- **Code Model:** `medany`
- **Linker Script:** `vega-sdk/bsp/common/mbl.lds`
- **Hardware Abstraction Layer (HAL):** `libvega.a`
- **Clock Frequency:** 100 MHz (`SYSTEM_FREQUENCY`)

---

## Directory Structure

```text
vega-sdk-gpx/
├── include/
│   └── vega/
│       ├── bsp.gpx          # Master umbrella header for all VEGA hardware
│       ├── config.gpx       # Peripheral base addresses and clock constants
│       ├── gpio.gpx         # GPIO read, write, toggle, and pin definitions (PIN_0..PIN_31)
│       ├── led.gpx          # On-board LED and RGB LED control APIs
│       ├── uart.gpx         # Serial communications (115200 baud, line & string transmitters)
│       ├── timer.gpx        # Hardware timers 0/1/2 delays and microsecond sleep (udelay, delay_ms)
│       ├── adc.gpx          # Analog-to-digital converter multi-channel sampling
│       ├── pwm.gpx          # Hardware PWM controller (frequency & duty-cycle modulation)
│       ├── i2c.gpx          # I2C master transceiver and device address probe
│       ├── spi.gpx          # SPI master bus controller and transfer primitives
│       └── interrupt.gpx    # Core interrupt enabling and vector handlers
├── common/
│   └── gpx_vega.mk          # Reusable Makefile rules linking GPX -> C -> RISC-V ELF -> BIN -> HEX
├── examples/
│   ├── gpio/
│   │   ├── led_toggle/      # Blinking on-board LED
│   │   ├── led_breathing/   # Smooth LED breathing via software PWM
│   │   ├── buzzer_demo/     # Musical tone frequency generation
│   │   └── gpio_write_read/ # Digital switches and multi-pin I/O
│   ├── uart/
│   │   ├── hello_world/     # Startup serial banner over UART0
│   │   └── uart_tx_rx/      # Bidirectional character & string TX/RX
│   ├── timer/
│   │   └── timer_sample/    # Hardware timers 0/1/2 polling delays
│   ├── adc/
│   │   └── adc_demo/        # Analog voltage reading across channels
│   ├── pwm/
│   │   └── pwm_led_brightness/ # Hardware PWMC controller brightness fading
│   ├── i2c/
│   │   └── i2c_scanner/     # 7-bit bus discovery for I2C devices
│   ├── spi/
│   │   └── spi_demo/        # SPI command packets and display init
│   └── interrupt/
│       └── software_interrupt/ # Software interrupt triggering and handlers
├── build_all.py             # Automated verification runner building all 12 projects
└── README.md                # SDK documentation
```

---

## Building Example Programs

Each example program contains a minimal `Makefile`:

```makefile
EXECUTABLE_NAME = led_toggle
include ../../../common/gpx_vega.mk
```

To compile, link, and generate firmware artifacts:

```bash
cd vega-sdk-gpx/examples/gpio/led_toggle
make clean all
```

### Build Artifacts Generated

In the `build/` directory of each example:
- `*.c`: Clean C99 bare-metal transpiled source
- `*.o`: RISC-V `rv32im` object file
- `*.elf`: Fully linked 32-bit RISC-V ELF executable
- `*.bin`: Raw flashable binary image (flashable over UART via xmodem/minicom)
- `*.hex`: Intel HEX file for memory programmers
- `*.dump`: Complete annotated RISC-V disassembly listing with symbol offsets
- `*.map`: Linker section and symbol allocation memory map

---

## Automated Test Verification

Run the automated test runner to build and verify all 12 peripheral examples across the entire SDK:

```bash
python vega-sdk-gpx/build_all.py
```

### Test Output

```text
====================================================================
      VEGA RISC-V SDK (GPX Port) - Automated Build Test Suite       
 Found 12 Example Projects across Peripherals
====================================================================
  [PASS]  adc\adc_demo                            31,808 B
  [PASS]  gpio\buzzer_demo                        32,544 B
  [PASS]  gpio\gpio_write_read                    32,544 B
  [PASS]  gpio\led_breathing                      31,896 B
  [PASS]  gpio\led_toggle                         27,520 B
  [PASS]  i2c\i2c_scanner                         31,216 B
  [PASS]  interrupt\software_interrupt            30,448 B
  [PASS]  pwm\pwm_led_brightness                  31,808 B
  [PASS]  spi\spi_demo                            32,000 B
  [PASS]  timer\timer_sample                      31,272 B
  [PASS]  uart\hello_world                        31,072 B
  [PASS]  uart\uart_tx_rx                         46,232 B
--------------------------------------------------------------------
  Total: 12 | Passed: 12 | Failed: 0
====================================================================
```

---

## GPX Code Example: Blinking LED

```gpx
#include <vega/led.gpx>
#include <vega/timer.gpx>

fn main() -> int {
    print("--- GPX LED Toggle Demo Starting on VEGA Processor ---");

    let led_pin = PIN_31;
    let count = 0;

    while count < 5 {
        on_LED(led_pin);
        print("LED Status: ON");
        udelay(250000); // 250 ms delay

        off_LED(led_pin);
        print("LED Status: OFF");
        udelay(250000);

        count = count + 1;
    }

    print("--- GPX LED Toggle Demo Completed Successfully ---");
    return 0;
}
```

---

## Peripheral API Reference

### GPIO & LED (`<vega/gpio.gpx>`, `<vega/led.gpx>`)
- `GPIO_write_pin(pin: int, data: int)`: Write logic level (`HIGH` or `LOW`) to GPIO pin
- `GPIO_read_pin(pin: int) -> int`: Read digital input state from GPIO pin
- `gpio_set_high(pin: int)` / `gpio_set_low(pin: int)` / `gpio_toggle(pin: int)`: High-level pin controls
- `on_LED(pin: int)` / `off_LED(pin: int)`: Control on-board LEDs
- `on_LED_RGB(pin: int)` / `off_LED_RGB(pin: int)`: Control multi-color RGB LEDs
- `read_switch(pin: int) -> int`: Read user tactile push-buttons

### UART Serial (`<vega/uart.gpx>`)
- `uart_init(uart_no: int)`: Initialize UART channel (0, 1, or 2)
- `uart_set_baud_rate(uart_no: int, baud: int, clk: int)`: Configure baud rate (9600, 115200, etc.)
- `uart_putchar(uart_no: int, ch: char, err: *char)`: Transmit single byte
- `uart_getchar(uart_no: int, err: *char) -> char`: Receive byte (blocking)
- `uart_write_string(uart_no: int, msg: string)`: Transmit complete string buffer
- `uart_write_line(uart_no: int, msg: string)`: Transmit line with `\r\n` terminator

### Timers & Delays (`<vega/timer.gpx>`)
- `udelay(us: int)`: Accurate microsecond delay loop
- `delay_ms(ms: int)`: Millisecond delay loop
- `timer_put_delay(timer_no: int, clocks: int) -> int`: Polling hardware timer delay
- `timer_load(timer_no: int, count: int)`: Load hardware timer counter

### PWMC (`<vega/pwm.gpx>`)
- `PWMC_init(channel: int, mode: int, align: int, intr: int, opc: int, count: int)`: Configure hardware PWMC
- `PWMC_Set_Period(channel: int, period: int)`: Set PWM carrier period
- `PWMC_Set_OnOffTime(channel: int, on_off: int)`: Set active pulse duty cycle
- `PWMC_Enable()` / `PWMC_Disable()`: Start/stop hardware PWM generation

### I2C & SPI (`<vega/i2c.gpx>`, `<vega/spi.gpx>`)
- `i2c_initialize(i2c_no: int)`: Initialize I2C bus controller
- `i2c_start(i2c_no: int, len: int, is_read: int) -> int`: Initiate I2C communication frame
- `i2c_stop(i2c_no: int)`: Generate I2C stop condition
- `SPI_init(spi_no: int)`: Initialize SPI controller
- `SPI_transmit(spi_no: int, data: int)`: Transmit byte over SPI bus
- `SPI_wait_if_busy(spi_no: int)`: Wait until SPI transfer shift registers flush

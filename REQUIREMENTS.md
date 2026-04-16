# 1. Project Context

- Target SoC: Zynq-7020
- Target board: Digilent PYNQ-Z1
- Software tools: Vivado 2024.1

# 2. Goal

Demonstrate PS–PL cooperation:

- **PS**: UDP reception + parsing + counters
- **PL**: detect counter changes + generate LED blink timing

Reusable later for ABS-related project.

# 3. Functional Requirements

## UDP + Parsing (PS)

- Listen on configurable UDP port.
- Receive UDP packets (no filtering required).
- Parse packets:
	- Valid format (initial): `pynq.label=123`
	- Otherwise → error
- Parser must be modular:
	- `parse_ascii(...)`
	- `parse_binary(...)` (placeholder)
	- Easy switch between them

## Counters (PS)

- Maintain two counters:
	- `success_count`
	- `error_count`
- Per packet:
	- Valid → increment `success_count`
	- Invalid → increment `error_count`
- 32-bit wraparound is OK.

## PS → PL Interface

- Expose both counters to PL.
- Simple memory-mapped interface (AXI Lite preferred).
- PL reads counters (no event signaling needed).

## LED Logic (PL)

- Two independent channels:
	- Success LED
	- Error LED
- Behavior per counter:
	- Detect change of counter value.
	- On change:
		- LED ON for 50 ms
		- Then OFF for 50 ms
- Constraints:
	- Max visible blink rate: 10 Hz
	- Multiple updates during one cycle must **NOT** increase blink rate (coalesce events)
	- Timing must be implemented in PL (not PS)

# 4. Architecture Constraints

- Clear separation:
	- UDP / parsing / counters (PS)
	- Event detection + timing (PL)
- Parser must be replaceable (ASCII → binary later).
- Use simple, readable design (learning-focused, not optimized).

# 5. Acceptance Criteria

- Sending `pynq.label=123`:
	- Success counter increments
	- Success LED blinks
- Sending invalid message:
	- Error counter increments
	- Error LED blinks
- High packet rate:
	- LEDs do **NOT** exceed 10 Hz blinking
- Both LEDs operate independently.

# 6. Out of Scope (for now)

- Binary protocol implementation
- CRC/checksum
- Real-time guarantees
- Packet forwarding to PL
- Interrupts / DMA optimizations

# 7. Optional (nice-to-have)

- Debug print of parsed packets (PS)
- Ability to read counters from PS
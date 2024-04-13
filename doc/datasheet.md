## Datasheet

### Overview
The `rtc(real time clock)` IP is a fully parameterised soft IP to generate the real-time clock. The IP features an APB4 slave interface, fully compliant with the AMBA APB Protocol Specification v2.0.

### Feature
* Programmable prescaler
    * max division factor is up to 2^20
    * can be changed ongoing
* 32-bit programmable counter up rtc counter and alarm register
* Register write-protected support
* Register read-resynchronized support
* Three maskable interrupt
    * second interrupt
    * overflow interrupt
    * alarm interrupt
* Static synchronous design
* Full synthesizable

### Interface
| port name | type        | description          |
|:--------- |:------------|:---------------------|
| apb4      | interface   | apb4 slave interface |
| rtc ->    | interface   | rtc slave interface |
| `rtc.rtc_clk_i` | input | rtc low speed clock input |
| `rtc.rtc_rst_n_i` | input | rtc reset input |

### Register

| name | offset  | length | description |
|:----:|:-------:|:-----: | :---------: |
| [CTRL](#control-register) | 0x0 | 4 | control register |
| [PSCR](#prescaler-register) | 0x4 | 4 | prescaler register |
| [CNT](#cnt-reigster) | 0x8 | 4 | counter register |
| [ALRM](#alarm-reigster) | 0xC | 4 | alarm register |
| [ISTA](#interrupt-state-reigster) | 0x10 | 4 | interrupt state register |
| [SSTA](#system-state-reigster) | 0x14 | 4 | system state register |

#### Control Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:5]` | none | reserved |
| `[4:4]` | RW | EN |
| `[3:3]` | RW | OVIE |
| `[2:2]` | RW | ALRMIE |
| `[1:1]` | RW | SCIE |
| `[0:0]` | RW | CMF |

reset value: `0x0000_0000`

* EN: the enable signal for seed register writing operation.
    * `EN = 1'b0`: writing seed register disabled
    * `EN = 1'b1`: writing seed register enabled

#### Prescaler Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:20]` | none | reserved |
| `[19:0]` | RW | PSCR |

reset value: `0x0000_0000`

* PSCR: the 32-bit initial random seed value.

#### Cnt Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | RW | CNT |

reset value: `0x0000_0000`

* VAL: the 32-bit generated random number.

#### Alarm Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | RW | ALRM |

reset value: `0x0000_0000`

* VAL: the 32-bit generated random number.

#### Interrupt State Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:3]` | none | reserved |
| `[2:2]` | RC_W0 | OVIF |
| `[1:1]` | RC_W0 | ALRMIF |
| `[0:0]` | RC_W0 | SCIF |

reset value: `0x0000_0000`

* VAL: the 32-bit generated random number.

#### System State Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:2]` | none | reserved |
| `[1:1]` | RO | LWOFF |
| `[0:0]` | RO | RSYNF |


reset value: `0x0000_0000`

* VAL: the 32-bit generated random number.

### Program Guide
The software operation of `rtc` is simple. These registers can be accessed by 4-byte aligned read and write. All operation can be split into **initialization and read operation**. C-like pseudocode for the initialization operation:
```c
rtc.CTRL.EN = 1        // enable the seed register writing
rtc.SEED = SEED_32_bit // write seed value
```
read operation:
```c
uint32_t val = rtc.VAL // get the random number
```

If wanting to stop generating valid random numbers, software need to set the value of seed register to zero:
```c
rtc.SEED = 0x0
```
### Resoureces
### References
### Revision History
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
| [CNT](#counter-reigster) | 0x8 | 4 | counter register |
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

* EN: the enable signal for rtc counting mode
    * `EN = 1'b0`: rtc counting disabled
    * `EN = 1'b1`: rtc counting enabled

* OVIE: the enable signal of overflow interrupt
    * `OVIE = 1'b0`: overflow interrupt disabled
    * `OVIE = 1'b1`: overflow interrupt enabled

* ALRMIE: the enable signal of alarm interrupt
    * `ALRMIE = 1'b0`: alarm interrupt disabled
    * `ALRMIE = 1'b1`: alarm interrupt enabled

* SCIE: the enable signal of second interrupt
    * `SCIE = 1'b0`: second interrupt disabled
    * `SCIE = 1'b1`: second interrupt enabled

* CMF: the configure mode flag
    * `CMF = 1'b0`: exit the configuare mode
    * `CMF = 1'b1`: enter the configuare mode

#### Prescaler Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:20]` | none | reserved |
| `[19:0]` | RW | PSCR |

reset value: `0x0000_0002`

* PSCR: the 20-bit prescaler value

#### Counter Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | RW | CNT |

reset value: `0x0000_0000`

* CNT: the 32-bit programmable counter

#### Alarm Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | RW | ALRM |

reset value: `0x0000_0000`

* ALRM: the 32-bit alarm register

#### Interrupt State Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:3]` | none | reserved |
| `[2:2]` | RC_W0 | OVIF |
| `[1:1]` | RC_W0 | ALRMIF |
| `[0:0]` | RC_W0 | SCIF |

reset value: `0x0000_0000`

* OVIF: the trigger flag of overflow interrupt
    * `OVIF = 1'b0`: overflow interrupt flag no trigger
    * `OVIF = 1'b1`: overflow interrupt flag trigger

* ALRMIF: the trigger flag of alarm interrupt
    * `ALRMIF = 1'b0`: alarm interrupt flag no trigger
    * `ALRMIF = 1'b1`: alarm interrupt flag trigger

* SCIF: the trigger flag of second interrupt
    * `SCIF = 1'b0`: second interrupt flag no trigger
    * `SCIF = 1'b1`: second interrupt flag trigger

#### System State Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:2]` | none | reserved |
| `[1:1]` | RO | LWOFF |
| `[0:0]` | RO | RSYNF |

reset value: `0x0000_0000`

* LWOFF: the last write operation finished flag
* RSYNF: the registers synchronized flag

### Program Guide
These registers can be accessed by 4-byte aligned read and write. C-like pseudocode:

init operation:
```c
rtc.CTRL.CMF = 1       // enable the config mode
rtc.PSCR = PSCR_32_bit // set the pscr value
rtc.CNT = CNT_32_bit   // set the init counter value
rtc.CTRL.CMF = 0       // disable the config mode
rtc.CTRL.[EN, OVIE, ALRMIE, SCIE] = 1 // enable counter and interrupt
```
read operation:
```c
uint32_t val = rtc.CNT // get the cnt value
```
### Resoureces
### References
### Revision History
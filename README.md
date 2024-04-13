# RTC

## Features
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

FULL vision of datatsheet can be found in [datasheet.md](./doc/datasheet.md).

## Build and Test
```bash
make comp    # compile code with vcs
make run     # compile and run test with vcs
make wave    # open fsdb format waveform with verdi
```
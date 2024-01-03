# RTC

## Features
* Max Programmable prescaler division factor is up to 2^20
* 32-bit programmable rtc counter and alarm register
* Register write-protected support
* Register read-resynchronized support
* Three maskable interrupt: second, overflow and alarm interrupt
* Static synchronous design
* Full synthesizable

## Build and Test
```bash
make comp    # compile code with vcs
make run     # run test with vcs
make wave    # open fsdb format waveform with verdi
```
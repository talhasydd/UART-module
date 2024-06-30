# UART MODULE

This repository contains VHDL code for a UART (Universal Asynchronous Receiver/Transmitter) communication system. The project includes components for both the UART transmitter and receiver, along with supporting modules like a baud rate clock generator and a top-level module to integrate the system. The purpose of this module is to receive data from the PC and echo it directly back with the transmitter.

## Project Structure

- UARTreceiver.vhd: Implements the UART receiver module, which handles the reception of serial data, including start, data, and stop bits.
- UARTtransmitter.vhd: Implements the UART transmitter module, which handles the transmission of serial data, including start, data, and stop bits.
- BaudclkGenerator.vhd: Generates a baud rate clock signal used by both the transmitter and receiver modules.
- TopLevelModule.vhd: Integrates the UART transmitter and receiver into a single module for full-duplex communication.
- BasicSR.vhd: Implements a basic shift register used in the receiver module.
- serializer.vhd: Implements a serializer used in the transmitter module.
- Sync.vhd: Synchronizes the asynchronous input to the system clock.

## Baud Rate and RS232 Protocol
The system is designed to communicate using the RS232 protocol, a standard for serial communication transmission of data.

The baud rate determines the speed of data transmission and reception. In this project, the default baud rate is set to 115200 baud, which is configurable through the generic parameters.

## Description

### UART Receiver (UARTreceiver.vhd)
The receiver module handles the asynchronous reception of serial data. It uses the following key components:

- Sync: Synchronizes the asynchronous RS232 input to the system clock.
- BaudclkGenerator: Generates a clock signal at the baud rate for data sampling.
- BasicSR: A shift register that collects received data bits.
- State Machine: Controls the reception process, detects start bits, collects data bits, and signals when data is ready.

### UART Transmitter (UARTtransmitter.vhd)
The transmitter module handles the asynchronous transmission of serial data. Key components include:

- serializer: Converts parallel data into a serial data stream.
- BaudclkGenerator: Generates a clock signal at the baud rate for data transmission.

### Baud Rate Clock Generator (BaudclkGenerator.vhd)
Generates the baud rate clock signal required for both transmission and reception. The clock generator includes:

- Period Counter: Manages the timing to generate the baud clock.
- Clock Counter: Keeps track of the number of bits to transmit/receive.
- Ready Signal: Indicates when the clock generator is ready for a new operation.

### Top-Level Module (TopLevelModule.vhd)
Integrates the transmitter and receiver modules into a single top-level module, allowing for full-duplex communication. The top-level module manages the overall communication process, including:

- State Machine: Controls the data flow between the transmitter and receiver.
- Signal Mapping: Connects the various sub-modules and handles the RS232 interface.


## Acknowledgements 

- Xilinx Vivado Design Suite
- L Athukorala on Udemy for code idea.

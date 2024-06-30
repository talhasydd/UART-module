# UART MODULE

A UART transmitter and receiver for serial communication is implemented here. The module handles a start and stop bit too. The purpose of this module is to receive data from the PC and echo it directly back with the transmitter.

## Baud clock generator

The RS232 protocol interface uses an asynchronous method. That means that no clock signal is transmitted along the data. The receiver has to have a way to "time" itself to the incoming data bits. This is done with the Baud clock generator, the speed used is 115200 bauds.

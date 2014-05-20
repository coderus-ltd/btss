# Bluetooth Signal Sampler CLI (BTSS)


#### Description
BTSS is a command line tool to scan the received signal strength indication (rssi) of paired Bluetooth devices.


#### Usage 
For a list of all available options run `./btss -h`:

```
$ ./btss -h

         Usage: btss -h
                btss -l
                btss -c <device_name> [-s <sleep_time>] [-n <number_of_reads>]
                
         -h                    Help
         -l                    Lists all paired devices
         -c <device_name>      Connect to a device with name
         -s <sleep_time>       Milliseconds to sleep before a new rssi read
```

### License
MIT
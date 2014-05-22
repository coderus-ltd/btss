# Bluetooth Signal Sampler CLI (BTSS)


#### Description
BTSS is a command line tool to scan the received signal strength indication (rssi) of paired Bluetooth devices.


#### Usage 
For a list of all available options run `./btss -h`:

```
$ ./btss -h

	Usage: btss -h
		   btss -l
		   btss -c <device_name> [-s <num_reads_per_second>] [-t <time_duration>]
		   
    -h                          Help
    -l                          Lists all paired devices
    -c <device_name>            Connect to a device with name
    -s <num_reads_per_second>   Number of rssi reads per second
    -t <time_duration>          Total duration of rssi reads in seconds
```

#### Return Codes
The cli tool has in place exit return codes:
```
	0		Success
   -1		Invalid Options/Invalid Parameters
```

### License
MIT
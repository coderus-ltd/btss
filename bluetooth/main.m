//
//  main.m
//  btss
//
//  Created by Coderus on 19/05/2014.
//  Copyright (c) 2014 Coderus. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

int printHelp(int argc, const char * argv[]);
int scanDevice(int argc, const char * argv[]);
int listDevices(int argc, const char * argv[]);

int main(int argc, const char * argv[])
{
  if(argc < 2) {
    printHelp(argc, argv);
    return 0;
  }
  
  NSString *arg = [[NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding] lowercaseString];
  NSArray *items = @[@"-h", @"-c", @"-l"];
  int item = [items containsObject:arg] ? (int) [items indexOfObject:arg] : -1;
  
  int code = -1;
  switch (item) {
    case 0:
      code = printHelp(argc, argv);
      break;
    case 1:
      code = scanDevice(argc, argv);
      break;
    case 2:
      code = listDevices(argc, argv);
      break;
    default:
      NSLog(@"Invalid args");
      break;
  }
  
  return code;
}

int scanDevice(int argc, const char * argv[]) {
  //default values
  NSString *deviceName = nil;
  int numReadsPerSecond = 0;
  int timeDuration = 0;
  
  //-c <device_name> [-s <sleep_time>] [-n <number_of_rssi_values>]
  if(argc <= 2 || argc % 2 == 0) {
    NSLog(@"Invalid Params");
    return -1;
  }
  
  //read out params
  for (int i = 1; i < argc; i+=2) {
    NSString *paramName = [NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding];
    NSString *paramValue = [NSString stringWithCString:argv[i + 1] encoding:NSUTF8StringEncoding];
    
    //read device name
    if([paramName isEqualToString:@"-c"] && i == 1) {
      deviceName = paramValue;
    }
    
    //number of sample reads per second
    if([paramName isEqualToString:@"-s"]) {
      int aNumReads = [paramValue intValue];
      numReadsPerSecond = aNumReads > 0 ? aNumReads : 0;
    }
    
    //Duration of rssi sample read in seconds
    if([paramName isEqualToString:@"-t"]) {
      int aTimeDuration = [paramValue intValue];
      timeDuration = (aTimeDuration > 0 ? aTimeDuration : 0);
    }
  }
  
  NSLog(@"%@", deviceName);
  
  @autoreleasepool
  {

    NSArray *theArray = [IOBluetoothDevice pairedDevices];
    if ([theArray count])
    {
      IOBluetoothDevice *device = nil;
      for (IOBluetoothDevice *aDevice in theArray)
      {
        NSString *dName = [aDevice name];
        if ([dName isEqualToString:deviceName])
        {
          device = aDevice;
          break;
        }
      }
      
      if(device == nil) {
        NSLog(@"Device not found");
        return -1;
      }
      
      int totalReads = 0;
      float sleepTime = 0.0f;
      
      //setup while vars
      if(numReadsPerSecond > 0 && timeDuration > 0) { //numReadsPerSecond and timeDuration set
        totalReads = numReadsPerSecond * timeDuration;
        sleepTime = 1.0f / numReadsPerSecond;
      } else if(numReadsPerSecond > 0 && timeDuration == 0) { //numReadsPerSecond set
        totalReads = 0;
        sleepTime = 1.0f / numReadsPerSecond;
      }
      
      NSLog(@"Scanning...");
      NSLog(@"Name    :%@", deviceName );
      NSLog(@"Address :%@", IOBluetoothNSStringFromDeviceAddress( [device getAddress] ) );
      
      int countReads = 0;
      while ([device isConnected])
      {
        NSLog(@"rssi %d - raw rssi %d", [device RSSI], [device rawRSSI]);
        
        if(sleepTime > 0.0f) { //
          [NSThread sleepForTimeInterval:sleepTime];
        }
        
        countReads++;
        if(totalReads > 0) {
          if(countReads == totalReads) {
            break;
          }
        }
      }
    }
  }
  
  return 0;
}

int listDevices(int argc, const char * argv[]) {
  @autoreleasepool
  {
    NSArray *theArray = [IOBluetoothDevice pairedDevices];
    if ([theArray count])
    {
      for ( IOBluetoothDevice *device in theArray)
      {
        NSLog(@"Device: %@       Address: %@", [device name], IOBluetoothNSStringFromDeviceAddress( [device getAddress] ));
      }
    } else {
      NSLog(@"No Devices Paired");
    }
  }
  
  return 0;
}

int printHelp(int argc, const char * argv[]) {
  NSString *name = [NSProcessInfo.processInfo.arguments[0] lastPathComponent];
  
  NSLog(@"\n");
  NSLog(@"Usage: %@ -h", name);
  NSLog(@"       %@ -l", name);
  NSLog(@"       %@ -c <device_name> [-s <num_reads_per_second>] [-t <time_duration>]", name);
  
  NSLog(@"\n");
  NSLog(@"-h                          Help");
  NSLog(@"-l                          Lists all paired devices");
  NSLog(@"-c <device_name>            Connect to a device with name");
  NSLog(@"-s <num_reads_per_second>   Number of rssi reads per second");
  NSLog(@"-t <time_duration>          Total duration of rssi reads in seconds");
  
  return 0;
}
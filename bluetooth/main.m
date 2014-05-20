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
  NSInteger sleepTime = 0;
  NSInteger numRssiValues = 0;
  
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
    
    //read number of rssi scans if available
    if([paramName isEqualToString:@"-n"]) {
      int aNumRssi = [paramValue intValue];
      numRssiValues = (aNumRssi > 0 ? aNumRssi : 0);
    }
    
    //read sleep time if available
    if([paramName isEqualToString:@"-s"]) {
      int aSleepValue = [paramValue intValue];
      sleepTime = aSleepValue > 0 ? aSleepValue : 0;
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

      NSLog(@"Scanning...");
      NSLog(@"Name    :%@", deviceName );
      NSLog(@"Address :%@", IOBluetoothNSStringFromDeviceAddress( [device getAddress] ) );
      
      int rssiReads = 0;
      while ([device isConnected])
      {
        NSLog(@" rssi %d - raw rssi %d", [device RSSI], [device rawRSSI]);
        
        if(sleepTime > 0) {
          [NSThread sleepForTimeInterval: 0.001 * sleepTime];
        }
        
        if(numRssiValues > 0) {
          if(++rssiReads == numRssiValues) {
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
  
  NSLog(@"Usage: %@ -h", name);
  NSLog(@"       %@ -l", name);
  NSLog(@"       %@ -c <device_name> [-s <sleep_time>] [-n <number_of_reads>]", name);

  
  NSLog(@"\n");
  NSLog(@"-h                    Help");
  NSLog(@"-c <device_name>      Connect to a device with name");
  NSLog(@"-s <sleep_time>       Milliseconds to sleep before a new rssi read");
  NSLog(@"-l                    Lists all paired devices");
  
  return 0;
}
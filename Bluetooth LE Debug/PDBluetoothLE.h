#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PDBluetoothLE : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

- (void)startBluetoothLE;

@end

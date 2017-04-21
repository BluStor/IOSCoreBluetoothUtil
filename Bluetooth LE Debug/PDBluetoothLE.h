#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PDBluetoothLE : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

- (void)startBluetoothLE:(NSNumber *) cmd;
- (void)sendCommand:(int) cmd;

@end

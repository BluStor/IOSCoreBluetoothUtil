#import "PDBluetoothLE.h"

@interface PDBluetoothLE()

@property CBCentralManager *myCentralManager;
@property CBUUID *blustorServiceUUID;
@property CBUUID *blustorControlPointUUID;
@property CBUUID *blustorFileWriteUUID;
@property NSArray *serviceArraySearch;
@property CBPeripheral *blustorPeripheral;
@property CBCharacteristic *blustorFileWriteCharacteristic;
@property CBCharacteristic *blustorControlPointCharacteristic;

@end

@implementation PDBluetoothLE

- (void)startBluetoothLE
{
    self.blustorServiceUUID = [CBUUID UUIDWithString: @"423AD87A-B100-4F14-9EAA-5EB5839F2A54"];
    self.serviceArraySearch = @[self.blustorServiceUUID];
    
    self.blustorControlPointUUID = [CBUUID UUIDWithString:@"423AD87A-0001-4F14-9EAA-5EB5839F2A54"];
    self.blustorFileWriteUUID = [CBUUID UUIDWithString:@"423AD87A-0002-4F14-9EAA-5EB5839F2A54"];
    
    self.myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOff){
        NSLog(@"BLE OFF");
    } else if (central.state == CBCentralManagerStatePoweredOn){
        NSLog(@"BLE ON");

        [self.myCentralManager scanForPeripheralsWithServices:self.serviceArraySearch options:nil];
    } else if (central.state == CBCentralManagerStateUnknown){
        NSLog(@"NOT RECOGNIZED");
    } else if(central.state == CBCentralManagerStateUnsupported){
        NSLog(@"BLE NOT SUPPORTED");
    } else if (central.state == CBCentralManagerStateUnauthorized){
        NSLog(@"BLE UNAUTHORIZED");
    } else if (central.state == CBCentralManagerStateResetting){
        NSLog(@"BLE RESETTING");
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    NSLog(@"Cybergate Card found");

    self.blustorPeripheral = peripheral;
    self.blustorPeripheral.delegate = self;
    
    [self.myCentralManager connectPeripheral:self.blustorPeripheral options:nil];
    [self.myCentralManager stopScan];
    NSLog(@"Scanning stopped");
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral connected.");
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central
  didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(nullable NSError *)error
{
    NSLog(@"Peripheral disconnected.");
    [self.myCentralManager scanForPeripheralsWithServices:self.serviceArraySearch options:nil];
}

- (void)peripheral:(CBPeripheral *)peripheral
    didDiscoverServices:(NSError *)error
{
    NSLog(@"Discovered services.");
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service);
        if([service.UUID isEqual:self.blustorServiceUUID]) {
            NSLog(@"Found BluStor service");
            NSLog(@"Discovering characteristics for service %@", service);
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
    didDiscoverCharacteristicsForService:(CBService *)service
                                    error:(NSError *)error
{
    //unsigned char command[] = {0x01};
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"small" ofType:@"txt"];
    unsigned char command3[] = {0x03};
    unsigned char command4[] = {0x04};
    unsigned char command1[] = {0x01};
    unsigned char hello[] = {72, 101, 108, 108, 111};
    unsigned int i = 0;
    NSString *thePath = @"/Users/jacksonkeating/Downloads/smaller.txt";
    NSLog(@"Found characteristic.");
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@", characteristic);
        if([characteristic.UUID isEqual:self.blustorControlPointUUID]){
            self.blustorControlPointCharacteristic = characteristic;
        } else if([characteristic.UUID isEqual:self.blustorFileWriteUUID]){
            self.blustorFileWriteCharacteristic = characteristic;
        }
    }
    [peripheral writeValue:[NSData dataWithBytes:command3 length:1] forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
    //while(i < 10000){
        [peripheral writeValue:[NSData dataWithContentsOfFile:thePath] forCharacteristic:self.blustorFileWriteCharacteristic type:CBCharacteristicWriteWithoutResponse];
      //  i+=20;
    //}
    [peripheral writeValue:[NSData dataWithBytes:command4 length:1] forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
    [peripheral writeValue:[NSData dataWithBytes:command1 length:1] forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
    //NSLog(@"Reading value for characteristic %@", service.characteristics[0]);
    //[peripheral readValueForCharacteristic:service.characteristics[0]];
    //NSLog(@"Cancelling connection");
    //[self.myCentralManager cancelPeripheralConnection:peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
                        error:(NSError *)error
{
    NSData *data = characteristic.value;
    NSLog(@"Discovered value %@", data);
}

@end
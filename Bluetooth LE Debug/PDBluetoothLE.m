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
@property NSDate *startTime;
@property NSNumber *app_command;

@end

@implementation PDBluetoothLE

- (void)startBluetoothLE:(NSNumber *)cmd
{
    self.app_command = cmd;
    self.blustorServiceUUID = [CBUUID UUIDWithString: @"423AD87A-B100-4F14-9EAA-5EB5839F2A54"];
    self.serviceArraySearch = @[self.blustorServiceUUID];
    
    self.blustorControlPointUUID = [CBUUID UUIDWithString:@"423AD87A-0001-4F14-9EAA-5EB5839F2A54"];
    self.blustorFileWriteUUID = [CBUUID UUIDWithString:@"423AD87A-0002-4F14-9EAA-5EB5839F2A54"];
    
    self.myCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)sendCommand:(int) cmd
{
    unsigned char command83[] = {0x08};
    unsigned char command6[] = {0x06};  // Connection settings: high speed
    unsigned char command5[] = {0x05};  // Connection settings: low power
    unsigned char command3[] = {0x03};
    unsigned char command4[] = {0x04};
    unsigned char command2[] = {0x02};
    unsigned char command1[] = {0x01};
    unsigned char filepath[] = "/data/hello.txt";
    unsigned char filepath_length = sizeof(filepath);
    unsigned char conn_interval_cmd_len = 2;
    unsigned char conn_interval[] = {8, 8};
    unsigned char hello[] = "hellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohello";
    unsigned int i = 0;
    
    NSMutableData *command_download = [NSMutableData dataWithBytes:command2 length:1];
    [command_download appendBytes:&filepath_length length:1];
    [command_download appendBytes:filepath length:filepath_length];
    
    NSMutableData *command_delete = [NSMutableData dataWithBytes:command8 length:1];
    [command_delete appendBytes:&filepath_length length:1];
    [command_delete appendBytes:filepath length:filepath_length];
    
    NSMutableData *command_upload = [NSMutableData dataWithBytes:command3 length:1];
    [command_upload appendBytes:&filepath_length length:1];
    [command_upload appendBytes:filepath length:filepath_length];
    
    NSMutableData *command_conn_interval = [NSMutableData dataWithBytes:command6 length:1];
    [command_conn_interval appendBytes:&conn_interval_cmd_len length:1];
    [command_conn_interval appendBytes:conn_interval length:conn_interval_cmd_len];
    
    if(self.blustorPeripheral.state == 2)
    {
        if(cmd == 1)
        {
            NSLog(@"Read to start pairing");
            [self.blustorPeripheral readValueForCharacteristic:self.blustorControlPointCharacteristic];
        }
        else if(cmd == 2)
        {
            NSLog(@"Download filepath");
            [self.blustorPeripheral setNotifyValue:YES forCharacteristic:self.blustorControlPointCharacteristic];
            [self.blustorPeripheral writeValue:command_download forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if(cmd == 3)
        {
            NSLog(@"Upload to filepath");
            [self.blustorPeripheral writeValue:command_conn_interval forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
            [self.blustorPeripheral writeValue:command_upload forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
            self.startTime = [NSDate date];
            while(i < 5000){
                [self.blustorPeripheral writeValue:[NSData dataWithBytes:hello length:sizeof(hello)] forCharacteristic:self.blustorFileWriteCharacteristic type:CBCharacteristicWriteWithoutResponse];
                i+=20;
            }
            [self.blustorPeripheral writeValue:[NSData dataWithBytes:command4 length:1] forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
            //[self.blustorPeripheral writeValue:[NSData dataWithBytes:command1 length:1] forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
            NSTimeInterval timeInterval = [self.startTime timeIntervalSinceNow];
            NSLog(@"File transfer time: %f", timeInterval);
        }
        else if(cmd == 4)
        {
            NSLog(@"Delete active file");
            [self.blustorPeripheral writeValue:command_delete forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
    else
    {
        NSLog(@"Error: device not connected");
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOff){
        NSLog(@"BLE OFF");
    } else if (central.state == CBCentralManagerStatePoweredOn){
        NSLog(@"BLE ON");

        [self.myCentralManager scanForPeripheralsWithServices:self.serviceArraySearch options:nil];
        //[self.myCentralManager retrieveConnectedPeripheralsWithServices:self.serviceArraySearch];
        //[self.myCentralManager retrievePeripheralsWithIdentifiers:self.serviceArraySearch];
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
    if([[peripheral name] isEqual:@"CGATELE0898"])
    {
        NSLog(@"Cybergate Card found");

        self.blustorPeripheral = peripheral;
        self.blustorPeripheral.delegate = self;
    
        [self.myCentralManager connectPeripheral:self.blustorPeripheral options:nil];
        [self.myCentralManager stopScan];
        NSLog(@"Scanning stopped");
    }
}

- (void)centralManager:(CBCentralManager *)central
 didRetrieveConnectedPeripherals:(NSArray<CBPeripheral *> *)peripherals
{
    NSLog(@"Cybergate Card found connected");
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray<CBPeripheral *> *)peripherals
{
    NSLog(@"Cybergate Card found non-connected");
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
    int cmd;

    NSLog(@"Found characteristic.");
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@", characteristic);
        if([characteristic.UUID isEqual:self.blustorControlPointUUID]){
            self.blustorControlPointCharacteristic = characteristic;
        } else if([characteristic.UUID isEqual:self.blustorFileWriteUUID]){
            self.blustorFileWriteCharacteristic = characteristic;
        }
    }
    
    while(1) {
        NSLog(@"Command: ");
        scanf("%d", &cmd);
        [self sendCommand:cmd];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
                        error:(NSError *)error
{
    NSData *data = characteristic.value;
    NSLog(@"Discovered value %@", data);
}

@end
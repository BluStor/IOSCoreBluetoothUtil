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
@property NSUUID *cybergateMacUUID;

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
    unsigned char command15[] = {0x0F};
    unsigned char command14[] = {0x0E};
    unsigned char command13[] = {0x0D};
    unsigned char command11[] = {0x0B};
    unsigned char command10[] = {0x0A};
    unsigned char command9[] = {0x09};
    unsigned char command8[] = {0x08};
    unsigned char command6[] = {0x06};  // Connection settings: custom speed
    unsigned char command5[] = {0x05};  // Connection settings: low power
    unsigned char command3[] = {0x03};
    unsigned char command4[] = {0x04};
    unsigned char command2[] = {0x02};
    unsigned char command1[] = {0x01};
    unsigned char filepath[] = "/device/log.0";
    unsigned char filepath_length = sizeof(filepath);
    unsigned char device_name[] = "bluster";
    unsigned char device_name_length = sizeof(device_name);
    unsigned char local_password[] = "Blust0r";
    unsigned char local_password_length = sizeof(local_password);
    unsigned char conn_interval_cmd_len = 2;
    unsigned char conn_interval[] = {30, 30};
    unsigned char hello[] = "hellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohello";
    //unsigned char hello[] = "1234";
    unsigned int i = 0;
    
    NSMutableData *command_enable_edr = [NSMutableData dataWithBytes:command1 length:1];
    
    NSMutableData *command_disc_le = [NSMutableData dataWithBytes:command13 length:1];

    NSMutableData *command_burn_in = [NSMutableData dataWithBytes:command14 length:1];

    NSMutableData *command_fw_ver = [NSMutableData dataWithBytes:command15 length:1];
    
    NSMutableData *command_download = [NSMutableData dataWithBytes:command2 length:1];
    [command_download appendBytes:&filepath_length length:1];
    [command_download appendBytes:filepath length:filepath_length];
    
    NSMutableData *command_delete = [NSMutableData dataWithBytes:command8 length:1];
    [command_delete appendBytes:&filepath_length length:1];
    [command_delete appendBytes:filepath length:filepath_length];
    
    NSMutableData *command_upload = [NSMutableData dataWithBytes:command3 length:1];
    [command_upload appendBytes:&filepath_length length:1];
    [command_upload appendBytes:filepath length:filepath_length];
    
    NSMutableData *command_srft = [NSMutableData dataWithBytes:command4 length:1];
    [command_srft appendBytes:&filepath_length length:1];
    [command_srft appendBytes:filepath length:filepath_length];
    
    NSMutableData *command_conn_interval = [NSMutableData dataWithBytes:command6 length:1];
    [command_conn_interval appendBytes:&conn_interval_cmd_len length:1];
    [command_conn_interval appendBytes:conn_interval length:conn_interval_cmd_len];

    NSMutableData *command_rename = [NSMutableData dataWithBytes:command8 length:1];
    [command_rename appendBytes:&device_name_length length:1];
    [command_rename appendBytes:device_name length:device_name_length];
    
    NSMutableData *command_store_password = [NSMutableData dataWithBytes:command9 length:1];
    [command_store_password appendBytes:&local_password_length length:1];
    [command_store_password appendBytes:local_password length:local_password_length];

    NSMutableData *command_status = [NSMutableData dataWithBytes:command10 length:1];
    [command_status appendBytes:&filepath_length length:1];
    [command_status appendBytes:filepath length:filepath_length];
    
    NSMutableData *command_size = [NSMutableData dataWithBytes:command11 length:1];
    [command_size appendBytes:&filepath_length length:1];
    [command_size appendBytes:filepath length:filepath_length];
    
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
            [self.blustorPeripheral writeValue:command_upload forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
            self.startTime = [NSDate date];
            while(i < 5000){
                [self.blustorPeripheral writeValue:[NSData dataWithBytes:hello length:sizeof(hello)] forCharacteristic:self.blustorFileWriteCharacteristic type:CBCharacteristicWriteWithoutResponse];
                i+=20;
            }
            [self.blustorPeripheral writeValue:command_srft forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
            NSTimeInterval timeInterval = [self.startTime timeIntervalSinceNow];
            NSLog(@"File transfer time: %f", timeInterval);
        }
        else if(cmd == 4)
        {
            NSLog(@"Delete active file");
            [self.blustorPeripheral writeValue:command_delete forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if(cmd == 5)
        {
            NSLog(@"Rename card");
            [self.blustorPeripheral writeValue:command_rename
                             forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if(cmd == 6)
        {
            NSLog(@"Store password");
            [self.blustorPeripheral writeValue:command_store_password
                             forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if(cmd == 7)
        {
            [self.myCentralManager cancelPeripheralConnection:self.blustorPeripheral];
        }
        else if(cmd == 8)
        {
            NSLog(@"Read CRC16");
            [self.blustorPeripheral readValueForCharacteristic:self.blustorFileWriteCharacteristic];
        }
        else if(cmd == 9)
        {
            NSLog(@"Open temp file");
            [self.blustorPeripheral writeValue:command_upload forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if(cmd == 10)
        {
            NSLog(@"Read file status");
            [self.blustorPeripheral writeValue:command_status forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if(cmd == 11)
        {
            NSLog(@"Read file size");
            [self.blustorPeripheral writeValue:command_size forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
            
        }
        else if(cmd == 12)
        {
            NSLog(@"Enable EDR");
            [self.blustorPeripheral writeValue:command_enable_edr forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if(cmd == 13)
        {
            NSLog(@"Send SRFT");
            [self.blustorPeripheral writeValue:command_srft forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if(cmd == 14)
        {
            NSLog(@"Disconnect LE");
            [self.blustorPeripheral writeValue:command_disc_le forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if(cmd == 15)
        {
            NSLog(@"Burn in");
            [self.blustorPeripheral writeValue:command_burn_in forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
        else if(cmd == 16)
        {
            NSLog(@"Get fw ver");
            [self.blustorPeripheral setNotifyValue:YES forCharacteristic:self.blustorControlPointCharacteristic];
            [self.blustorPeripheral writeValue:command_fw_ver forCharacteristic:self.blustorControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
        }
    }
    else
    {
        NSLog(@"Error: device not connected");
    }
}

- (void)userInput
{
    int cmd;
    
    while(1) {
        NSLog(@"Command: ");
        scanf("%d", &cmd);
        [self sendCommand:cmd];
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
    //if([[peripheral name] isEqual:@"CGATELE0898"])
    //{
        NSLog(@"Cybergate Card found");

    if(RSSI.intValue > -65){
        NSLog(@"In range!");
        self.blustorPeripheral = peripheral;
        self.blustorPeripheral.delegate = self;
        NSLog(@"RSSI: %@", RSSI);
        
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

    NSLog(@"Found characteristic.");
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@", characteristic);
        if([characteristic.UUID isEqual:self.blustorControlPointUUID]){
            self.blustorControlPointCharacteristic = characteristic;
        } else if([characteristic.UUID isEqual:self.blustorFileWriteUUID]){
            self.blustorFileWriteCharacteristic = characteristic;
        }
    }
    
    NSThread* btThread = [[NSThread alloc] initWithTarget:self selector:@selector(userInput) object:nil];
    
    [btThread start];
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
                        error:(NSError *)error
{
    NSData *data = characteristic.value;
    NSLog(@"Discovered value %@", data);
}

@end

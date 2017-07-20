# IOSCoreBluetoothUtil

## Running the program

Open the project in XCode. The program will immediately attempt to locate a BluStor card peripheral based on RSSI.  When it finds a card that is close enough, the program will attempt to connect.

After a successful connection, the program will prompt the user terminal for a command.  The commands all run based on predfined symbols established at run time.  To change the command parameters, you will have to stop and rebuild the program.

CMD 1: Read to start pairing
- This command reads a known value (0x26a5) from encryption protected data on the database.  Run this command to confirm that you have successfully paired with the Central.  Alternatively, run this command to kickstart the pairing process if you are not paired.

CMD 2: Download filepath
- This command reads a file from the filepath specified at compile time.  Run this command to download any file on the card.  Alternatively, use this command to confirm the success of command 3.

CMD 3: Upload to filepath
- This command continuously writes a string to the filepath.  Use this command to simulate storing a database.

CMD 4: Delete active file
- Use this command to delete the file existing at the filepath.

CMD 5: Rename card
- Use this command to rename the card.

CMD 6: Store password
- Use this command to store a custom AUTOLOGN password to the BluStor card.  The card will only associate the password with the active paired Central device.

CMD 7: Cancel connect
- Use this command to cancel the active connection.

CMD 8: Read CRC16
- Use this command to verify the results of the CRC16 algorithm used for file transfer on the card.

CMD 9: Open temp file
- Use this command to open the temp file.  In order to upload the database, the program must open the BluStor card's temp file. Also use this command to test the safety of sending multiple open commands in a row.

CMD 10: Read file status
- Use this command to chekc if a file exists.

CMD 11: Read file size:
- Use this command to check the size of the file located at filepath.

CMD 12: Enable EDR
- Use this command to enable EDR mode when the password vault firmware enables low power mode.

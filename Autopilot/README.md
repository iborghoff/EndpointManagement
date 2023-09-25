# AutopilotDeviceConfiguration
A modified version of AutopilotBranding (https://github.com/mtniehaus/AutopilotBranding) which configures a device during Windows Autopilot based on its geographical ID location. This is based on the location the user selects during OOBE.

I've removed items I didn't want/need to customise in my version, such as the Start Menu.

# Usage
1. Add/update Config.xml with Geo ID elements for the location(s) you need.
2. Add the language pack file(s) to the LPs folder.
3. Create a Language XML file for each.
4. Create a .intunewin file and add as a Win32 application to Intune (you can follow the AutopilotBranding on the best way to do that)

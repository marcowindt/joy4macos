# joy4macos

## Known issues

- Accelerometer and gyroscope not working properly

## Build & Run

- Run `pod install` to install depencies (requires cocoapods to be installed).
- Open this project in Xcode
- Make sure your Signing & Capabilities settings are correct, change the bundle identifier if needed
- Press run

## JoyCon Controllers & Pro Controller

This application is designed to also have motion data available from JoyCon Controllers and Pro Controllers in the Dolphin emulator on MacOS.
If you aren't interested in using the accelerometer and gyro of these controler(s) then this application is not needed, 
since simple button mapping works straight away with Dolphin.

## Dolphin

This app is made to be used with the Dolphin emulator. 
Within Dolphin you go to alternative input devices and setup the DSU client to listen to the server running on your computer with port 26760 (you can find your ip address by running something like `ifconfig` in a Terminal).

### Controller Profile

1. If using the profile (for JoyCon Right Controller) from this repository place it within the Config folder of Dolhpin:
	- `/Users/username/Library/Application Support/Dolphin/Config/Profiles/Wiimote/joy4macosR.ini`

Otherwise, just map it yourself it's very simple.

## Credits

A lot of this application's code was made possible by looking at an existing DSU server
implementation for Joy Con controllers at https://github.com/joaorb64/joycond-cemuhook/tree/master

Also, the specification of the DSU protocol at https://v1993.github.io/cemuhook-protocol/ is of
great value

Furthermore, huge thanks to [magicien](https://github.com/magicien) for writing the [JoyConSwift](https://github.com/magicien/JoyConSwift) library which this simple app heavily relies on.

## Screenshots

<img src="https://github.com/marcowindt/joy4macos/blob/main/screenshot1.png" alt="Screenshot of the controllers tab"/>
<img src="https://github.com/marcowindt/joy4macos/blob/main/screenshot2.png" alt="Screenshot of the server tab"/>

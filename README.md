## Fake GPS Utility

##

# Overview

This tool allows to replace the CLLocationManager data with custom parameters, which is particularly useful for debugging location-based apps.

# Installation

## Manual

1. Drag the FakeGPSUtility folder (the one under the main folder) into your Xcode project.
2. Define 'DEBUG' in target build configuration.
3. Add MapKit and CoreLocation frameworks into your target.

## From CocoaPods

1. Write in your *.pod file:

pod 'FakeGPSUtility', :git => 'https://github.com/Azoft/FakeGPSUtility.git'"

2. Define 'DEBUG' in target build configuration.

## How to Use

To run the utility, make the shake gesture, then press the Simulate Location button. On the next screen you will see the map and can configure the tool and stop/pause/resume simulation of custom locations.

The utility settings offer 3 modes (and starting with iOS 7.0 – 4 modes) of simulation: 

Single – allows to choose one point on the map where the tool will simulate location;
Multiple – offers several points on the map to simulate location;
File – uses points from a *.plist file, so there’s no need to set them manually; to use this mode, add a Ponits.plist file to the app sources;
Route – allows to choose two points with a long-press gesture and creates a route between them – the simulation of coordinate changes would be made along this new route. Besides, you can define the value for updates of route coordinates per second and loop a route. This mode is available only for iOS 7.

After you've configured the tool, close the menu and continue debugging your application.

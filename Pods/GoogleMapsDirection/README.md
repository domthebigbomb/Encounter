#GoogleMapsDirection

GoogleMapsDirection provide a wrapper for the Google Direction Service API. You can find more information about this service here : https://developers.google.com/maps/documentation/directions/

#Usage

The service is a singleton, you can easily make a call with :

	[[GMDirectionService sharedInstance] getDirectionsFrom:origin to:destination succeeded:^(GMDirection *directionResponse) {
			if ([directionResponse statusOK]){
				NSLog(@"Duration : %@", [directionResponse durationHumanized]);
				NSLog(@"Distance : %@", [directionResponse distanceHumanized]);
			}
	} failed:^(NSError *error) {
			NSLog(@"Can't reach the server")
	}];

#Install

Use CocoaPods and add this in your podfile

	pod "GoogleMapsDirection"

Just run

	pod install


#License

Copyright (C) 2013 Djengo

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

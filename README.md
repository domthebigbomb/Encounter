Encounter
=========

Encounter iOS App

Welcome to the Encounter iOS Readme!

After the application has properly loaded there are two options:

Create - application will check firebase for an available room pin and assign it to the room you are about to create.
Once confirmed, the application will open a map view that shows a representation of the room you created. 

Join - User's can enter a PIN in the textfield and if the PIN is valid then a map view is loaded with markers indicating
the position of other user's in the room. If the PIN is invalid, Encounter will alert the user.

Mapview will draw a polyline utilizing Google Map API and the Google Map SDK. Lines will stem from the user's
current location and extend to every other user in the room. Lines will refresh automatically. User's location 
is reported to firebase once every 10 or so seconds.

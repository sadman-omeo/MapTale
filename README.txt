Project Overview
MapTale is an Android mobile application developed for the CSE 489 Mobile Application Development lab exam. The app interacts with the faculty-provided REST API to manage and visualize smart geo-tagged landmarks. It allows users to view landmarks in both list and map formats, visit landmarks using current GPS location, add new landmarks with image upload, track visit history, and continue using important features even when offline.

Features Implemented
1. Landmarks list view showing title, image, and score
2. Sorting landmarks by score
3. Filtering landmarks by minimum score
4. Map view with landmark markers centered on Bangladesh
5. Marker tap dialog showing landmark details
6. Marker color variation based on score
7. Visit Landmark feature using current GPS location
8. Success and failure feedback for visit requests
9. Activity screen showing visit history with landmark name, visit time, and distance
10. Add Landmark feature with title, latitude, longitude, and image upload
11. Auto-fill latitude and longitude using current location
12. Offline landmark caching
13. Offline visit queueing
14. Automatic syncing of pending offline visits when internet becomes available
15. Refresh support to reload latest landmark data

API Usage
This project uses the faculty-provided API endpoint:
https://labs.anontech.info/cse489/exm3/api.php

The following API actions were used:
1. get_landmarks
   - Used to fetch landmark data from the server
   - Displayed in both Landmarks and Map tabs

2. visit_landmark
   - Used when a user visits a landmark
   - Sends landmark_id, user_lat, and user_lon as JSON
   - Displays server response and returned distance

3. create_landmark
   - Used to create a new landmark
   - Sends title, lat, lon, and image using multipart/form-data

The student key is included in all API requests as required.



Offline Strategy
The application supports offline behavior in the following way:
1. When landmarks are fetched successfully from the API, they are saved locally using shared preferences.
2. If the internet is unavailable later, the cached landmark data is loaded and shown in the Landmarks screen.
3. If a user presses Visit while offline, the visit is stored locally as a pending visit instead of being lost.
4. When the internet becomes available again and the Landmarks screen is opened, the app attempts to sync pending offline visits to the server.
5. Successfully synced offline visits are removed from the pending queue and added to Activity history.

Architecture Used
The project follows a simple modular Flutter structure:
1. screens/
   - Contains UI screens such as Map, Landmarks, Activity, and Add/View
2. services/
   - Handles API communication, visit history storage, and offline storage
3. models/
   - Contains model classes such as the Landmarks model

The UI layer communicates with service classes, and service classes handle networking and local storage.


Devices Used
1. Samsung Galaxy Note 20U (SM N9860)
2. Samsung Galaxy F22(SM F9880)
3. Poco X4 Pro

Challenges Faced
1. Handling dynamic landmark data from the API
2. Making sure image upload worked correctly using multipart/form-data
3. Showing images properly when API image paths were relative instead of full URLs
4. Managing GPS permission and current location access
5. Implementing offline cache and pending visit sync logic
6. Keeping Activity history updated after successful online and offline-synced visits
7. Refreshing both list and map views properly when landmark data changed
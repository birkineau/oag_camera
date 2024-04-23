Provides a CameraApplication widget that allows other applications to take
geolocated pictures, and utility functions for compressing the resulting files
for storage.

## Features

- Take pictures with different orientations, flash modes.
- Camera roll with image selector, zoom pan, and slide/scroll through photos.
- Auto-rotating UI & images even when app UI mode is locked.
- Pinch to zoom in/out during live preview, or when viewing the camera roll;
double tap to reset zoom.
- Camera settings (flash modes, exposure); close with double tap.
- Toggle lens direction with button or double tap.

## Getting started

In the example project, permissions must be granted on application startup.

Run the example application, grant the required permissions, and follow the
documentation as needed.

## Usage

This application is somewhat similar to the iOS camera. Most interactions should
be self-explanatory.

IMPORTANT: To close the live preview settings; double tap the live preview.

## Additional information

This camera project was necessary to implement forms that required photos in a
larger project; it needed support for 

In the larger project, images require compression for storage, and must be able
to be built from the bytes of the image.

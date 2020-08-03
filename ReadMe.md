![screenshots](https://github.com/OlehTitov/virtualTourist/blob/master/VirtualTouristBannerAlt.jpg)

## Core Data
- The app uses a managed object model created in the Xcode Model Editor
- The object model contains a one-to-many relationship between the Pin and Photo entities, with an appropriate inverse

## Map View
- The app contains a map view that allows users to drop pins with a touch and hold gesture
- When a pin is tapped, the app transitions to the photo album associated with the pin
- When pins are dropped on the map, the pins are persisted as Pin instances in Core Data and the context is saved
- Pin details view has a shrinking map view to increase the screen area allocated for images

## Collection View
- The app uses Compositional Layout which enables to present photos in modern layout

## Diffable Data Source
- The collection view uses diffable data source and its snapshot feeds from Core Data which makes it easy to handle CRUD operations


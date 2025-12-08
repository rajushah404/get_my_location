## [2.1.1] - 2025-11-26
### Changed
- Updated dependencies and improved package compatibility

## [2.0.3] - 2025-05-14
## Added 
- Complete UI decoupling: Package no longer renders any built-in UI components

- Three access patterns:

  - Callback-based (onLocationFetched, onError, onLoading)

  - InheritedWidget-style (LocationGetter.of(context))

  - Controller pattern (LocationGetterController)
 
 
## [2.0.2] - 2025-05-13
### Added
- Improved location fetching logic with additional checks for service and permissions.
- Added `onLocationFetched` callback to handle location data on fetch.

### Fixed
- Resolved issue where location data wasn't displayed correctly in certain cases.
- Fixed minor UI issues in location display.

### Changed
- Refined error handling for better user feedback.
- Refined code to ensure compatibility with the latest Flutter versions.


## 2.0.1
- Fixed "No location data available" bug after permission grant
- Ensured `_currentPosition` is properly updated
y

## 2.0.0
- Added address reverse geocoding
- Introduced `LocationData` model
- Configurable refresh button
- Added timestamp to location data
- Improved documentation

## 1.0.0
- Initial release with basic location fetching
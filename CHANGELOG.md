# exestack Changelog

## Unreleased Changes

### Added
* Breadcrumbs to navigate folders. 

### Changed
* Fixed tooltips sometimes being cutoff.
* Updated Ode Script Editor to latest version

### Removed
* Parent button replaced with breadcrumbs.

## 0.4.3

### Removed
* Remove execution control
* Remove update checking
* Remove options for above
* Remove bad terms in fast lexer

## 0.4.2

### Added
* Add more types to ExportToModule
  * CFrame
  * UDim2
  * UDim
  * Enum
  * NumberSequence
  * NumberSequenceKeypoint
  * NumberRange
  * ColorSequence
  * ColorSequenceKeypoint
* Add clone as additional option

### Changed
* Add semantic improvements for better human readability
  * Hide number indices for gapless arrays
  * Simplify table indices when they are valid variable names

### Fixed
* Fix ExportToModule (ETM) not exporting vector3s properly
* Fix ETM not exporting colors properly
* Slightly optimized ETM
* Add type annotations to some BytLib functions
* Update About page

## 0.4.1
### Changed
* Update OSE to latest version

## 0.4.0

### Added
* Add support ko-fi page
* Add prompt message
* Add new local byt

### Fixed
* Fix issue where rename menu is shown under generic advanced menu
* Let replication use correct order in editing during playtesting
* Small codebase improvements
* Make S/C Execution related if statements clearer
* Update copyright
* Fix status update not properly displaying after waiting in a byt script
* Update API doc

## Older
* Add proper selection box functionality
* Try adding execution control
* Add tooltips
* Add a simple tutorial
* Add confirmation before delete
* Add quick server/client execution
* Responsive UI
* Refresh button (fixes replication folder stuff)
* Switch right and left click for plus icon
* Make it so right-clicking doesn't deselect everything
* Prevent user from making an empty name
* Make slashes consistent
* Fix folder export not working
* Make BE2 icon toggle rather than enable
* Shorten time needed to drag
* Fix replication attempting on snippets
* Fix documents not opening
* Rojo support
* Better folder search
* Improved Ode
* Fix issue where settings scales improperly
* Add option to use new script context
* Add new importing/exporting options
* Refactor preferences because it hasn't changed since BE1
* Fixed issue where options would fail to clean up unused options
* Fix issue where true size isnt used
* Fix issue where setting for new byt name allows spaces
* Add new export instance
* Add new import data
* Add update checker
* Add backup folder
  * Stored in ServerStorage
* Add Load Last Saved Backup option
* Improve internal codebase
  * Replace some function with YieldCurrentThread
  * Improve performance by not loading model if update checking was disabled
  * Improve naming
  * Replace custom func with gsub
  * Move some stuff to Util
* Add BytLib:Require(string)
* Add ability to edit and save scripts even while playtesting and S/C is enabled
* Add Enable Debug Options
* Add option to swap functionality on plus icon
* Add option to enable select elements that were prev dragged after opening folder
* Add option whether to open folder that was dragged in
* Add ForceUniqueNames
  * Forces unique names when adding or renaming element
* Increase min size of Preferences
* Save where you left off in the directory
* Replace backslash with forward slashes
* Patch issue where things didnt auto-indent for function Foo.bar()
* Add heavy saving
* Make parent element more responsive when hovering
* Add default names for other element types
* Replace spaces in imported script with underscores
* Test if SF call degrades performance
* Allow building/viewing source code
* Add SharedTable and other blue names
* Improve ClickFields
  * Fix bugs related to click inputs
* Make parent element more responsive when clicking
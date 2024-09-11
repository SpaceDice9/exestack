# exestack Changelog

## Unreleased Changes

### Added
* Breadcrumbs to navigate folders. 

### Changed
* Fixed tooltips sometimes being cutoff.

### Removed
* Parent button replaced with breadcrumbs.

## 0.4.3

### Removed
* Remove execution control (DONE)
* Remove update checking (DONE)
* Remove options for above (DONE)
* Remove bad terms in fast lexer

## 0.4.2

### Added
* Add more types to ExportToModule (DONE)
  * CFrame (DONE)
  * UDim2 (DONE)
  * UDim (DONE)
  * Enum (DONE)
  * NumberSequence (DONE)
  * NumberSequenceKeypoint (DONE)
  * NumberRange (DONE)
  * ColorSequence (DONE)
  * ColorSequenceKeypoint (DONE)
* Add clone as additional option (DONE)

### Changed
* Add semantic improvements for better human readability (DONE)
  * Hide number indices for gapless arrays (DONE)
  * Simplify table indices when they are valid variable names (DONE)

### Fixed
* Fix ExportToModule (ETM) not exporting vector3s properly (DONE)
* Fix ETM not exporting colors properly (DONE)
* Slightly optimized ETM (DONE)
* Add type annotations to some BytLib functions (DONE)
* Update About page (DONE)

## 0.4.1
### Changed
* Update OSE to latest version (DONE)

## 0.4.0

### Added
* Add support ko-fi page (DONE)
* Add prompt message (DONE)
* Add new local byt (DONE)

### Fixed
* Fix issue where rename menu is shown under generic advanced menu (DONE)
* Let replication use correct order in editing during playtesting (DONE)
* Small codebase improvements (DONE)
* Make S/C Execution related if statements clearer (DONE)
* Update copyright (DONE)
* Fix status update not properly displaying after waiting in a byt script (DONE)
* Update API doc (DONE)

## Older
* Add proper selection box functionality (DONE)
* Try adding execution control (DONE?)
* Add tooltips (DONE)
* Add a simple tutorial (DONE?)
* Add confirmation before delete (DONE)
* Add quick server/client execution (DONE?)
* Responsive UI (DONE?)
* Refresh button (fixes replication folder stuff) (DONE)
* Switch right and left click for plus icon (DONE)
* Make it so right-clicking doesn't deselect everything (DONE)
* Prevent user from making an empty name (DONE)
* Make slashes consistent (DONE)
* Fix folder export not working (DONE)
* Make BE2 icon toggle rather than enable (DONE)
* Shorten time needed to drag (DONE)
* Fix replication attempting on snippets (DONE)
* Fix documents not opening (DONE)
* Rojo support (DONE)
* Better folder search (DONE)
* Improved Ode (DONE)
* Fix issue where settings scales improperly (DONE)
* Add option to use new script context (DONE)
* Add new importing/exporting options (DONE)
* Refactor preferences because it hasn't changed since BE1 (DONE)
* Fixed issue where options would fail to clean up unused options (DONE)
* Fix issue where true size isnt used (DONE)
* Fix issue where setting for new byt name allows spaces (DONE)
* Add new export instance (DONE)
* Add new import data (DONE)
* Add update checker (DONE)
* Add backup folder (DONE)
  * Stored in ServerStorage (DONE)
* Add Load Last Saved Backup option (DONE)
* Improve internal codebase (DONE?)
  * Replace some function with YieldCurrentThread (DONE)
  * Improve performance by not loading model if update checking was disabled (DONE)
  * Improve naming (DONE)
  * Replace custom func with gsub (DONE)
  * Move some stuff to Util (DONE)
* Add BytLib:Require(string) (DONE)
* Add ability to edit and save scripts even while playtesting and S/C is enabled (DONE?)
* Add Enable Debug Options (DONE)
* Add option to swap functionality on plus icon (DONE)
* Add option to enable select elements that were prev dragged after opening folder (DONE)
* Add option whether to open folder that was dragged in (DONE)
* Add ForceUniqueNames (DONE)
  * Forces unique names when adding or renaming element (DONE)
* Increase min size of Preferences (DONE)
* Save where you left off in the directory (DONE)
* Replace backslash with forward slashes (DONE)
* Patch issue where things didnt auto-indent for function Foo.bar() (DONE)
* Add heavy saving (DONE)
* Make parent element more responsive when hovering (DONE)
* Add default names for other element types (DONE)
* Replace spaces in imported script with underscores (DONE)
* Test if SF call degrades performance (Nothing found)
* Allow building/viewing source code (DONE?)
* Add SharedTable and other blue names (DONE)
* Improve ClickFields (DONE)
  * Fix bugs related to click inputs (DONE)
* Make parent element more responsive when clicking (DONE)
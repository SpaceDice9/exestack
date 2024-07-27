--disable
--[[


NOTE: For Exestack's BytExecutor, there are several principles it must adhere to in decreasing priority

* Minimal clutter: The UI must contain as little clutter as possible. It can't be overflowing with widgets and buttons to click
  * Minimal actions: Most actions should be as few actions away as possible
  * Less used actions should never be more than two actions away
  * Commonly used actions should be a single action away

* High density: The UI should hold as much data as it can without clutter

* Intuitive: Most elements should be self-explanatory or have a tooltip for anything not obvious

* Elegance: The UI should look pretty when possible


Things I'm done with
Add proper selection box functionality (DONE)
Try adding execution control (DONE?)
Add tooltips (DONE)
Add a simple tutorial (DONE?)
Add confirmation before delete (DONE)
Add quick server/client execution (DONE?)
Responsive UI (DONE?)
Refresh button (fixes replication folder stuff) (DONE)

Switch right and left click for plus icon (DONE)
Make it so right-clicking doesn't deselect everything (DONE)
Prevent user from making an empty name (DONE)
Make slashes consistent (DONE)
Fix folder export not working (DONE)
Make BE2 icon toggle rather than enable (DONE)
Shorten time needed to drag (DONE)
Fix replication attempting on snippets (DONE)
Fix documents not opening (DONE)

Rojo support (DONE)
Better folder search (DONE)
Improved Ode (DONE)
Fix issue where settings scales improperly (DONE)

Add option to use new script context (DONE)
Add new importing/exporting options (DONE)
Refactor preferences because it hasn't changed since BE1 (DONE)
Fixed issue where options would fail to clean up unused options (DONE)

Fix issue where true size isnt used (DONE)
Fix issue where setting for new byt name allows spaces (DONE)
Add new export instance (DONE)
Add new import data (DONE)

Add update checker (DONE)


Add backup folder (DONE)
 * Stored in ServerStorage (DONE)
Add Load Last Saved Backup option (DONE)
Improve internal codebase (DONE?)
 * Replace some function with YieldCurrentThread (DONE)
 * Improve performance by not loading model if update checking was disabled (DONE)
 * Improve naming (DONE)
 * Replace custom func with gsub (DONE)
 * Move some stuff to Util (DONE)

Add BytLib:Require(string) (DONE)
Add ability to edit and save scripts even while playtesting and S/C is enabled (DONE?)
Add Enable Debug Options (DONE)
Add option to swap functionality on plus icon (DONE)
Add option to enable select elements that were prev dragged after opening folder (DONE)
Add option whether to open folder that was dragged in (DONE)

Add ForceUniqueNames (DONE)
 * Forces unique names when adding or renaming element (DONE)
Increase min size of Preferences (DONE)
Save where you left off in the directory (DONE)
Replace backslash with forward slashes (DONE)
Patch issue where things didnt auto-indent for function Foo.bar() (DONE)

Add heavy saving (DONE)
Make parent element more responsive when hovering (DONE)
Add default names for other element types (DONE)
Replace spaces in imported script with underscores (DONE)

Test if SF call degrades performance (Nothing found)


Allow building/viewing source code (DONE?)
Add SharedTable and other blue names (DONE)

Improve ClickFields (DONE)
* Fix bugs related to click inputs (DONE)

Make parent element more responsive when clicking (DONE)


-- Snippets --
Show preview (DONE)
Show potential other snippets that match (DONE)
* Match incomplete snippets to real snippets (DONE)

Fix: label showing wrong text (DONE)
Fix: remove unnecessary vars related to snippets (DONE?)
Fix: update warning for editing byts when using S/C Execution (DONE)

Small codebase improvements (DONE)
* Moves some executable code to make it a bit cleaner and more general


(0.4.0)

Fix issue where rename menu is shown under generic advanced menu (DONE)
(S/C E seems stable enough!)

Let replication use correct order in editing during playtesting (DONE)
Small codebase improvements (DONE)
* Make S/C Execution related if statements clearer (DONE)
Update copyright (DONE)

Add support ko-fi page (DONE)
Add prompt message (DONE)
Add new local byt (DONE)
Fix status update not properly displaying after waiting in a byt script (DONE)
Update API doc (DONE)

(0.4.1)
Update OSE to latest version (DONE)


TODO (0.4.2)
Fix ExportToModule (ETM) not exporting vector3s properly (DONE)
Fix ETM not exporting colors properly (DONE)
Slightly optimized ETM (DONE)
Add type annotations to some BytLib functions (DONE)
Add semantic improvements for better human readability (DONE)
* Hide number indices for gapless arrays (DONE)
* Simplify table indices when they are valid variable names (DONE)
Add more types to ExportToModule (DONE)
* CFrame (DONE)
* UDim2 (DONE)
* UDim (DONE)
* Enum (DONE)
* NumberSequence (DONE)
* NumberSequenceKeypoint (DONE)
* NumberRange (DONE)
* ColorSequence (DONE)
* ColorSequenceKeypoint (DONE)

Add clone as additional option (DONE)
Update About page (DONE)


(0.4.3)

Remove execution control (DONE)
Remove update checking (DONE)
Remove options for above (DONE)
Remove bad terms in fast lexer


(0.4.4)

Remove clone option


Use more explicit dependency injection

Add ability to automatically add BytLocalSync (Done?)
Better detect when an internal error occurs
Improve search algo

Make script editing for s/c while playtesting save across models
Detect properly when mouse leaves the widget and selects something
Duplicate option
Transform option under name (changes element type if applicable)
Add better document viewer (DELAYED)
Fix issue where selection option cant be clicked thru the arrow


---/ Exestack: Sunset (CubicLuau) Blocks /---
Blocks



---/ Exestack: ExeBridge /---
* Separate Exestack into several different plugins



---/ Exestack: Luau Index /---
Luau Index
* Minimap
* Lexer to get functions and other stuff
* Moonwave?


---/ Exestack: Snippets (BE2) /---

Core features
* Replaces snippet indicator with the correct snippet of code (DONE)
  * Support placeholders (DONE)
    * --@snippet/${var1}/${var2} (DONE)

UX
* Make them intuitive (DONE)
* Works with BE2 (DONE)
* Autocomplete list



---/ Exestack: Performance Profiler (BE2) /---
Core features
* Gives a detailed graph and summary of data (DONE?)
  * Mean, median, q1, q3, standard deviation (DONE)
  * These can be hidden (DONE)
* Compare multiple graphs (DONE)
* Highly interactive, hovering over elements gives more data (DONE?)
  * Hovering over bar gives its size (DONE)
  * Clicking the colored bar or its marker on the legend emphasizes it (DONE)
* Create markers to view different speeds within func itself

UX
* Functions can be given names (DONE)
* Add some support for inferential statistics



---/ Exestack: BytExecutor2 /---

DEBUG:


Bugs fixes so far:
Search does not work in subdirectories (fixed)
Crash when enabling s/c execution (fixed)
Replication scripts not replicating when moving elements to a folder (fixed)
creating replication instances doesn't work in subdirectories? (fixed)
Reloading BE2 doesn't load in byt code to replication scripts (fixed)
Can't auto-edit name when using right-click creating both with the plus icon and menu (fixed)
Theme doesn't change when studio does (fixed)
Loading backups doesnt destroy current elements (fixed)

In some cases when running to an error the execute button disappears (fixed)
Byts that are being dragged are displayed in the wrong size (fixed)
Elements can be moved when asked for deletion (fixed)
Byt saving occurs when user reselects inside a script (fixed)
Errors point to an invalid line due to BytLib error (fixed)
INTERNAL EXECUTABLES don't redirect to the correct line when clicked on (fixed)
Fix explorer rendering over the dragging container (fixed)

Bugs found:
Terminate, pause buttons don't clear, creating small mem leak (fixed)




---------------------------------


(27/29) as of 6/27/23
  (25/33) as of 6/8/23


(4/4)
Core Features:
  * Lua script execution in Studio (DONE)
    * On-the-fly execution like RunLSC (DONE)
    * Quick server/client execution (DONE)
  * API which provides convenient methods for testing code and running complex tasks (DONE?)
  * Importing and exporting scripts (DONE)
  * Configuration to customize the plugin (DONE)

(5/5)
QoL
  * Contextual Exporting: dynamically change the script class depending on where it is being exported (DONE)
  * Update checker: A snackbar that pops up when script detects a new update. It gives metadata about the new version (INCOMPLETE)
  * Plugin action which runs the last Byt edited (DONE)
    * Settings for changing this behavior (DONE)
  * Plugin actions for creating new byts and folders (DONE)
  * Error Message Redirects: allows users to access where an error occurs without having to manual search for it (DONE?)

(7/7)
UX
  * Tooltips (DONE)
  * Simple tutorial for creating and using BytExecutor (DONE)
    * Done when no elements are present (DONE)
    * Easy pages for presenting tutorials
  * Overall responsive UI (DONE)
    * Colored icons (DONE)
    * Visible renaming (DONE)
  * Confirmation before delete (DONE)
  * Themes! (DONE)
  * Custom code editor option (DONE)
  * Undo/redo (DONE)

(6/6)
Ode Code Editor
  * Highlights (DONE)
  * Loads lines only as needed (DONE)
  * Easily customizable scrolling (DONE)
  * Accessible (DONE)
  * Auto indent (DONE?)
  * Quickly indent with tab (DONE?)


(2/2)
Execution Control/Sandboxing
  * Pausing scripts (DONE)
  * Terminating scripts (DONE)
  * EC macros, achieves similar results to sandboxing but retains much more performance (CANCELLED)

(3/3)
Saving
  * Save metadata (DONE)
  * Save backups (DONE)
  * Minimal saving, only saves when when user quits studio (DONE?)

(0/1)
  (0/1)
About page (INCOMPLETE)
  * Update version and update name (INCOMPLETE)

(2/3)
API
  * proper data -> module (DONE)
  * performance profiler methods (DONE?)
    * visual graphs (DONE?)
  * Rash requiring (DONE)

(5/5)
Byt Explorer
  * Selectable Byts (DONE)
  * Draggable Byts (DONE)
    * Reposition-able Byts (DELAYED)
  * Movable Byts (DONE)
  * Folders (DONE)
    * Nested Folders (DONE)
  * Search bar (DONE)


Bug/Performance Notes:
  * Improve performance of ClickFields?
  * Make it so MouseDown and MouseUp must occur at the same ui element to trigger (DONE)


Prevent multiple parameters from being highlighted
Fix tooltips appearing in the wrong pivot



]]
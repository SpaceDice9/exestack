> NOTE: For Exestack's BytExecutor, there are several principles it must adhere to in decreasing priority

* Minimal clutter: The UI must contain as little clutter as possible. It can't be overflowing with widgets and buttons to click
  * Minimal actions: Most actions should be as few actions away as possible
  * Less used actions should never be more than two actions away
  * Commonly used actions should be a single action away

* High density: The UI should hold as much data as it can without clutter

* Intuitive: Most elements should be self-explanatory or have a tooltip for anything not obvious

* Elegance: The UI should look pretty when possible

___

### Future (0.X.X)
* Remove clone option
* Use more explicit dependency injection
* Better detect when an internal error occurs
* Improve search algo
* Make script editing for s/c while playtesting save across models
* Detect properly when mouse leaves the widget and selects something
* Duplicate option
* Transform option under name (changes element type if applicable)
* Add better document viewer (DELAYED)
* Fix issue where selection option cant be clicked thru the arrow

### 0.4.4
* Undetermined



## Feature sets

### Exestack: Sunset (CubicLuau) Blocks
* Scratch-like


### Exestack: ExeBridge
* Separate Exestack into several different plugins


### Exestack: Luau Index
* Minimap
* Lexer to get functions and other stuff
* Moonwave?


### Exestack: Snippets (BE2)

#### Core features
* Replaces snippet indicator with the correct snippet of code (DONE)
  * Support placeholders (DONE)
    * --@snippet/\${var1}/\${var2} (DONE)

#### UX
* Make them intuitive (DONE)
* Works with BE2 (DONE)
* Autocomplete list


### Exestack: Performance Profiler (BE2)
#### Core features
* Gives a detailed graph and summary of data (DONE?)
  * Mean, median, q1, q3, standard deviation (DONE)
  * These can be hidden (DONE)
* Compare multiple graphs (DONE)
* Highly interactive, hovering over elements gives more data (DONE?)
  * Hovering over bar gives its size (DONE)
  * Clicking the colored bar or its marker on the legend emphasizes it (DONE)
* Create markers to view different speeds within func itself

#### UX
* Functions can be given names (DONE)
* Add some support for inferential statistics


### Exestack: BytExecutor2

#### DEBUG

Bugs fixes so far:
* Search does not work in subdirectories (fixed)
* Crash when enabling s/c execution (fixed)
* Replication scripts not replicating when moving elements to a folder (fixed)
* creating replication instances doesn't work in subdirectories? (fixed)
* Reloading BE2 doesn't load in byt code to replication scripts (fixed)
* Can't auto-edit name when using right-click creating both with the plus icon and menu (fixed)
* Theme doesn't change when studio does (fixed)
* Loading backups doesnt destroy current elements (fixed)
* In some cases when running to an error the execute button disappears (fixed)
* Byts that are being dragged are displayed in the wrong size (fixed)
* Elements can be moved when asked for deletion (fixed)
* Byt saving occurs when user reselects inside a script (fixed)
* Errors point to an invalid line due to BytLib error (fixed)
* INTERNAL EXECUTABLES don't redirect to the correct line when clicked on (fixed)
* Fix explorer rendering over the dragging container (fixed)
* Terminate, pause buttons don't clear, creating small mem leak (fixed)

Bugs found:


## Initial TODO

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
* Prevent multiple parameters from being highlighted
* Fix tooltips appearing in the wrong pivot
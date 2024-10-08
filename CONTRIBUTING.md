# Contributing
> This is a draft and is subject to changes!

## Principles
* Minimal clutter: The UI must contain as little clutter as possible. It can't be overflowing with widgets and buttons to click
  * Minimal actions: Most actions should be as few actions away as possible
  * Less used actions should never be more than two actions away
  * Commonly used actions should be a single action away

* High density: The UI should hold as much data as it can without clutter

* Intuitive: Most elements should be self-explanatory or have a tooltip for anything not obvious

* Elegance: The UI should look pretty when possible

___
When developing, keep this in mind:
* This plugin was ported using Argon, so you should use it when you are making changes.
* Instance data is stored in folders/directories and the associated `.data.json` file.
* Some modules are deprecated and no longer used. These may be removed in a future release
  * `ClickField.luau` has been replaced by `Buttony.luau`
* When testing changes, there may be unexplained errors (such as errors in lines with no code). This is because Exestack does not currently clean its connections per update. 
  * This does not impact end users, it's just a problem on our end :)
  * To fix this, restart studio. Or submit a PR that fixes this. Your choice
	* Maybe Roblox fixed this? Not sure
* This is not an exhaustive list. There are definitely edge cases that @SpaceDice9 forgot about.
___

When submitting changes, make sure to check for the following:
* **DO NOT LET GUI CHANGES POLLUTE THE `default.project.json` FILE!**
* Update the [CHANGELOG.md](./CHANGELOG.md), following the convention given by [Keep a Changelog](keepachangelog.com)
* Verify it works in both light and dark mode, as well as switch between them
* Verify that all experimental options work with your change
* Verify that element (that is and not including: byt, folder, snippet, etc...) creation, modification and deletion works as expected.
* This is not an exhaustive list. There are definitely edge cases that @SpaceDice9 forgot about.
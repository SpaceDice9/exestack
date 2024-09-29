--[[--

[ HELP ]

BytExecutor2 is an in-studio script executor. Running code without playtesting requires you
to write code in the command bar. This is inefficient. Writing with a single line is
tedious and debugging is made much harder. BytExecutor2 (BE2 from now on) fixes this
by allowing you to run scripts in studio with minimal effort.

Starting up BE2, you will see that there are no scripts you can run. This is
because you have to create them yourself. Click the plus icon in the top left to get started.
This will create an "element" which is a generic object that BE2 organizes in the explorer.
Choose the `New Byt Script`. Congratulations! You created your first byt!

Well, you might be asking, what is a byt? A "byt" is what BE2 uses as a container to
store code that it can run later. Just think of it as a sort of "Studio Script".
When hovering over an element several icons will pop out to the left.
These are the primary interactions that you can click, such as execute, delete, etc. 
To edit a byt or open a folder, double-click it. Holding left click will allow you to
drag an element across the space. If you are confused on what the different icons do,
hovering over a button will give you a little tooltip. 

A pop-up menu can be accessed by right clicking certain elements. The two elements
that have pop-up menus is the element list, the name of an element, and the
execute icon on byts.

The element list pop-up menu is by far the largest and is too big to fully explain here,
but it should be pretty obvious what each option does. 

Right-clicking an element name gives you the option to rename it.

Right-clicking the execute icon only gives a pop-up menu if you have
Server/Client Execution enabled and if you are currently playtesting.
This lets you execute from either the server or client without having
to switch.

If you would like to quickly import from the command bar into a byt, you can go to
`File -> Customize Shortcuts` and type in `Import from Command Bar`. A suggested
shortcut is `Alt+I`.

--]]--
--[[--

[ DOCUMENTATION ]

To access the Byt library, do:
```
local BytLib = require(script.BytLib)
```


nil BytLib.Perf(amount: number, {[string]: function}, ...)
Runs fn a specified amount of times and uses the Performance Profiler to measure performance


nil BytLib.PerfSlow(amount: number, {[string]: function}, ...)
Runs fn a specified amount of times with a delay and uses the Performance Profiler to measure performance


any BytLib.Require(module: ModuleScript | string)
Similar to require() but does not lazy load when module is a ModuleScript. However
when it is a string it instead loads a BytScript as though it were a ModuleScript. Example:
```
BytLib.Require("TestFolder/TestByt") 
```
loads a byt called TestByt inside a folder named TestFolder.

It is recommended that you use this over require()


ModuleScript BytLib.ExportToModule(t: any, name: string?)
Exports a table to a module script. It's like a JSON file but for luau


string BytLib.Input(prompt: string?)
Asks the user for an input. An optional prompt can be specified, telling the user what input you expect from them.


--]]--

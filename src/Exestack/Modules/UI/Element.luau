--!strict

-- UI component for elements like folders, snippets, and byts.

type ElementData = any

type ElementFields = {
    data: ElementData,
}
type ElementImplementation = {
    __index: ElementImplementation,
    new: () -> Element,
}
export type Element = typeof(setmetatable({} :: ElementFields, {} :: ElementImplementation))

local Element: ElementImplementation
Element = {
    __index = Element,

    new = function(elementData: ElementData)
        local self = setmetatable({}, Element)

        self.data = data

        return self
    end,
}

return Element
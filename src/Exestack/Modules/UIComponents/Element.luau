--!strict

-- UI component for elements like folders, snippets, and byts.

type ElementData = any

type ElementFields = {
    data: ElementData,
}
type ElementImpl = {
    __index: ElementImpl,
    new: (ElementData) -> Element,
}
export type Element = typeof(setmetatable({} :: ElementFields, {} :: ElementImpl))

local Element: ElementImpl = {} :: ElementImpl
Element.__index = Element

function Element.new(elementData: ElementData)
    local self = setmetatable({}, Element)

    self.data = data

    return self
end

return Element
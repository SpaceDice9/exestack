local Apps = script.Parent
local ExestackFile = Apps.Parent
local plugin = ExestackFile.Parent

local Storage = ExestackFile.Storage.PerformanceProfiler
local Modules = ExestackFile.Modules

local References = require(Modules.References)
local Util = require(Modules.Util)
local Zeciar = require(Modules.Zeciar)
local Signal = require(Modules.SignalModule)

local AppList = require(Modules.AppList)

local PerfProfWidgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	true,
	700,
	400,
	700,
	400
)

local PerfProfWidget = plugin:CreateDockWidgetPluginGui("PerformanceProfiler", PerfProfWidgetInfo)
PerfProfWidget.Name = "PerformanceProfiler"
PerfProfWidget.Title = "Performance Profiler"

local Background = ExestackFile.UI.PerfProfBackground:Clone()
Background.Parent = PerfProfWidget

local InfoContainer = Background.InfoScrollFrame.InfoContainer
local BarContainer = Background.HistogramContainer.GraphContainer.BarContainer

local PluginSaveKeys = {
	Preferences = "Preferences"
}

local Preferences = References.Preferences
local PerfProfCategory = Preferences:AddCategory("Performance Profiler")
local SavedPreferences = plugin:GetSetting(PluginSaveKeys.Preferences) or {}

PerfProfCategory:AddSection("Summary")
PerfProfCategory:AddSetting({
	Name = "VerboseSummary",
	Descriptor = "Verbose Summary",
	Description = "Displays more information in the dataset summary",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
})

PerfProfCategory:AddSetting({
	Name = "StandardizedMoments",
	Descriptor = "Standardized Moments",
	Description = "Display the 3rd standardized moment (skewness) and the 4th standardized moment (kurtosis) in the summary",
	Type = "Boolean",

	DefaultState = false,
	Restrictions = {}
})

--PerfProfCategory:AddSpacing()
--PerfProfCategory:AddSection("Experimental")

--PerfProfCategory:AddSetting({
--	Name = "InferentialStatistics",
--	Descriptor = "Inferential Statistics",
--	Description = "Use inferential statistics to estimate true average performance and evaluate significant differences",
--	Type = "Boolean",

--	DefaultState = false,
--	SettingsState = SavedPreferences,
--	Restrictions = {}
--})

local CompiledPreferences = Preferences.Options

local Themes = {
	Dark = {
		Background = Color3.fromRGB(47, 47, 47),
		LowerBackground = Color3.fromRGB(27, 27, 27),
		Text = Color3.fromRGB(230, 230, 230),
		
		Border = Color3.fromRGB(0, 0, 0),
		Indent = Color3.fromRGB(37, 37, 37),
		Pressed = Color3.fromRGB(27, 27, 27),
		Indicator = Color3.fromRGB(255, 255, 255),
		
		Icon = Color3.fromRGB(200, 200, 200),
		
		InfoBox = Color3.fromRGB(57, 57, 57),
		InfoBoxName = Color3.fromRGB(87, 87, 87),
	},
	
	Light = {
		Background = Color3.fromRGB(217, 217, 217),
		LowerBackground = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(37, 37, 37),

		Border = Color3.fromRGB(100, 100, 100),
		Indent = Color3.fromRGB(180, 180, 180),
		Pressed = Color3.fromRGB(160, 160, 160),
		Indicator = Color3.fromRGB(0, 0, 0),

		Icon = Color3.fromRGB(47, 47, 47),

		InfoBox = Color3.fromRGB(180, 180, 180),
		InfoBoxName = Color3.fromRGB(200, 200, 200),
	}
}

local Theme = Themes.Dark



local xSize = 350
local padding = 2

local colorList = {
	Color3.fromRGB(0, 155, 230),
	Color3.fromRGB(50, 220, 50),
	Color3.fromRGB(160, 60, 230),
	Color3.fromRGB(255, 50, 50),
	Color3.fromRGB(230, 140, 50),
	Color3.fromRGB(250, 120, 200),
	Color3.fromRGB(190, 190, 20),
	Color3.fromRGB(0, 220, 200),
	Color3.fromRGB(180, 100, 30),
}

local InfoBoxList = {}
local HistogramData = {}

local InfoBox = {}
InfoBox.__index = InfoBox

function InfoBox:Ticket(text)
	local infoLabel = Storage.InfoLabel:Clone()
	infoLabel.Visible = self.Open
	infoLabel.Text = text
	infoLabel.Parent = self.Instance
	
	self:Resize()
end

function InfoBox:Spacing(spacing)
	local spacing = Storage.Spacing:Clone()
	spacing.Visible = self.Open
	
	if spacing then
		spacing.Size = UDim2.new(1, 0, 0, spacing)
	end
	
	spacing.Parent = self.Instance
	
	self:Resize()
end

function InfoBox:Resize()
	local size = 0
	
	for _, uiElement: Instance in self.Instance:GetChildren() do
		if uiElement:IsA("GuiBase2d") and uiElement.Visible then
			size += uiElement.AbsoluteSize.Y + 5
		end
	end
	
	self.Instance.Size = UDim2.new(1, 0, 0, size)
	
	resizeList(InfoContainer, InfoContainer.Parent)
	
	return size
end

function InfoBox:SetOpenState(opened)
	opened = opened or not self.Open
	self.Open = opened
	
	local infoBox = self.Instance
	
	if self.Open then
		infoBox.InfoBoxName.ImageLabel.Image = "rbxassetid://10709790948"
	else
		infoBox.InfoBoxName.ImageLabel.Image = "rbxassetid://10709791437"
	end

	for _, infoElement in infoBox:GetChildren() do
		if infoElement:IsA("GuiBase2d") and infoElement.Name ~= "InfoBoxName" then
			infoElement.Visible = self.Open
		end
	end

	self:Resize()
end

local HoverManager = {
	ElementHoverList = {},
	ElementEventsList = {},
	
	OnUnhoverAll = Signal.new(),
	OnHoverSome = Signal.new(),
}

function HoverManager.RegisterElement(element: Frame)
	local elementHoverList = HoverManager.ElementHoverList
	local elementEventsList = HoverManager.ElementEventsList
	
	local elementEvents = {
		Hover = Signal.new(),
		Unhover = Signal.new()
	}
	
	element.MouseEnter:Connect(function(x, y)
		local oldElement = elementHoverList[1]
		
		table.insert(elementHoverList, element)
		table.sort(elementHoverList, function(a, b)
			return a.ZIndex > b.ZIndex
		end)

		if elementHoverList[1] == element then
			if oldElement then
				local oldElementEvents = elementEventsList[oldElement]

				oldElementEvents.Unhover:Fire(x, y)
			end
			
			elementEvents.Hover:Fire(x, y)
		end
		
		if #elementHoverList == 1 then
			HoverManager.OnHoverSome:Fire(x, y)
		end
	end)
	
	element.MouseLeave:Connect(function(x, y)
		local elementIndex = table.find(elementHoverList, element)
		table.remove(elementHoverList, elementIndex)
		
		if elementIndex == 1 then
			local newElementEvents = elementEventsList[elementHoverList[1]]
			
			elementEvents.Unhover:Fire(x, y)
			
			if newElementEvents then
				newElementEvents.Hover:Fire(x, y)
			end
		end
		
		if #elementHoverList == 0 then
			HoverManager.OnUnhoverAll:Fire(x, y)
		end
	end)
	
	element.Destroying:Connect(function()
		elementEventsList[element] = nil
	end)
	
	elementEventsList[element] = elementEvents
end

function HoverManager.OnHover(element: Frame, fn)
	local elementEventsList = HoverManager.ElementEventsList
	local elementEvents = elementEventsList[element]
	
	if elementEvents then
		elementEvents.Hover:Connect(fn)
	end
end

function HoverManager.OnUnhover(element: Frame, fn)
	local elementEventsList = HoverManager.ElementEventsList
	local elementEvents = elementEventsList[element]

	if elementEvents then
		elementEvents.Unhover:Connect(fn)
	end
end



local PerformanceProfiler = {}

function createInfoBox(name, color, id)
	local infoBox = Storage.InfoBox:Clone()
	infoBox.InfoBoxName.Text = name or "Unknown Function"
	infoBox.InfoBoxName.ColorBox.BackgroundColor3 = color
	infoBox.Parent = InfoContainer
	
	local self = {
		Instance = infoBox,
		Open = true,
		Id = id
	}
	
	setmetatable(self, InfoBox)
	
	table.insert(InfoBoxList, self)
	
	infoBox.InfoBoxName.MouseButton1Up:Connect(function()
		self:SetOpenState()
	end)
	
	return self
end

function resizeList(list: GuiBase2d, scroller: ScrollingFrame, isX)
	local paddingInstance = list:FindFirstChildOfClass("UIListLayout")
	
	if not padding then
		warn("No padding found")
		
		return
	end
	
	local padding = paddingInstance.Padding.Offset
	local size = 0
	
	for _, uiElement in list:GetChildren() do
		if uiElement:IsA("GuiBase2d") then
			if isX then
				size += uiElement.AbsoluteSize.X + padding
			else
				size += uiElement.AbsoluteSize.Y + padding
			end
		end
	end
	
	size += padding
	
	if isX then
		scroller.CanvasSize = UDim2.fromOffset(size, 0)
	else
		scroller.CanvasSize = UDim2.fromOffset(0, size)
	end
end

function getTimeUnit(seconds)
	local unitName = "s"
	local multiplier = 1

	if math.abs(seconds) < 1e-3 then
		unitName = "μs"
		multiplier = 1e6
	elseif math.abs(seconds) < 1 then
		unitName = "ms"
		multiplier = 1e3
	end

	return unitName, multiplier
end

function truncateTimeWithBase(seconds, baseTime, hideUnit)
	local unitName, multiplier = getTimeUnit(baseTime)
	local units = seconds*multiplier
	local roundedUnits = math.round(units*10)/10

	if roundedUnits >= 10 and math.ceil(roundedUnits) ~= roundedUnits then
		roundedUnits = math.round(roundedUnits)
	end

	if roundedUnits <= 0 then
		--roundedUnits = "<0.1"
		roundedUnits = 0
	end

	if not hideUnit then
		roundedUnits = roundedUnits .. " " .. unitName
	end

	return roundedUnits
end

function truncateTime(seconds, hideUnit)
	return truncateTimeWithBase(seconds, seconds, hideUnit)
end

function truncate(n)
	local truncatedN = math.round(n*100)/100
	
	if math.abs(truncatedN) <= 0 then
		truncatedN = "<0.01"
	end

	return truncatedN
end

function getRangeFromSet(dataset)
	local distribution = table.clone(dataset)
	table.sort(distribution)
	
	local min, max = distribution[1], distribution[#distribution]
	
	return min, max
end

function clearList(frame)
	for _, uiElement: Instance in frame:GetChildren() do
		if (uiElement:IsA("GuiBase2d") or uiElement:IsA("Folder")) and not uiElement:GetAttribute("Undeletable") then
			uiElement:Destroy()
		end
	end
end



function getScale(n)
	local digits = math.floor(math.log(n, 10))
	local leading = n/(math.pow(10, digits))

	local max = math.pow(10, digits)

	return max
end

function getGraphBounds(min, max)
	local tens = getScale(max)
	local upper = math.ceil(max/tens)
	local lower = math.floor(min/tens)

	local subdivisions = upper - lower
	local divisions = 0

	repeat
		subdivisions = subdivisions*2
		divisions = divisions + 1
	until subdivisions > 8

	local barSize = math.floor(xSize/subdivisions) - padding

	return lower, upper, divisions, subdivisions, barSize, tens
end

type HistogramDataTable = {
	Index: number,
	Marker: GuiBase2d,
	Folder: Folder,
	Color: Color3,
	Name: string,
	Dataset: {number},
}

function toggleHistogram(histogramData)
	local folder = histogramData.Folder
	local marker = histogramData.Marker

	for _, otherFolder in BarContainer:GetChildren() do
		if otherFolder ~= folder then
			for _, bar in otherFolder:GetChildren() do
				bar.BackgroundTransparency = .75
			end
		end
	end

	for _, bar in folder:GetChildren() do
		bar.BackgroundTransparency = 0
	end

	for _, otherMarker in Background.LegendContainer.Legend:GetChildren() do
		if not otherMarker:IsA("GuiBase2d") then
			continue
		end

		if otherMarker ~= marker then
			otherMarker.BackgroundColor3 = Theme.Indent
		else
			marker.BackgroundColor3 = Theme.Pressed
		end
	end
end

function detoggleAllHistograms()
	for _, folder in BarContainer:GetChildren() do
		for _, bar in folder:GetChildren() do
			bar.BackgroundTransparency = 0
		end
	end

	for _, otherMarker in Background.LegendContainer.Legend:GetChildren() do
		if not otherMarker:IsA("GuiBase2d") then
			continue
		end

		otherMarker.BackgroundColor3 = Theme.Indent
	end
end

function generateHistogram(datasets)
	table.clear(HistogramData)
	local upperBound, lowerBound = 0, math.huge
	
	for _, dataset in datasets do
		local min, max = getRangeFromSet(dataset)
		
		if min < lowerBound then
			lowerBound = min
		end
		
		if max > upperBound then
			upperBound = max
		end
	end
	
	if lowerBound > upperBound then
		warn("Failed to generate histogram, lower bound is larger than upper bound")
	end
	
	local datasetList = {}
	local keys = {}
	
	for index, dataset in datasets do
		table.insert(datasetList, dataset)
		table.insert(keys, index)
	end
	
	local lowerGraphDigitBound, upperGraphDigitBound, divisions, subdivisions, barSize, tens = getGraphBounds(lowerBound, upperBound)
	local superdivisions = upperGraphDigitBound - lowerGraphDigitBound
	local lowerGraphBound, upperGraphBound = lowerGraphDigitBound*tens, upperGraphDigitBound*tens
	local range = upperGraphBound - lowerGraphBound
	
	local histograms = {}
	local barColors = colorList
	
	for i, dataset in datasetList do
		histograms[i] = table.create(subdivisions, 0)
		local histogram = histograms[i]
		
		for _, v in dataset do
			local index = math.min(subdivisions, math.floor((v - lowerGraphBound)/(range) * subdivisions) + 1)
			
			histogram[index] += 1
		end
	end
	
	if #histograms > #barColors then
		warn("Cannot have more than ", #barColors, " datasets")
	end
	
	local barOrderList = {}
	
	--gives a list of how bars should be ordered
	for i = 1, subdivisions do
		local barOrders = {}
		
		for histogramIndex, histogram in histograms do
			table.insert(barOrders, {
				HistogramIndex = histogramIndex,
				Height = histogram[i]
			})
		end
		
		table.sort(barOrders, function(a, b)
			return a.Height > b.Height
		end)
		
		barOrderList[i] = barOrders
	end
	
	local maxHeight = 0
	
	for _, histogram in histograms do
		for _, height in histogram do
			maxHeight = math.max(maxHeight, height)
		end
	end
	
	local _, upperHeightDigitBound, heightDivisions, heightSubdivisions, _, heightTens = getGraphBounds(0, maxHeight)
	local heightSuperdivisions = upperHeightDigitBound
	local upperHeightBound = upperHeightDigitBound*heightTens
	
	local histogramContainer = Background.HistogramContainer
	local xLabelAsset = Storage.xLabel
	local yLabelAsset = Storage.yLabel
	local indicatorAsset = Storage.Indicator

	clearList(histogramContainer.yAxisFrame)
	clearList(histogramContainer.xAxisFrame)
	clearList(histogramContainer.GraphContainer.IndicatorContainer)
	clearList(BarContainer)
	
	for i = 1, heightSuperdivisions do
		local indicator = indicatorAsset:Clone()
		indicator.Position = UDim2.new(0, 0, 1 - i/heightSuperdivisions, 0)
		indicator.Parent = histogramContainer.GraphContainer.IndicatorContainer
	end
	
	for i = 1, heightSubdivisions do
		local yAsset = yLabelAsset:Clone()
		yAsset.Text = math.ceil(upperHeightBound/heightSubdivisions * i)
		yAsset.Position = UDim2.new(0, -5, 1 - i/heightSubdivisions, 0)
		yAsset.Parent = histogramContainer.yAxisFrame
		
		local indicator = indicatorAsset:Clone()
		indicator.Transparency = .9
		indicator.Position = UDim2.new(0, 0, 1 - i/heightSubdivisions, 0)
		indicator.Parent = histogramContainer.GraphContainer.IndicatorContainer
	end
	
	for i = 1, superdivisions do
		local indicator = Storage.xIndicator:Clone()
		indicator.Position = UDim2.new(i/superdivisions, 0, 0, 0)
		indicator.Parent = histogramContainer.GraphContainer.IndicatorContainer
	end
	
	for i = 0, subdivisions do
		local xAsset = xLabelAsset:Clone()
		xAsset.Text = truncateTimeWithBase(lowerGraphBound + i*range/subdivisions, lowerGraphBound, true)
		xAsset.Position = UDim2.new(i/subdivisions, 0, 0, 0)
		xAsset.Parent = histogramContainer.xAxisFrame
		
		local indicator = Storage.xIndicator:Clone()
		indicator.Transparency = .9
		indicator.Position = UDim2.new(i/subdivisions, 0, 0, 0)
		indicator.Parent = histogramContainer.GraphContainer.IndicatorContainer
	end
	
	for index, _ in histograms do
		local folder = Instance.new("Folder")
		folder.Name = "Histogram" .. index
		folder.Parent = BarContainer
	end
	
	table.clear(HistogramData)
	clearList(Background.LegendContainer.Legend)

	for index, histogram in histograms do
		local marker = Storage.Marker:Clone()
		marker.ColorTab.BackgroundColor3 = barColors[index]
		marker.Label.Text = keys[index]
		marker.Parent = Background.LegendContainer.Legend
		
		local histogramDataTable = {
			Index = index,
			Marker = marker,
			Folder = BarContainer:FindFirstChild("Histogram" .. index),
			Color = barColors[index],
			Name = keys[index],
			Dataset = datasetList[index],
		} :: HistogramDataTable

		HistogramData[index] = histogramDataTable
		
		marker.MouseButton1Up:Connect(function()
			if marker.BackgroundColor3 == Theme.Pressed then
				detoggleAllHistograms()
			else
				toggleHistogram(HistogramData[index])
			end
		end)
	end
	
	resizeList(Background.LegendContainer.Legend, Background.LegendContainer, true)
	table.clear(HoverManager.ElementHoverList)
	
	for i = 1, subdivisions do
		local barOrders = barOrderList[i]

		for zindex, barData in barOrders do
			if barData.Height <= 0 then
				continue
			end
			
			local folder = BarContainer:FindFirstChild("Histogram" .. barData.HistogramIndex)
			
			local bar = Storage.Bar:Clone()
			bar.Size = UDim2.new(0, barSize - padding*2 - (zindex - 1)*2, barData.Height/upperHeightBound, 0)
			bar.BackgroundColor3 = barColors[barData.HistogramIndex]
			bar.Position = UDim2.new(i/subdivisions, -padding, 1, 0)
			bar.ZIndex = zindex + 5
			
			bar.Parent = folder
			
			bar.MouseButton1Up:Connect(function()
				toggleHistogram(HistogramData[barData.HistogramIndex])
			end)
			
			HoverManager.RegisterElement(bar)
			HoverManager.OnHover(bar, function()
				Background.HeightContainer.TextLabel.Text = barData.Height
			end)
		end
	end
	
	local baseUnit = getTimeUnit(lowerGraphBound)
	
	Background.HorizontalLabel.Text = "Time (in " .. baseUnit .. ")"
end

function clearInfoBoxes()
	for _, infoBox in InfoBoxList do
		infoBox.Instance:Destroy()
	end
	
	table.clear(InfoBoxList)
end

function clearHistograms()
	clearList(BarContainer)
end

function changeTheme(themeName)
	local themeData = Themes[themeName]
	Theme = themeData
	
	Background.BackgroundColor3 = themeData.Background
	Background.HeightContainer.BackgroundColor3 = themeData.LowerBackground
	Background.HeightContainer.BorderColor3 = themeData.Border
	Background.HeightContainer.TextLabel.TextColor3 = themeData.Text
	
	local marker = Storage.Marker
	marker.BackgroundColor3 = themeData.Indent
	marker.Label.TextColor3 = themeData.Text
	
	for _, marker in Background.LegendContainer.Legend:GetChildren() do
		if not marker:IsA("GuiBase2d") then
			continue
		end
		
		marker.BackgroundColor3 = themeData.Indent
		marker.Label.TextColor3 = themeData.Text
	end
	
	Background.HistogramContainer.xAxisFrame.BackgroundColor3 = themeData.Indicator
	Background.HistogramContainer.yAxisFrame.BackgroundColor3 = themeData.Indicator
	
	local ylabel = Storage.xLabel
	ylabel.TextColor3 = themeData.Text
	local xlabel = Storage.yLabel
	xlabel.TextColor3 = themeData.Text
	
	for _, label in Background.HistogramContainer.xAxisFrame:GetChildren() do
		if label:IsA("TextLabel") then
			label.TextColor3 = themeData.Text
		end
	end
	
	for _, label in Background.HistogramContainer.yAxisFrame:GetChildren() do
		if label:IsA("TextLabel") then
			label.TextColor3 = themeData.Text
		end
	end
	
	local yindicator = Storage.Indicator
	yindicator.BackgroundColor3 = themeData.Indicator
	local xindicator = Storage.xIndicator
	xindicator.BackgroundColor3 = themeData.Indicator
	
	for _, indicator in Background.HistogramContainer.GraphContainer.IndicatorContainer:GetChildren() do
		if indicator:IsA("Frame") then
			indicator.BackgroundColor3 = themeData.Indicator
		end
	end
	
	Background.InfoScrollFrame.BackgroundColor3 = themeData.LowerBackground
	
	local infoBox = Storage.InfoBox
	infoBox.BackgroundColor3 = themeData.InfoBox
	infoBox.InfoBoxName.BackgroundColor3 = themeData.InfoBoxName
	infoBox.InfoBoxName.TextColor3 = themeData.Text
	infoBox.InfoBoxName.ImageLabel.ImageColor3 = themeData.Icon
	infoBox.InfoBoxName.ColorBox.BorderColor3 = themeData.Border
	
	local infoTicket = Storage.InfoLabel
	infoTicket.TextColor3 = themeData.Text
	
	for _, infoBoxData in InfoBoxList do
		local infoBox = infoBoxData.Instance
		infoBox.BackgroundColor3 = themeData.InfoBox
		infoBox.InfoBoxName.BackgroundColor3 = themeData.InfoBoxName
		infoBox.InfoBoxName.TextColor3 = themeData.Text
		infoBox.InfoBoxName.ImageLabel.ImageColor3 = themeData.Icon
		infoBox.InfoBoxName.ColorBox.BorderColor3 = themeData.Border
		
		for _, infoTicket in infoBox:GetChildren() do
			if infoTicket.Name == "InfoLabel" then
				infoTicket.TextColor3 = themeData.Text
			end
		end
	end
	
	Background.HorizontalLabel.TextColor3 = themeData.Text
end

function PerformanceProfiler.graph(datasets)
	--clearList(InfoContainer)
	clearInfoBoxes()
	clearHistograms()
	
	generateHistogram(datasets)
	
	local verbose = CompiledPreferences.VerboseSummary
	
	--for index, dataset in datasets do
	for _, histogramData in HistogramData do
		local dataset = histogramData.Dataset
		
		local infoBox = createInfoBox(histogramData.Name, histogramData.Color, histogramData.Index)

		infoBox:Ticket("mean: " .. truncateTime(Zeciar.Mean(dataset)))
		infoBox:Ticket("sd: " .. truncateTime(Zeciar.SE(dataset)))
		infoBox:Spacing()

		local min, q1, median, q3, max = Zeciar.Quartiles(dataset)
		
		if verbose then
			infoBox:Ticket("min: " .. truncateTime(min))
		end
		
		infoBox:Ticket("q1: " .. truncateTime(q1))
		infoBox:Ticket("median: " .. truncateTime(median))
		infoBox:Ticket("q3: " .. truncateTime(q3))
		
		if verbose then
			infoBox:Ticket("max: " .. truncateTime(max))
			
			infoBox:Ticket("iqr: " .. truncateTime(Zeciar.IQR(dataset)))
			infoBox:Ticket("range: " .. truncateTime(Zeciar.Range(dataset)))
		end
		
		infoBox:Ticket("mad: " .. truncateTime(Zeciar.MAD(dataset)))
		
		if verbose then
			infoBox:Spacing()
			infoBox:Ticket("# of outliers: " .. #Zeciar.GetOutliers(dataset))
			infoBox:Ticket("mode: " .. truncateTime(Zeciar.Mode(dataset)))
		end
		
		if CompiledPreferences.StandardizedMoments then
			infoBox:Spacing()
			infoBox:Ticket("skewness: " .. truncate(Zeciar.Skewness(dataset)))
			infoBox:Ticket("kurtosis: " .. truncate(Zeciar.Kurtosis(dataset)))
		end
	end
	
	Util.ForceWidgetOpen(PerfProfWidget)
end

BarContainer.BackgroundButton.MouseButton1Up:Connect(function()
	detoggleAllHistograms()
end)

BarContainer.MouseMoved:Connect(function(x, y)
	Background.HeightContainer.Position = UDim2.fromOffset(x, y - 5)
end)

HoverManager.OnHoverSome:Connect(function()
	Background.HeightContainer.Visible = true
end)

HoverManager.OnUnhoverAll:Connect(function()
	Background.HeightContainer.Visible = false
end)

settings().Studio.ThemeChanged:Connect(function()
	changeTheme(tostring(settings().Studio.Theme))
end)

PerfProfCategory:Resize()
changeTheme(tostring(settings().Studio.Theme))

return PerformanceProfiler

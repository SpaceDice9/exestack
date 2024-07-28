--better? z quartile approx

--Module for performing basic inferential statistics
local function integral(a, b, f)
	local h = (b - a) / 1e3
	local sum = (f(a) + f(b))*h

	for i = 1, 1e3-1 do
		local x = a + i*h
		local y = f(x)

		if i%2 == 0 then
			sum += 2*y*h
		else
			sum += 4*y*h
		end
	end

	return sum*1/3
end


local Zeciar = {}

function Zeciar.Mean(distribution)
	local mean = 0
	
	for _, value in pairs(distribution) do
		mean = mean + value
	end
	
	return mean/#distribution
end

function Zeciar.Variance(distribution)
	local mean = Zeciar.Mean(distribution)
	local var = 0

	for _, value in pairs(distribution) do
		var = var + (value - mean)^2
	end
	
	var = var/#distribution

	return var
end

function Zeciar.SD(distribution)
	--local mean = Zeciar.Mean(distribution)
	local var = Zeciar.Variance(distribution)
	local sd = math.sqrt(var)
	
	return sd
end

function Zeciar.SE(distribution)
	local mean = Zeciar.Mean(distribution)
	local var = 0
	local se = 0

	for _, value in pairs(distribution) do
		var = var + (value - mean)^2
	end

	var = var/(#distribution - 1)
	se = math.sqrt(var)
	
	return se
end

function Zeciar.Quartiles(distribution)
	local dataset = table.clone(distribution)
	local numValues = #dataset
	table.sort(dataset)
	
	local medValue = 0
	
	local min = dataset[1]
	local max = dataset[numValues]
	local median = 0
	local q1 = 0
	local q3 = 0

	if numValues%2 == 0 then
		median = (dataset[math.floor(numValues/2)] + dataset[math.ceil(numValues/2)])/2
		medValue = (math.floor(numValues/2) + math.ceil(numValues/2))/2
	else
		median = (dataset[math.ceil(numValues/2)])
		medValue = math.ceil(numValues/2)
	end

	q1 = dataset[math.floor(medValue/2)]
	q3 = dataset[math.ceil(3*medValue/2)]
	
	return min, q1, median, q3, max
end

function Zeciar.Median(distribution)
	local _, _, median, _, _ = Zeciar.Quartiles(distribution)
	
	return median
end

function Zeciar.IQR(distribution)
	local _, q1, _, q3, _ = Zeciar.Quartiles(distribution)

	return q3 - q1
end

function Zeciar.Range(distribution)
	local min, _, _, _, max = Zeciar.Quartiles(distribution)
	
	return max - min
end

function Zeciar.MAD(distribution)
	local median = Zeciar.Median(distribution)
	local absoluteDeviations = {}
	
	for _, value in pairs(distribution) do
		table.insert(absoluteDeviations, math.abs(value - median))
	end
	
	local mad = Zeciar.Median(absoluteDeviations)
	
	return mad
end

--uses Tukey's fences at k = 1.5
function Zeciar.GetOutliers(distribution)
	local _, q1, _, q3, _ = Zeciar.Quartiles(distribution)
	local iqr = q3 - q1
	
	local outliers = {}
	
	for _, value in pairs(distribution) do
		if value > q3 + iqr*1.5 or value < q1 - iqr*1.5 then
			table.insert(outliers, value)
		end
	end
	
	return outliers
end

--uses 2 sigma distance from mean
function Zeciar.GetOutliers2(distribution)
	local mean = Zeciar.Mean(distribution)
	local sd = Zeciar.SD(distribution)

	local outliers = {}

	for _, value in pairs(distribution) do
		if value > mean + sd*2 and value < mean - sd*2 then
			table.insert(outliers, value)
		end
	end

	return outliers
end

function Zeciar.Mode(distribution)
	local occurences = {}
	local highestOccurence = 0
	local mode
	
	for _, value in pairs(distribution) do
		if occurences[tostring(value)] then
			occurences[tostring(value)] = occurences[tostring(value)] + 1
		else
			occurences[tostring(value)] = 1
		end
	end
	
	for _, value in pairs(distribution) do
		if occurences[tostring(value)] > highestOccurence then
			highestOccurence = occurences[tostring(value)]
			mode = value
		end
	end
	
	return mode
end

-- 3rd standardized moment
function Zeciar.Skewness(distribution)
	local skewness = 0
	local mean = Zeciar.Mean(distribution)
	local sd = Zeciar.SD(distribution)
	
	for _, x in pairs(distribution) do
		skewness = skewness + (x - mean)^3
	end
	
	skewness = skewness/(#distribution*sd^3)
	
	return skewness
end

function Zeciar.SampleSkewness(distribution)
	local skewness = 0
	local mean = Zeciar.Mean(distribution)
	local sd = Zeciar.SD(distribution)

	for _, x in pairs(distribution) do
		skewness = skewness + (x - mean)^3
	end

	skewness = skewness/((#distribution - 1)*sd^3)

	return skewness
end

-- 4th standardized moment
function Zeciar.Kurtosis(distribution)
	local kurtosis = 0
	local mean = Zeciar.Mean(distribution)
	local sd = Zeciar.SD(distribution)

	for _, x in pairs(distribution) do
		kurtosis = kurtosis + (x - mean)^4
	end

	kurtosis = kurtosis/(#distribution*sd^4)
	
	return kurtosis
end

function Zeciar.SampleKurtosis(distribution)
	local kurtosis = 0
	local mean = Zeciar.Mean(distribution)
	local sd = Zeciar.SD(distribution)

	for _, x in pairs(distribution) do
		kurtosis = kurtosis + (x - mean)^4
	end

	kurtosis = kurtosis/((#distribution - 1)*sd^4)

	return kurtosis
end



--Distributions
function StandardNormalFunc(x)
	return 1/math.sqrt(2*math.pi)*math.exp(-.5*x^2)
end

function Zeciar.NormalPDF(x: number, mean: number?, sd: number?)
	local z = (x - ( mean or 0 ))/( sd or 1 )

	return StandardNormalFunc(z)
end

function Zeciar.NormalCDF(lower: number, upper: number, mean: number?, sd: number?)
	local z_lower = math.clamp((lower - ( mean or 0 ))/( sd or 1 ), -10, 10)
	local z_upper = math.clamp((upper - ( mean or 0 ))/( sd or 1 ), -10, 10)

	return integral(z_lower, z_upper, StandardNormalFunc)
end


function tcoef(df)
	
end

local function rawtcdf(x, df)
	
end

local function getrawtcdf(df)
	return function(t)
		return rawtcdf(t, df)
	end
end

function Zeciar.StudentTPDF(x: number, df: number, mean: number?, se: number?)
	
end

function Zeciar.StudentTCDF(lower: number, upper: number, df: number, mean: number?, se: number?)
	
end

function Zeciar.StudentTQuantile(probability, df)
	
end




function Zeciar.ChiSqrPDF(a, b)

end

function Zeciar.ChiSqrCDF(a, b)

end



function Zeciar.tTest()
	
end

return Zeciar

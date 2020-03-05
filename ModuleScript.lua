--[[
	___________________________________________________________________________________________________________________
												
												!!!!! Important !!!!!
												_____________________
	
	Don't forget to require this module when attempting to use it!  The easiest way is just something like:
	
	local DynamicLightingModule = require(game:GetService("ServerScriptService"):WaitForChild("DynamicLightingModule"))
	
	at the start of your script
	
	___________________________________________________________________________________________________________________
	
	When calling the DynamicLightingSystem from another script and starting it, you can do so like:
		
		local DynamicLightingSystem = coroutine.create(DynamicLightingModule.DynamicLightingSystem)
		coroutine.resume(DynamicLightingSystem, 1)
		
		or
		
		DynamicLightingModule.DynamicLightingSystem()
		
		or
		DynamicLightingModule.DynamicLightingSystem(1)
	
	___________________________________________________________________________________________________________________
	
	Enjoy and please let me know if there are any bugs!!
	
	-https_KingPie
--]]

local module = {}

--// Services
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--// Primary Variables
local LightingSettings = {
	
	["Dawn"] = {
		TimeStart = 5,
		TimeEnd = 6.3,
		AdjustedStart = nil, --// Leave as is!
		AdjustedEnd = nil, --// Leave as is!
		Ambient = Color3.fromRGB(115, 78, 0),
		OutdoorAmbient = Color3.fromRGB(128, 124, 81),
		ShadowSoftness = .4,
		LightsOn = false,
	},

	["Day"] = {
		TimeStart = 6.3,
		TimeEnd = 17.3,
		AdjustedStart = nil, --// Leave as is!
		AdjustedEnd = nil, --// Leave as is!
		Ambient = Color3.fromRGB(136, 95, 0),
		OutdoorAmbient = Color3.fromRGB(128, 128, 128),
		ShadowSoftness = .65,
		LightsOn = false,
	},

	["Twilight"] = {
		TimeStart = 17.3,
		TimeEnd = 18.5,
		AdjustedStart = nil, --// Leave as is!
		AdjustedEnd = nil, --// Leave as is!
		Ambient = Color3.fromRGB(115, 78, 0),
		OutdoorAmbient = Color3.fromRGB(128, 109, 86),
		ShadowSoftness = .3,
		LightsOn = false,
	},

	["Night"] = {
		TimeStart = 18.5,
		TimeEnd = 5,
		AdjustedStart = nil, --// Leave as is!
		AdjustedEnd = nil, --// Leave as is!
		Ambient = Color3.fromRGB(104, 67, 0),
		OutdoorAmbient = Color3.fromRGB(95, 100, 128),
		ShadowSoftness = .1,
		LightsOn = true,
	}
}

local WeatherSettings = {
	
	["clear"] = {
		BlurSize = 0,
		SunRaysIntensity = .25,
		FogColor = Color3.fromRGB(99, 115, 138),
		FogEnd = 10000,
		Brightness = 2,
		--// Uses the Ambient of whatever the current Lighting Period is
		--// Uses the OutdoorAmbient of whatever the current Lighting Period is
		WaterReflectance = 1,
		WaterWaveSize = .35,
		WaterWaveSpeed = 9.77,
		LightsOn = false,
	},

	["snow"] = {
		BlurSize = 3,
		SunRaysIntensity = 0,
		FogColor = Color3.fromRGB(154, 171, 203),
		FogEnd = 700,
		Brightness = 2,
		--// Uses the Ambient of whatever the current Lighting Period is
		OutdoorAmbient = Color3.fromRGB(170,170,170),
		WaterReflectance = 1,
		WaterWaveSize = .35,
		WaterWaveSpeed = 9.77,
		LightsOn = false,
	},

	["blizzard"] = {
		BlurSize = 5,
		SunRaysIntensity = 0,
		FogColor = Color3.fromRGB(154, 171, 203),
		FogEnd = 150,
		Brightness = 2,
		Ambient = Color3.fromRGB(136, 95, 0),
		OutdoorAmbient = Color3.fromRGB(170,170,170),
		WaterReflectance = 1,
		WaterWaveSize = .35,
		WaterWaveSpeed = 9.77,
		LightsOn = true,
	},

	["rain"] = {
		BlurSize = 3,
		SunRaysIntensity = 0,
		FogColor = Color3.fromRGB(99,115,138),
		FogEnd = 800,
		Brightness = 0,
		Ambient = Color3.fromRGB(0, 0, 0),
		OutdoorAmbient = Color3.fromRGB(99,115,138),
		WaterReflectance = .2,
		WaterWaveSize = .6,
		WaterWaveSpeed = 10,
		LightsOn = true,
	},
	
	["thunder"] = {
		BlurSize = 5,
		SunRaysIntensity = 0,
		FogColor = Color3.fromRGB(42,47,54),
		FogEnd = 400,
		Brightness = 0,
		Ambient = Color3.fromRGB(75, 75, 75),
		OutdoorAmbient = Color3.fromRGB(42,47,54),
		WaterReflectance = .1,
		WaterWaveSize = .9,
		WaterWaveSpeed = 15,
		LightsOn = true,
	},
}

local ChangingLights = {
	["Parts"] = {
		--[[Windows = {
			InstanceName = "GlassWindow",
			UnlitColor = Color3.fromRGB(231, 231, 236),
			UnlitMaterial = Enum.Material.Glass,
			LitColor = Color3.fromRGB(218, 133, 65),
			LitMaterial = Enum.Material.Neon,
			ChanceOfIllumination = 0, --// Enter without percent sign (ex: 33% = 33)
			InstanceTable = nil, --//Leave as is!
		},
		
		Lanterns = {
			InstanceName = "GlassLantern",
			UnlitColor = Color3.fromRGB(231, 231, 236),
			UnlitMaterial = Enum.Material.Glass,
			LitColor = Color3.fromRGB(218, 133, 65),
			LitMaterial = Enum.Material.Neon,
			ChanceOfIllumination = 0, --// Enter without percent sign (ex: 33% = 33)
			InstanceTable = nil, --//Leave as is!
		},]]
	},
	
	["Lights"] = {
		--[[Lanterns = {
			InstanceName = "LanternLight",
			LitBrightness = .7,
			UnlitBrightness = 0,
			ChanceOfIllumination = 100, --// Enter without percent sign (ex: 33% = 33)
			InstanceTable = nil, --//Leave as is!
		},
		
		Windows = {
			InstanceName = "WindowLight",
			LitBrightness = 1,
			UnlitBrightness = 0,
			ChanceOfIllumination = 33, --// Enter without percent sign (ex: 33% = 33)
			InstanceTable = nil, --//Leave as is!
		},]]
	},
	
	["MultiInstanceLights"] = { --//Only use if utilizing randomization feature (unless you really want to, I can't stop you and it's not actually that big of a deal)
		Windows = {
			ReferencePartName = "WindowLight",
			ReferencePartType = "Light", --// Either Light or Part.  Leave as nil if you want zero changes on the reference part
			Brightness = 1, --// Arbitrary if the ReferencePartType is Part
			UnlitColor = Color3.fromRGB(231, 231, 236), --// Arbitrary if the ReferencePartType is Light
			UnlitMaterial = Enum.Material.Glass, --// Arbitrary if the ReferencePartType is Light
			LitColor = Color3.fromRGB(218, 133, 65), --// Arbitrary if the ReferencePartType is Light 218, 133, 65
			LitMaterial = Enum.Material.Neon, --// Arbitrary if the ReferencePartType is Light
			InstanceTable = nil, --//Leave as is!
			RelatedParts = {
				{
					RelatedName = nil, --// If set to nil will just reference the parent without checking the parent's name.  The name must be specified if the relation is a child because ROBLOX ugh
					RelationType = "Parent", 
					InstanceType = "Part", --// Light or Part
					UnlitColor = Color3.fromRGB(231, 231, 236), --// Arbitrary if the InstanceType is Light
					UnlitMaterial = Enum.Material.Glass, --// Arbitrary if the InstanceType is Light
					LitColor = Color3.fromRGB(218, 133, 65), --// Arbitrary if the InstanceType is Light
					LitMaterial = Enum.Material.Neon, --// Arbitrary if the InstanceType is Light
					LitBrightness = 1, --// Arbitrary if the InstanceType is Part
					UnlitBrightness = 0, --// Arbitrary if the InstanceType is Part
				}
			},
			ChanceOfIllumination = 66
		},
		
		Lanterns = {
			ReferencePartName = "LanternLight",
			ReferencePartType = "Light", --// Either Light or Part.  Leave as nil if you want zero changes on the reference part
			Brightness = .7, --// Arbitrary if the ReferencePartType is Part
			UnlitColor = Color3.fromRGB(231, 231, 236), --// Arbitrary if the ReferencePartType is Light
			UnlitMaterial = Enum.Material.Glass, --// Arbitrary if the ReferencePartType is Light
			LitColor = Color3.fromRGB(218, 133, 65), --// Arbitrary if the ReferencePartType is Light
			LitMaterial = Enum.Material.Neon, --// Arbitrary if the ReferencePartType is Light
			InstanceTable = nil, --//Leave as is!
			RelatedParts = {
				{
					RelatedName = nil, --// If set to nil will just reference the parent without checking the parent's name.  The name must be specified if the relation is a child because ROBLOX ugh
					RelationType = "Parent", 
					InstanceType = "Part", --// Light or Part
					UnlitColor = Color3.fromRGB(231, 231, 236), --// Arbitrary if the InstanceType is Light
					UnlitMaterial = Enum.Material.Glass, --// Arbitrary if the InstanceType is Light
					LitColor = Color3.fromRGB(218, 133, 65), --// Arbitrary if the InstanceType is Light
					LitMaterial = Enum.Material.Neon, --// Arbitrary if the InstanceType is Light
					LitBrightness = .7, --// Arbitrary if the InstanceType is Part
					UnlitBrightness = 0, --// Arbitrary if the InstanceType is Part
				}
			},
			ChanceOfIllumination = 66
		},
	}
}
--// Secondary Varaibles
local Weather = false --// Indicates non-clear or non-snow weather
local LightsActive = false --// Defaults to off, adjust if necessary

local CurrentLightingPeriod --// Held primarily to see if a tween change is necessary

local LightingTweenInformation = TweenInfo.new(
	20,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local WeatherTweenInformation = TweenInfo.new(
	10,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

--// Core Function
function module.DynamicLightingSystem(WaitTime) --// This can be the sole thing called and this will properly set up and run the Dynamic Lighting system as a coroutine
	if WaitTime == nil then
		WaitTime = 1 --// Default value
	end
	
	while wait(WaitTime) do
		if CurrentLightingPeriod == nil then --// Initial set up of the Lighting Period
			CurrentLightingPeriod = module.GetLightingPeriod() --// Records the current Lighting Period
			if Weather == false then
				module.SetLighting(CurrentLightingPeriod) --// Activates the lighting settings for the current Lighting Period if there is no weather
			end
			module.AdjustedStart() --// Sets up the adjusted start ranges
			module.HandleLightsLightingPeriod(CurrentLightingPeriod, "Set") --Handles whether lights need to be turned on for the current Lighting Period
			
			if Lighting:FindFirstChildWhichIsA("SunRaysEffect") == false then --// Creates a Sun Rays effect if necessary
				local SunRays = Instance.new("SunRaysEffect")
				SunRays.Parent = Lighting
			end
			
			if Lighting:FindFirstChildWhichIsA("BlurEffect") == false then --// Creates a Blur effect fi necessary
				local Blur = Instance.new("BlurEffect")
				Blur.Parent = Lighting
			end
		end
		
		if Weather == false then
			if CurrentLightingPeriod ~= module.CheckForPeriodChange() then --// Checks for impending Lighting Period changes
				module.TweenLightingSettings(module.CheckForPeriodChange()) --// Starts tweening light settings when a LightingPeriod change is detected
			end
		end
	end
end

--// Get Functions
function module.GetLightingSettings(LightingSettings) --// Gets the LightingSettings table
	return LightingSettings
end

function module.GetWeatherSettings(WeatherSettings) --// Gets the WeatherSettings table
	return WeatherSettings
end

function module.GetLightingPeriod() --// Gets the index name of the current LightingPeriod that the ClockTime is within
	local CurrentTime = Lighting.ClockTime
	
	for LightingPeriod, PeriodSettings in pairs(LightingSettings) do
		for x, c in pairs (PeriodSettings) do
			if PeriodSettings.TimeStart < PeriodSettings.TimeEnd then --// Expected (ex: starts at 5 ends at 13)
				if CurrentTime >= PeriodSettings.TimeStart and CurrentTime < PeriodSettings.TimeEnd then
					return LightingPeriod
				end
			else --// Slightly abnormal cases where times go over midnight (ex: starts at 22 ends at 4)
				if CurrentTime >= PeriodSettings.TimeStart and CurrentTime < 23.99 or CurrentTime < PeriodSettings.TimeEnd then
					return LightingPeriod
				end
			end
		end
	end
end

--// (Pretty much the same code as above, but this checks with the AdjustedStart)
function module.CheckForPeriodChange() --// Gets the index of whatever adjustment period the current ClockTime falls within
	local CurrentTime = Lighting.ClockTime
	
	for LightingPeriod, PeriodSettings in pairs(LightingSettings) do
		for x, c in pairs (PeriodSettings) do
			if PeriodSettings.AdjustedStart < PeriodSettings.AdjustedEnd then --// Expected (ex: starts at 5 ends at 13)
				if CurrentTime >= PeriodSettings.AdjustedStart and CurrentTime < PeriodSettings.AdjustedEnd then
					return LightingPeriod
				end
			else --// Slightly abnormal cases where times go over midnight (ex: starts at 22 ends at 4)
				if CurrentTime >= PeriodSettings.AdjustedStart and CurrentTime < 23.99 or CurrentTime < PeriodSettings.AdjustedEnd then
					return LightingPeriod
				end
			end
		end
	end
end

--//Set Functions
function module.SetWeather(WeatherType) --// Immediately applies the lighting settings for a weather period
	local LightingPeriodSettings = LightingSettings[module.GetLightingPeriod()]
	
	if WeatherType == "rain" or WeatherType == "thunder" or WeatherType == "blizzard" then --// These each have unique and constant OutdoorAmbients and Ambient settings
		
		Weather = true
		
		Lighting.FogEnd = WeatherSettings[WeatherType].FogEnd
		Lighting.FogColor = WeatherSettings[WeatherType].FogColor
		Lighting.Ambient = WeatherSettings[WeatherType].Ambient
		Lighting.OutdoorAmbient = WeatherSettings[WeatherType].OutdoorAmbient
		Lighting.Brightness = WeatherSettings[WeatherType].Brightness
		
		local SunRaysEffect = Lighting:FindFirstChildWhichIsA("SunRaysEffect")
		SunRaysEffect.Intensity = WeatherSettings[WeatherType].SunRaysIntensity
		
		local BlurEffect = Lighting:FindFirstChildWhichIsA("BlurEffect")
		BlurEffect.Size = WeatherSettings[WeatherType].BlurSize
		
		local Terrain = Workspace.Terrain
		Terrain.WaterReflectance = WeatherSettings[WeatherType].WaterReflectance
		Terrain.WaterWaveSize = WeatherSettings[WeatherType].WaterWaveSize
		Terrain.WaterWaveSpeed = WeatherSettings[WeatherType].WaterWaveSpeed
		
	elseif WeatherType == "snow" then --// Has a unique and constant OutdoorAmbient setting but uses the Ambient setting of whatever the current Lighting Period is
		
		Weather = false
		
		Lighting.FogEnd = WeatherSettings[WeatherType].FogEnd
		Lighting.FogColor = WeatherSettings[WeatherType].FogColor
		Lighting.Ambient = LightingPeriodSettings.Ambient
		Lighting.OutdoorAmbient = WeatherSettings[WeatherType].OutdoorAmbient
		Lighting.Brightness = WeatherSettings[WeatherType].Brightness
		
		local SunRaysEffect = Lighting:FindFirstChildWhichIsA("SunRaysEffect")
		SunRaysEffect.Intensity = WeatherSettings[WeatherType].SunRaysIntensity
		
		local BlurEffect = Lighting:FindFirstChildWhichIsA("BlurEffect")
		BlurEffect.Size = WeatherSettings[WeatherType].BlurSize
		
		local Terrain = Workspace.Terrain
		Terrain.WaterReflectance = WeatherSettings[WeatherType].WaterReflectance
		Terrain.WaterWaveSize = WeatherSettings[WeatherType].WaterWaveSize
		Terrain.WaterWaveSpeed = WeatherSettings[WeatherType].WaterWaveSpeed
		
	elseif WeatherType == "clear" then --// Uses the Ambient and OutdoorAmbient settings of whatever the current Lighting Period is
		
		Weather = false
		
		Lighting.FogEnd = WeatherSettings[WeatherType].FogEnd
		Lighting.FogColor = WeatherSettings[WeatherType].FogColor
		Lighting.Ambient = LightingPeriodSettings.Ambient
		Lighting.OutdoorAmbient = LightingPeriodSettings.OutdoorAmbient
		Lighting.Brightness = WeatherSettings[WeatherType].Brightness
		
		local SunRaysEffect = Lighting:FindFirstChildWhichIsA("SunRaysEffect")
		SunRaysEffect.Intensity = WeatherSettings[WeatherType].SunRaysIntensity
		
		local BlurEffect = Lighting:FindFirstChildWhichIsA("BlurEffect")
		BlurEffect.Size = WeatherSettings[WeatherType].BlurSize
		
		local Terrain = Workspace.Terrain
		Terrain.WaterReflectance = WeatherSettings[WeatherType].WaterReflectance
		Terrain.WaterWaveSize = WeatherSettings[WeatherType].WaterWaveSize
		Terrain.WaterWaveSpeed = WeatherSettings[WeatherType].WaterWaveSpeed
	end
	module.HandleLightsWeather(WeatherType, "Set")
end

function module.SetLighting(LightingPeriod) --// Immediately applies the light settings for the current lighting period
	Lighting.Ambient = LightingSettings[LightingPeriod].Ambient
	Lighting.OutdoorAmbient = LightingSettings[LightingPeriod].OutdoorAmbient
	Lighting.ShadowSoftness = LightingSettings[LightingPeriod].ShadowSoftness
end

--// Handling Functions
function module.HandleLightsLightingPeriod(LightingPeriod, Type) --// Handles turning on/off lights for the Lighting Periods
	if LightsActive ~= LightingSettings[LightingPeriod].LightsOn then --// Lights must be either turned on or off
		local ActivateLights
		
		if LightsActive == false and LightingSettings[LightingPeriod].LightsOn == true then
			ActivateLights = true
			LightsActive = true
		end
		
		if LightsActive == true and LightingSettings[LightingPeriod].LightsOn == false then
			ActivateLights = false
			LightsActive = false
		end
		
		if Type == "Set" then
			module.SetLights(ActivateLights)
		elseif Type == "Tween" then
			module.TweenLights(ActivateLights)
		else
			module.TweenLights(ActivateLights)
			warn("Type not specified in light handling, assuming Tween")
		end
	end
end

function module.HandleLightsWeather(WeatherType, Type) --// Handles turning on/off lights for Weather periods
	if LightsActive ~= WeatherSettings[WeatherType].LightsOn then --// Lights must be either turned on or off
		local ActivateLights
		
		if LightsActive == false and WeatherSettings[WeatherType].LightsOn == true then
			ActivateLights = true
			LightsActive = true
		end
		
		if LightsActive == true and WeatherSettings[WeatherType].LightsOn == false then
			ActivateLights = false
			LightsActive = false
		end
		
		if Type == "Set" then
			module.SetLights(ActivateLights)
		elseif Type == "Tween" then
			module.TweenLights(ActivateLights)
		else
			module.TweenLights(ActivateLights)
			warn("Type not specified in light handling, assuming Tween")
		end
	end
end

--// Tween Functions
function module.TweenLightingSettings(LightingPeriod) --// Tweens the lighting settings to the designated Lighting Period
	local Tween = TweenService:Create(Lighting, LightingTweenInformation, {Ambient = LightingSettings[LightingPeriod].Ambient, OutdoorAmbient = LightingSettings[LightingPeriod].OutdoorAmbient, ShadowSoftness = LightingSettings[LightingPeriod].ShadowSoftness})
	Tween:Play()
	Tween.Completed:Connect(function()
		wait(1)
		CurrentLightingPeriod = module.GetLightingPeriod()
	end)
	module.HandleLightsLightingPeriod(LightingPeriod, "Tween")
end

function module.TweenWeather(WeatherType) --Tweens the lighting settings to the designated Weather
	if WeatherType == "rain" or WeatherType == "thunder" or WeatherType == "blizzard" then --// These each have unique and constant OutdoorAmbients and Ambient settings
		Weather = true
		
		local Tween1 = TweenService:Create(Lighting, WeatherTweenInformation, {FogEnd = WeatherSettings[WeatherType].FogEnd, FogColor = WeatherSettings[WeatherType].FogColor, Ambient = WeatherSettings[WeatherType].Ambient, OutdoorAmbient = WeatherSettings[WeatherType].OutdoorAmbient, Brightness = WeatherSettings[WeatherType].Brightness})
		local Tween2 = TweenService:Create(Lighting:FindFirstChildWhichIsA("SunRaysEffect"), WeatherTweenInformation, {Intensity = WeatherSettings[WeatherType].SunRaysIntensity})
		local Tween3 = TweenService:Create(Lighting:FindFirstChildWhichIsA("BlurEffect"), WeatherTweenInformation, {Size = WeatherSettings[WeatherType].BlurSize})
		local Tween4 = TweenService:Create(Workspace.Terrain, WeatherTweenInformation, {WaterReflectance = WeatherSettings[WeatherType].WaterReflectance, WaterWaveSize = WeatherSettings[WeatherType].WaterWaveSize, WaterWaveSpeed = WeatherSettings[WeatherType].WaterWaveSpeed})
		
		Tween1:Play()
		Tween2:Play()
		Tween3:Play()
		Tween4:Play()
		
	elseif WeatherType == "snow" then --// Has a unique and constant OutdoorAmbient setting but uses the Ambient setting of whatever the current Lighting Period is
		
		Weather = false
		
		local Tween1 = TweenService:Create(Lighting, WeatherTweenInformation, {FogEnd = WeatherSettings[WeatherType].FogEnd, FogColor = WeatherSettings[WeatherType].FogColor, Ambient = module.GetLightingPeriod().Ambient, OutdoorAmbient = WeatherSettings[WeatherType].OutdoorAmbient, Brightness = WeatherSettings[WeatherType].Brightness})
		local Tween2 = TweenService:Create(Lighting:FindFirstChildWhichIsA("SunRaysEffect"), WeatherTweenInformation, {Intensity = WeatherSettings[WeatherType].SunRaysIntensity})
		local Tween3 = TweenService:Create(Lighting:FindFirstChildWhichIsA("BlurEffect"), WeatherTweenInformation, {Size = WeatherSettings[WeatherType].BlurSize})
		local Tween4 = TweenService:Create(Workspace.Terrain, WeatherTweenInformation, {WaterReflectance = WeatherSettings[WeatherType].WaterReflectance, WaterWaveSize = WeatherSettings[WeatherType].WaterWaveSize, WaterWaveSpeed = WeatherSettings[WeatherType].WaterWaveSpeed})
		
		Tween1:Play()
		Tween2:Play()
		Tween3:Play()
		Tween4:Play()
		
	elseif WeatherType == "clear" then --// Uses the Ambient and OutdoorAmbient settings of whatever the current Lighting Period is
		
		Weather = false
		
		local Tween1 = TweenService:Create(Lighting, WeatherTweenInformation, {FogEnd = WeatherSettings[WeatherType].FogEnd, FogColor = WeatherSettings[WeatherType].FogColor, Ambient = module.GetLightingPeriod().Ambient, OutdoorAmbient = module.GetLightingPeriod().OutdoorAmbient, Brightness = WeatherSettings[WeatherType].Brightness})
		local Tween2 = TweenService:Create(Lighting:FindFirstChildWhichIsA("SunRaysEffect"), WeatherTweenInformation, {Intensity = WeatherSettings[WeatherType].SunRaysIntensity})
		local Tween3 = TweenService:Create(Lighting:FindFirstChildWhichIsA("BlurEffect"), WeatherTweenInformation, {Size = WeatherSettings[WeatherType].BlurSize})
		local Tween4 = TweenService:Create(Workspace.Terrain, WeatherTweenInformation, {WaterReflectance = WeatherSettings[WeatherType].WaterReflectance, WaterWaveSize = WeatherSettings[WeatherType].WaterWaveSize, WaterWaveSpeed = WeatherSettings[WeatherType].WaterWaveSpeed})
		
		Tween1:Play()
		Tween2:Play()
		Tween3:Play()
		Tween4:Play()
	end
	module.HandleLightsWeather(WeatherType, "Tween")
end

--// Advanced Functions
function module.SetLights(ActivateLights) --// Immediately sets the lights to an on/off status
	for i, v in pairs (ChangingLights) do
		if i == "Parts" then
			for x, c in pairs (v) do
				if c.InstanceTable == nil then
					c.InstanceTable = module.GatherInstanceTable(c.InstanceName)
				end
				
				if ActivateLights == true then
					for n, m in pairs (c.InstanceTable) do
						if module.LightRandomIllumination(c.ChanceOfIllumination) == true then
							m.Color = c.LitColor
							m.Material = c.LitMaterial
						end
					end
				elseif ActivateLights == false then
					for n, m in pairs (c.InstanceTable) do
						m.Color = c.UnlitColor
						m.Material = c.UnlitMaterial
					end
				else
					warn("[ABC] Hmm, this warning should never be hit - contact https_KingPie!!")
				end
			end
		elseif i == "Lights" then
			for x, c in pairs (v) do
				if c.InstanceTable == nil then
					c.InstanceTable = module.GatherInstanceTable(c.InstanceName)
				end
				
				if ActivateLights == true then
					for n, m in pairs (c.InstanceTable) do
						if module.LightRandomIllumination(c.ChanceOfIllumination) == true then
							m.Brightness = c.LitBrightness
						end
					end
				elseif ActivateLights == false then
					for n, m in pairs (c.InstanceTable) do
						m.Brightness = c.UnlitBrightness
					end
				else
					warn("[DEF] Hmm, this warning should never be hit - contact https_KingPie!!")
				end
			end
		elseif i == "MultiInstanceLights" then
			for x, c in pairs (v) do
				if c.InstanceTable == nil then
					c.InstanceTable = module.GatherInstanceTable(c.ReferencePartName)
				end
				
				if ActivateLights == true then
					for n, TabulatedInstance in pairs (c.InstanceTable) do
						if module.LightRandomIllumination(c.ChanceOfIllumination) == true then
							
							if c.ReferencePartType ~= nil then
								if c.ReferencePartType == "Light" then
									if TabulatedInstance:IsA("PointLight") or TabulatedInstance:IsA("SpotLight") or TabulatedInstance:IsA("SurfaceLight") then
										TabulatedInstance.Brightness = c.LitBrightness
									else
										warn("Attempt to perform property changes for a light on a non-light")
									end
								elseif TabulatedInstance.ReferencePartType == "Part" then
									if c:IsA("BasePart") then
										TabulatedInstance.Color = c.LitColor
										TabulatedInstance.Material = c.LitMaterial
									else
										warn("Attempt to perform property changes for a part on a non-part")
									end
								end
							end
							
							for a, b in pairs (c.RelatedParts) do
								if b.RelationType == "Parent" then
									if b.RelatedName == TabulatedInstance.Parent.Name or b.RelatedName == nil then
										local TargetInstance = TabulatedInstance.Parent
										
										if b.InstanceType == "Light" then
											if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
												TargetInstance.Brightness = b.LitBrightness
											else
												warn("Attempt to perform property changes for a light on a non-light")
											end
										elseif b.InstanceType == "Part" then
											if TargetInstance:IsA("BasePart") then
												TargetInstance.Color = b.LitColor
												TargetInstance.Material = b.LitMaterial
											else
												warn("Attempt to perform property changes for a part on a non-part")
											end	
										end
									end
									
								elseif b.RelationType == "Child" then
									if TabulatedInstance:FindFirstChild(b.RelatedName) then
										local TargetInstance = TabulatedInstance:FindFirstChild(b.RelatedName)
										
										if b.InstanceType == "Light" then
											if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
												TargetInstance.Brightness = b.LitBrightness
											else
												warn("Attempt to perform property changes for a light on a non-light")
											end
										elseif b.InstanceType == "Part" then
											if TargetInstance:IsA("BasePart") then
												TargetInstance.Color = b.LitColor
												TargetInstance.Material = b.LitMaterial
											else
												warn("Attempt to perform property changes for a part on a non-part")
											end	
										end
									end
								end
							end
						end
					end
					
				elseif ActivateLights == false then
					for n, TabulatedInstance in pairs (c.InstanceTable) do
						for a, b in pairs (c.RelatedParts) do
							if b.RelationType == "Parent" then
								if b.RelatedName == TabulatedInstance.Parent.Name or b.RelatedName == nil then
									local TargetInstance = TabulatedInstance.Parent
									
									if b.InstanceType == "Light" then
										if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
											TargetInstance.Brightness = b.UnlitBrightness
										else
											warn("Attempt to perform property changes for a light on a non-light")
										end
									elseif b.InstanceType == "Part" then
										if TargetInstance:IsA("BasePart") then
											TargetInstance.Color = b.UnlitColor
											TargetInstance.Material = b.UnlitMaterial
										else
											warn("Attempt to perform property changes for a part on a non-part")
										end	
									end
								end
								
							elseif b.RelationType == "Child" then
								if TabulatedInstance:FindFirstChild(b.RelatedName) then
									local TargetInstance = TabulatedInstance:FindFirstChild(b.RelatedName)
									
									if b.InstanceType == "Light" then
										if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
											TargetInstance.Brightness = b.UnlitBrightness
										else
											warn("Attempt to perform property changes for a light on a non-light")
										end
									elseif b.InstanceType == "Part" then
										if TargetInstance:IsA("BasePart") then
											TargetInstance.Color = b.UnitColor
											TargetInstance.Material = b.UnitMaterial
										else
											warn("Attempt to perform property changes for a part on a non-part")
										end	
									end
								end
							end
						end
					end
				else
					warn("[GHI] Hmm, this warning should never be hit - contact https_KingPie!!")
				end
			end
		else
			warn("Index: ".. i .. " not recognized")
		end
	end
end

function module.TweenLights(ActivateLights) --Tweens lights to an on/off status
		for i, v in pairs (ChangingLights) do
		if i == "Parts" then
			for x, c in pairs (v) do
				if c.InstanceTable == nil then
					c.InstanceTable = module.GatherInstanceTable(c.InstanceName)
				end
				
				if ActivateLights == true then
					for n, m in pairs (c.InstanceTable) do
						if module.LightRandomIllumination(c.ChanceOfIllumination) == true then
							local Tween = TweenService:Create(m, LightingTweenInformation, {Color = c.LitColor})
							Tween:Play()
							Tween.Completed:Connect(function()
								m.Material = c.LitMaterial
							end)
						end
					end
				elseif ActivateLights == false then
					for n, m in pairs (c.InstanceTable) do
						local Tween = TweenService:Create(m, LightingTweenInformation, {Color = c.UnlitColor})
						Tween:Play()
						Tween.Completed:Connect(function()
							m.Material = c.LitMaterial
						end)
					end
				else
					warn("[ABC] Hmm, this warning should never be hit - contact https_KingPie!!")
				end
			end
		elseif i == "Lights" then
			for x, c in pairs (v) do
				if c.InstanceTable == nil then
					c.InstanceTable = module.GatherInstanceTable(c.InstanceName)
				end
				
				if ActivateLights == true then
					for n, m in pairs (c.InstanceTable) do
						if module.LightRandomIllumination(c.ChanceOfIllumination) == true then
							local Tween = TweenService:Create(m, LightingTweenInformation, {Brightness = c.LitBrightness})
							Tween:Play()
						end
					end
				elseif ActivateLights == false then
					for n, m in pairs (c.InstanceTable) do
						local Tween = TweenService:Create(m, LightingTweenInformation, {Brightness = c.UnlitBrightness})
						Tween:Play()
					end
				else
					warn("[DEF] Hmm, this warning should never be hit - contact https_KingPie!!")
				end
			end
		elseif i == "MultiInstanceLights" then
			for x, c in pairs (v) do --// Access table of settings for each type of multiinstance lights (value of each setting table being c)
				if c.InstanceTable == nil then
					c.InstanceTable = module.GatherInstanceTable(c.ReferencePartName)
				end
				
				--// Turns lights on
				if ActivateLights == true then
					for n, TabulatedInstance in pairs (c.InstanceTable) do --// Access table of instances (value being TabulatedInstance)
						if module.LightRandomIllumination(c.ChanceOfIllumination) == true then
							--// Handles the reference part
							if c.ReferencePartType ~= nil then
								if c.ReferencePartType == "Light" then
									if TabulatedInstance:IsA("PointLight") or TabulatedInstance:IsA("SpotLight") or TabulatedInstance:IsA("SurfaceLight") then
										local Tween = TweenService:Create(TabulatedInstance, LightingTweenInformation, {Brightness = c.LitBrightness})
										Tween:Play()
									else
										warn("Attempt to perform property changes for a light on a non-light")
									end
								elseif TabulatedInstance.ReferencePartType == "Part" then
									if c:IsA("BasePart") then
										local Tween = TweenService:Create(TabulatedInstance, LightingTweenInformation, {Color = c.LitColor})
										Tween:Play()
										Tween.Completed:Connect(function()
											TabulatedInstance.Material = c.LitMaterial
										end)
									else
										warn("Attempt to perform property changes for a part on a non-part")
									end
								end
							end
							
							--// Handles the referenced parts
							for a, b in pairs (c.RelatedParts) do --// Access tables of properties for the Related Parts (value of each setting table being b)
								if b.RelationType == "Parent" then
									if b.RelatedName == TabulatedInstance.Parent.Name or b.RelatedName == nil then
										local TargetInstance = TabulatedInstance.Parent
										
										if b.InstanceType == "Light" then
											if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
												local Tween = TweenService:Create(TargetInstance, LightingTweenInformation, {Brightness = b.LitBrightness})
												Tween:Play()
											else
												warn("Attempt to perform property changes for a light on a non-light")
											end
										elseif b.InstanceType == "Part" then
											if TargetInstance:IsA("BasePart") then
												local Tween = TweenService:Create(TargetInstance, LightingTweenInformation, {Color = b.LitColor}) --TweenService:Create property named 'Material' cannot be tweened due to type mismatch (property is a 'int', but given type is 'token')
												Tween:Play()
												Tween.Completed:Connect(function()
													TargetInstance.Material = b.LitMaterial
												end)
											else
												warn("Attempt to perform property changes for a part on a non-part")
											end	
										end
									end
									
								elseif b.RelationType == "Child" then
									if TabulatedInstance:FindFirstChild(b.RelatedName) then
										local TargetInstance = TabulatedInstance:FindFirstChild(b.RelatedName)
										
										if b.InstanceType == "Light" then
											if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
												local Tween = TweenService:Create(TargetInstance, LightingTweenInformation, {Brightness = b.LitBrightness})
												Tween:Play()
											else
												warn("Attempt to perform property changes for a light on a non-light")
											end
										elseif b.InstanceType == "Part" then
											if TargetInstance:IsA("BasePart") then
												local Tween = TweenService:Create(TargetInstance, LightingTweenInformation, {Color = b.LitColor})
												Tween:Play()
												Tween.Completed:Connect(function()
													TargetInstance.Material = b.LitMaterial
												end)
											else
												warn("Attempt to perform property changes for a part on a non-part")
											end	
										end
									end
								end
							end
						end
					end
					
				elseif ActivateLights == false then
					for n, TabulatedInstance in pairs (c.InstanceTable) do
						
						--// Handles the reference part
							if c.ReferencePartType ~= nil then
								if c.ReferencePartType == "Light" then
									if TabulatedInstance:IsA("PointLight") or TabulatedInstance:IsA("SpotLight") or TabulatedInstance:IsA("SurfaceLight") then
										local Tween = TweenService:Create(TabulatedInstance, LightingTweenInformation, {Brightness = c.UnlitBrightness})
										Tween:Play()
									else
										warn("Attempt to perform property changes for a light on a non-light")
									end
								elseif TabulatedInstance.ReferencePartType == "Part" then
									if c:IsA("BasePart") then
										TabulatedInstance.Material = c.UnlitMaterial
										local Tween = TweenService:Create(TabulatedInstance, LightingTweenInformation, {Color = c.UnlitColor})
										Tween:Play()
									else
										warn("Attempt to perform property changes for a part on a non-part")
									end
								end
							end
							
						for a, b in pairs (c.RelatedParts) do
							if b.RelationType == "Parent" then
								if b.RelatedName == TabulatedInstance.Parent.Name or b.RelatedName == nil then
									local TargetInstance = TabulatedInstance.Parent
									
									if b.InstanceType == "Light" then
										if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
											local Tween = TweenService:Create(TargetInstance, LightingTweenInformation, {Brightness = b.UnlitBrightness})
											Tween:Play()
										else
											warn("Attempt to perform property changes for a light on a non-light")
										end
									elseif b.InstanceType == "Part" then
										if TargetInstance:IsA("BasePart") then
											TargetInstance.Material = b.UnlitMaterial
											local Tween = TweenService:Create(TargetInstance, LightingTweenInformation, {Color = b.UnlitColor})
											Tween:Play()
										else
											warn("Attempt to perform property changes for a part on a non-part")
										end	
									end
								end
								
							elseif b.RelationType == "Child" then
								if TabulatedInstance:FindFirstChild(b.RelatedName) then
									local TargetInstance = TabulatedInstance:FindFirstChild(b.RelatedName)
									
									if b.InstanceType == "Light" then
										if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
											local Tween = TweenService:Create(TargetInstance, LightingTweenInformation, {Brightness = b.UnlitBrightness})
											Tween:Play()
										else
											warn("Attempt to perform property changes for a light on a non-light")
										end
									elseif b.InstanceType == "Part" then
										if TargetInstance:IsA("BasePart") then
											TargetInstance.Material = b.UnlitMaterial
											local Tween = TweenService:Create(TargetInstance, LightingTweenInformation, {Color = b.UnlitColor})
											Tween:Play()
										else
											warn("Attempt to perform property changes for a part on a non-part")
										end	
									end
								end
							end
						end
					end
				else
					warn("[GHI] Hmm, this warning should never be hit - contact https_KingPie!!")
				end
			end
		else
			warn("Index: ".. i .. " not recognized")
		end
	end
end

--// Mechanical Functions
function module.GatherInstanceTable(InstanceName)
	local Table = {}

	for i, v in pairs (Workspace:GetDescendants()) do
		if v.Name == InstanceName then
			table.insert(Table, v)
		end
	end
	
	return Table
end

function module.LightRandomIllumination(ChanceOfIllumination) --// As a 0-100 integer with 0 never turning on and 100 always turning on
	local Number = math.random(1,100)
	
	if Number <= ChanceOfIllumination then
		return true
	else
		return false
	end
end

function module.AdjustedStart(WaitTime) --// Creates the adjusted start times by "syncing" to the day/night script
	if WaitTime == nil then
		WaitTime = 10
	end
	
	local ClockTime1 = Lighting.ClockTime
	wait(WaitTime)
	local ClockTime2 = Lighting.ClockTime
	local RateOfTime --// Measures how time change per second (average)
	
	if ClockTime1 < ClockTime2 then
		RateOfTime = (ClockTime2-ClockTime1)/WaitTime
	else --// Means midnight was crossed
		RateOfTime = (24-ClockTime1+ClockTime2)/WaitTime
	end
	
	local Adjustment = RateOfTime * LightingTweenInformation.Time
	
	for i, v in pairs (LightingSettings) do
		if (v.TimeStart - Adjustment) >= 0 then
			v.AdjustedStart = v.TimeStart - Adjustment
		else
			v.AdjustedStart = 24 + v.TimeStart - Adjustment --// (TimeStart - Adjustment) would be a negative number
		end
		
		if (v.TimeEnd - Adjustment) >= 0 then
			v.AdjustedEnd = v.TimeEnd - Adjustment
		else
			v.AdjustedEnd = 24 + v.TimeEnd - Adjustment --// (TimeStart - Adjustment) would be a negative number
		end
	end
end

return module
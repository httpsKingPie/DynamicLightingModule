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
		
		*The 1 you see above is an optional wait period that you can include that directs how often the module checks for Lighting Period changes 
	
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
local LightingSettings = { --// Add as many or as little Lighting Periods as you like, just make sure they are continuous i.e. (0 - 3, 3-12, 12-20, 20-0) don't leave gaps like (0-3, 6-12, 12-20, 20-0)
	["LightingPeriodName1"] = {
		TimeStart = 5,
		TimeEnd = 6.3,
		Ambient = Color3.fromRGB(115, 78, 0),
		OutdoorAmbient = Color3.fromRGB(128, 124, 81),
		ShadowSoftness = 0.4,
		LightsOn = false,
	},
	["LightingPeriodName2"] = {
		TimeStart = 6.3,
		TimeEnd = 17.3,
		Ambient = Color3.fromRGB(136, 95, 0),
		OutdoorAmbient = Color3.fromRGB(128, 128, 128),
		ShadowSoftness = 0.65,
		LightsOn = false,
	},
	["LightingPeriodName3"] = {
		TimeStart = 17.3,
		TimeEnd = 18.5,
		Ambient = Color3.fromRGB(115, 78, 0),
		OutdoorAmbient = Color3.fromRGB(128, 109, 86),
		ShadowSoftness = 0.3,
		LightsOn = false,
	},
	["LightingPeriodName4"] = {
		TimeStart = 18.5,
		TimeEnd = 5,
		Ambient = Color3.fromRGB(104, 67, 0),
		OutdoorAmbient = Color3.fromRGB(95, 100, 128),
		ShadowSoftness = 0.1,
		LightsOn = true,
	},
}

local WeatherSettings = {
	["None"] = { --// This is your default settings (do not delete this table) [some very generic default settings have been loaded in - feel free to change]
		BlurSize = 0,
		SunRaysIntensity = .25,
		FogColor = Color3.fromRGB(191, 191, 191),
		FogEnd = 5000,
		Brightness = 1,
		--// No Ambient, OutdoorAmbient, or ShadowSoftness settings as this will be replaced by whatever settings are applied based on Lighting Period
		WaterReflectance = 1,
		WaterWaveSize = 0.35,
		WaterWaveSpeed = 9.77,
		LightsOn = false,
	},
}

local ChangingLights = {	
	["Parts"] = {
		["NameThisWhateverYouWant"] = {
			InstanceName = "",
			UnlitColor = Color3.fromRGB(231, 231, 236),
			UnlitMaterial = Enum.Material.Glass,
			LitColor = Color3.fromRGB(218, 133, 65),
			LitMaterial = Enum.Material.Neon,
			ChanceOfIllumination = 80, --// Enter without percent sign (ex: 33% = 33)
		},
		
		["NameThisWhateverYouWant2"] = {
			InstanceName = "", --This is the only one appearing
			UnlitColor = Color3.fromRGB(0, 0, 0),
			UnlitMaterial = Enum.Material.Glass,
			LitColor = Color3.fromRGB(0, 0, 0),
			LitMaterial = Enum.Material.Neon,
			ChanceOfIllumination = 80, --// Enter without percent sign (ex: 33% = 33)
		},
		
		--// Feel free to add more!
	},
	
	["Lights"] = {
		["NameThisWhateverYouWant"] = {
			InstanceName = "",
			LitBrightness = 1,
			UnlitBrightness = 0,
			ChanceOfIllumination = 80, --// Enter without percent sign (ex: 33% = 33)
		},
		
		["NameThisWhateverYouWant2"] = {
			InstanceName = "",
			LitBrightness = 1,
			UnlitBrightness = 0,
			ChanceOfIllumination = 80, --// Enter without percent sign (ex: 33% = 33)
		},
		
		--// Feel free to add more!
	},
	
	["MultiInstanceLights"] = { --//Only use if utilizing randomization feature (unless you really want to, I can't stop you and it's not actually that big of a deal)
		["NameThisWhateverYouWant"] = {
			ReferencePartName = "",
			ReferencePartType = "Part", --// Either Light or Part.  Leave as nil if you want zero changes on the reference part
			--// Only relevant if ReferencePartType is "Light"
			LitBrightness = 1,
			UnlitBrightness = 0,
			--// Only relevant if ReferencePartType is "Part"
			UnlitColor = Color3.fromRGB(231, 231, 236),
			UnlitMaterial = Enum.Material.Glass,
			LitColor = Color3.fromRGB(218, 133, 65),
			LitMaterial = Enum.Material.Neon,
			ChanceOfIllumination = 80,
			RelatedParts = {
				{
					RelatedName = "", --// If set to nil will just reference the parent without checking the parent's name.  The name must be specified if the relation is a child because ROBLOX ugh
					RelationType = "Child", --// Child or Parent
					InstanceType = "Light", --// Light or Part
					--// Only relevant if InstanceType is "Light"
					LitBrightness = 1,
					UnlitBrightness = 0,
					--// Only relevant if InstanceType is "Part"
					UnlitColor = Color3.fromRGB(0, 0, 0),
					UnlitMaterial = Enum.Material.Glass,
					LitColor = Color3.fromRGB(0, 0, 0),
					LitMaterial = Enum.Material.Neon,
				}
			},
		},
		
		["NameThisWhateverYouWant2"] = {
			ReferencePartName = "",
			ReferencePartType = "Part", --// Either Light or Part.  Leave as nil if you want zero changes on the reference part
			--// Only relevant if ReferencePartType is "Light"
			LitBrightness = 1,
			UnlitBrightness = 0,
			--// Only relevant if ReferencePartType is "Part"
			UnlitColor = Color3.fromRGB(0, 0, 0),
			UnlitMaterial = Enum.Material.Glass,
			LitColor = Color3.fromRGB(0, 0, 0),
			LitMaterial = Enum.Material.Neon,
			ChanceOfIllumination = 80,
			RelatedParts = {
				{
					RelatedName = "", --// If set to nil will just reference the parent without checking the parent's name.  The name must be specified if the relation is a child because ROBLOX ugh
					RelationType = "Child", --// Child or Parent
					InstanceType = "Light", --// Light or Part
					--// Only relevant if InstanceType is "Light"
					LitBrightness = 1,
					UnlitBrightness = 0,
					--// Only relevant if InstanceType is "Part"
					UnlitColor = Color3.fromRGB(0, 0, 0),
					UnlitMaterial = Enum.Material.Glass,
					LitColor = Color3.fromRGB(0, 0, 0),
					LitMaterial = Enum.Material.Neon,
				}
			},
		},
		
		--// Feel free to add more!
	}
}
--// Secondary Varaibles
local Weather = false --// Indicates non-clear or non-snow weather
local LightsActive = false --// Defaults to off, adjust if necessary
local TimeAdjusted = false --// Indicated whether TimeAdjusted zones have been set up

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
	
	CurrentLightingPeriod = module.GetLightingPeriod() --// Records the current Lighting Period
	
	if Weather == false then
		module.SetLighting(CurrentLightingPeriod) --// Activates the lighting settings for the current Lighting Period if there is no weather
		module.HandleLightsLightingPeriod(CurrentLightingPeriod, "Set") --Handles whether lights need to be turned on for the current Lighting Period
	end
	
	local SetUpAdjustedStart = coroutine.create(module.AdjustedStart)
	coroutine.resume(SetUpAdjustedStart) --// Sets up the adjusted start ranges
	
	if Lighting:FindFirstChildWhichIsA("SunRaysEffect") == nil then --// Creates a Sun Rays effect if necessary
		local SunRays = Instance.new("SunRaysEffect")
		SunRays.Parent = Lighting
	end
	
	if Lighting:FindFirstChildWhichIsA("BlurEffect") == nil then --// Creates a Blur effect fi necessary
		local Blur = Instance.new("BlurEffect")
		Blur.Parent = Lighting
		Blur.Size = 0
	end
	
	while wait(WaitTime) do
		if TimeAdjusted == true then
			if Weather == false then
				if CurrentLightingPeriod ~= module.CheckForPeriodChange() then --// Checks for impending Lighting Period changes
					module.TweenLightingSettings(module.CheckForPeriodChange()) --// Starts tweening light settings when a LightingPeriod change is detected
				end
			end
		else
			--// This just means it is waiting on the Adjusted Start ranges to configure
		end
	end
end

--// Get Functions
function module.GetLightingSettings() --// Gets the LightingSettings table
	return LightingSettings
end

function module.GetWeatherSettings() --// Gets the WeatherSettings table
	return WeatherSettings
end

function module.GetLightingPeriod() --// Gets the index name of the current LightingPeriod that the ClockTime is within
	local CurrentTime = Lighting.ClockTime
	
	for LightingPeriod, PeriodSettings in pairs(LightingSettings) do
		if PeriodSettings.TimeStart < PeriodSettings.TimeEnd then --// Expected (ex: starts at 5 ends at 13)
			if CurrentTime >= PeriodSettings.TimeStart and CurrentTime < PeriodSettings.TimeEnd then
				return LightingPeriod
			end
		else --// Slightly abnormal cases where times go over midnight (ex: starts at 22 ends at 4)
			if (CurrentTime >= PeriodSettings.TimeStart and CurrentTime < 24) or CurrentTime < PeriodSettings.TimeEnd then
				return LightingPeriod
			end
		end
	end
	
	warn("Error: Current ClockTime ".. CurrentTime.. " is not within a specified Time Period")
end

--// (Pretty much the same code as above, but this checks with the AdjustedStart)
function module.CheckForPeriodChange() --// Gets the index of whatever adjustment period the current ClockTime falls within
	local CurrentTime = Lighting.ClockTime
	
	for LightingPeriod, PeriodSettings in pairs(LightingSettings) do
		if PeriodSettings.AdjustedStart < PeriodSettings.AdjustedEnd then --// Expected (ex: starts at 5 ends at 13)
			if CurrentTime >= PeriodSettings.AdjustedStart and CurrentTime < PeriodSettings.AdjustedEnd then
				return LightingPeriod
			end
		else --// Slightly abnormal cases where times go over midnight (ex: starts at 22 ends at 4)
			if (CurrentTime >= PeriodSettings.AdjustedStart and CurrentTime < 24) or CurrentTime < PeriodSettings.AdjustedEnd then
				return LightingPeriod
			end
		end
	end
	
	warn("Ensure all time periods are continuous, a gap has been detected at time ".. CurrentTime)
end

--//Set Functions
function module.SetWeather(WeatherType) --// Immediately applies the lighting settings for a weather period
	local SpecifiedWeatherSettings = WeatherSettings[WeatherType]
	
	if WeatherType ~= "None" then
		if SpecifiedWeatherSettings ~= nil then
			Lighting.FogEnd = SpecifiedWeatherSettings.FogEnd
			Lighting.FogEnd = SpecifiedWeatherSettings.FogEnd
			Lighting.FogColor = SpecifiedWeatherSettings.FogColor
			Lighting.Ambient = SpecifiedWeatherSettings.Ambient
			Lighting.OutdoorAmbient = SpecifiedWeatherSettings.OutdoorAmbient
			Lighting.Brightness = SpecifiedWeatherSettings.Brightness
			Lighting.ShadowSoftness = SpecifiedWeatherSettings.ShadowSoftness
			
			local SunRaysEffect = Lighting:FindFirstChildWhichIsA("SunRaysEffect")
			SunRaysEffect.Intensity = SpecifiedWeatherSettings.SunRaysIntensity
			
			local BlurEffect = Lighting:FindFirstChildWhichIsA("BlurEffect")
			BlurEffect.Size = SpecifiedWeatherSettings.BlurSize
			
			local Terrain = Workspace.Terrain
			Terrain.WaterReflectance = SpecifiedWeatherSettings.WaterReflectance
			Terrain.WaterWaveSize = SpecifiedWeatherSettings.WaterWaveSize
			Terrain.WaterWaveSpeed = SpecifiedWeatherSettings.WaterWaveSpeed
			
			module.HandleLightsWeather(WeatherType, "Set")
			Weather = true
		else
			warn("Weather input ".."//"..WeatherType.."//".." is not in the WeatherSettings")
		end
	else
		Weather = false
		Lighting.FogEnd = SpecifiedWeatherSettings.FogEnd
		Lighting.FogEnd = SpecifiedWeatherSettings.FogEnd
		Lighting.FogColor = SpecifiedWeatherSettings.FogColor
		Lighting.Brightness = SpecifiedWeatherSettings.Brightness
		--// Ambient, OutdoorAmbient, and ShadowSoftness are taken care of by the Lighting Period
		local SunRaysEffect = Lighting:FindFirstChildWhichIsA("SunRaysEffect")
		SunRaysEffect.Intensity = SpecifiedWeatherSettings.SunRaysIntensity
		
		local BlurEffect = Lighting:FindFirstChildWhichIsA("BlurEffect")
		BlurEffect.Size = SpecifiedWeatherSettings.BlurSize
		
		local Terrain = Workspace.Terrain
		Terrain.WaterReflectance = SpecifiedWeatherSettings.WaterReflectance
		Terrain.WaterWaveSize = SpecifiedWeatherSettings.WaterWaveSize
		Terrain.WaterWaveSpeed = SpecifiedWeatherSettings.WaterWaveSpeed
			
		local LightingPeriod = module.GetLightingPeriod()
		module.SetLighting(LightingPeriod)
		module.HandleLightsLightingPeriod(LightingPeriod, "Set")
	end
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
	if WeatherType ~= "None" then
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
	if WeatherType ~= "None" then
		Weather = true
		local SpecifiedWeatherSettings = WeatherSettings[WeatherType]
		
		local Tween1 = TweenService:Create(Lighting, WeatherTweenInformation, {FogEnd = SpecifiedWeatherSettings.FogEnd, FogColor = SpecifiedWeatherSettings.FogColor, Ambient = SpecifiedWeatherSettings.Ambient, OutdoorAmbient = SpecifiedWeatherSettings.OutdoorAmbient, Brightness = SpecifiedWeatherSettings.Brightness, ShadowSoftness = SpecifiedWeatherSettings.ShadowSoftness})
		local Tween2 = TweenService:Create(Lighting:FindFirstChildWhichIsA("SunRaysEffect"), WeatherTweenInformation, {Intensity = SpecifiedWeatherSettings.SunRaysIntensity})
		local Tween3 = TweenService:Create(Lighting:FindFirstChildWhichIsA("BlurEffect"), WeatherTweenInformation, {Size = SpecifiedWeatherSettings.BlurSize})
		local Tween4 = TweenService:Create(Workspace.Terrain, WeatherTweenInformation, {WaterReflectance = SpecifiedWeatherSettings.WaterReflectance, WaterWaveSize = SpecifiedWeatherSettings.WaterWaveSize, WaterWaveSpeed = SpecifiedWeatherSettings.WaterWaveSpeed})
		
		Tween1:Play()
		Tween2:Play()
		Tween3:Play()
		Tween4:Play()
		
	else
		Weather = false
		local SpecifiedWeatherSettings = WeatherSettings[WeatherType]
		
		local Tween1 = TweenService:Create(Lighting, WeatherTweenInformation, {FogEnd = SpecifiedWeatherSettings.FogEnd, FogColor = SpecifiedWeatherSettings.FogColor, Brightness = SpecifiedWeatherSettings.Brightness})
		local Tween2 = TweenService:Create(Lighting:FindFirstChildWhichIsA("SunRaysEffect"), WeatherTweenInformation, {Intensity = SpecifiedWeatherSettings.SunRaysIntensity})
		local Tween3 = TweenService:Create(Lighting:FindFirstChildWhichIsA("BlurEffect"), WeatherTweenInformation, {Size = SpecifiedWeatherSettings.BlurSize})
		local Tween4 = TweenService:Create(Workspace.Terrain, WeatherTweenInformation, {WaterReflectance = SpecifiedWeatherSettings.WaterReflectance, WaterWaveSize = SpecifiedWeatherSettings.WaterWaveSize, WaterWaveSpeed = SpecifiedWeatherSettings.WaterWaveSpeed})
		
		Tween1:Play()
		Tween2:Play()
		Tween3:Play()
		Tween4:Play()
		
		module.TweenLightingSettings(module.CheckForPeriodChange()) --// Tweens the Ambient, OutdoorAmbient, and ShadowSoftness to wahtever the current Lighting Period is
		
		local LightingPeriod = module.GetLightingPeriod()
		module.HandleLightsLightingPeriod(LightingPeriod, "Tween")
	end
	module.HandleLightsWeather(WeatherType, "Tween") --// Tweens lights
end

--// Advanced Functions
function module.SetLights(ActivateLights) --// Immediately sets the lights to an on/off status
	for i, v in pairs (ChangingLights) do
		
		--//Parts index
		if i == "Parts" then
			for x, c in pairs (v) do
				--Error in that only one table c is appearing, not parsing through them all
				--// Creates InstanceTable
				if c.InstanceTable == nil then
					c.InstanceTable = module.GatherInstanceTable(c.InstanceName)
				end
				
				--// Sets lights to on
				if ActivateLights == true then
					for n, m in pairs (c.InstanceTable) do
						if module.LightRandomIllumination(c.ChanceOfIllumination) == true then
							m.Color = c.LitColor
							m.Material = c.LitMaterial
						end
					end
					
				--// Sets lights off
				elseif ActivateLights == false then
					for n, m in pairs (c.InstanceTable) do
						m.Color = c.UnlitColor
						m.Material = c.UnlitMaterial
					end
				else
					warn("[ABC] Hmm, this warning should never be hit - contact https_KingPie!!")
				end
			end
			
		--// Lights index
		elseif i == "Lights" then
			for x, c in pairs (v) do
				
				--//Creates InstanceTable
				if c.InstanceTable == nil then
					c.InstanceTable = module.GatherInstanceTable(c.InstanceName)
				end
				
				--// Turns lights on
				if ActivateLights == true then
					for n, m in pairs (c.InstanceTable) do
						if module.LightRandomIllumination(c.ChanceOfIllumination) == true then
							m.Brightness = c.LitBrightness
						end
					end
					
				--// Turns lights off
				elseif ActivateLights == false then
					for n, m in pairs (c.InstanceTable) do
						m.Brightness = c.UnlitBrightness
					end
				else
					warn("[DEF] Hmm, this warning should never be hit - contact https_KingPie!!")
				end
			end
		
		--// MultiInstances index
		elseif i == "MultiInstanceLights" then
			for x, c in pairs (v) do
				
				--// Creates InstanceTable
				if c.InstanceTable == nil then
					c.InstanceTable = module.GatherInstanceTable(c.ReferencePartName)
				end
				
				--// Turns lights on
				if ActivateLights == true then
					for n, TabulatedInstance in pairs (c.InstanceTable) do
						if module.LightRandomIllumination(c.ChanceOfIllumination) == true then
							
							--// Handles the ReferencePart
							if c.ReferencePartType ~= nil then
								
								--// Handles ReferencePartType Light
								if c.ReferencePartType == "Light" then
									if TabulatedInstance:IsA("PointLight") or TabulatedInstance:IsA("SpotLight") or TabulatedInstance:IsA("SurfaceLight") then
										TabulatedInstance.Brightness = c.LitBrightness
									else
										warn("Attempt to perform property changes for a light on a non-light")
									end
									
								--// Handles ReferencePartType Part
								elseif c.ReferencePartType == "Part" then
									if TabulatedInstance:IsA("BasePart") then
										TabulatedInstance.Color = c.LitColor
										TabulatedInstance.Material = c.LitMaterial
									else
										warn("Attempt to perform property changes for a part on a non-part")
									end
								end
							end
							
							--// Handles the RelatedParts
							for a, b in pairs (c.RelatedParts) do
								
								--// Handles Parent relations
								if b.RelationType == "Parent" then
									if b.RelatedName == TabulatedInstance.Parent.Name or b.RelatedName == nil then
										local TargetInstance = TabulatedInstance.Parent
										
										--// Handles Light Instances
										if b.InstanceType == "Light" then
											if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
												TargetInstance.Brightness = b.LitBrightness
											else
												warn("Attempt to perform property changes for a light on a non-light")
											end
											
										--// Handles Part Instances
										elseif b.InstanceType == "Part" then
											if TargetInstance:IsA("BasePart") then
												TargetInstance.Color = b.LitColor
												TargetInstance.Material = b.LitMaterial
											else
												warn("Attempt to perform property changes for a part on a non-part")
											end	
										end
									end
								
								--// Handles Child relations
								elseif b.RelationType == "Child" then
									if TabulatedInstance:FindFirstChild(b.RelatedName) then
										local TargetInstance = TabulatedInstance:FindFirstChild(b.RelatedName)
										
										--// Handles Light Instances
										if b.InstanceType == "Light" then
											if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
												TargetInstance.Brightness = b.LitBrightness
											else
												warn("Attempt to perform property changes for a light on a non-light")
											end
											
										--// Handles Part Instances
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
				
				--// Turns Lights Off
				elseif ActivateLights == false then
					for n, TabulatedInstance in pairs (c.InstanceTable) do
						
						--// Handles the Reference Part
						if c.ReferencePartType ~= nil then
							
							--// Handles ReferencePartType Light
							if c.ReferencePartType == "Light" then
								if TabulatedInstance:IsA("PointLight") or TabulatedInstance:IsA("SpotLight") or TabulatedInstance:IsA("SurfaceLight") then
									TabulatedInstance.Brightness = c.UnlitBrightness
								else
									warn("Attempt to perform property changes for a light on a non-light")
								end
								
							--// Handles ReferencePartType Part
							elseif c.ReferencePartType == "Part" then
								if TabulatedInstance:IsA("BasePart") then
									TabulatedInstance.Color = c.UnlitColor
									TabulatedInstance.Material = c.UnlitMaterial
								else
									warn("Attempt to perform property changes for a part on a non-part")
								end
							end
						end
						
						--// Handles RelatedParts
						for a, b in pairs (c.RelatedParts) do
							
							--// Handles Parent Relations
							if b.RelationType == "Parent" then
								if b.RelatedName == TabulatedInstance.Parent.Name or b.RelatedName == nil then
									local TargetInstance = TabulatedInstance.Parent
									
									--// Handles Light Instances
									if b.InstanceType == "Light" then
										if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
											TargetInstance.Brightness = b.UnlitBrightness
										else
											warn("Attempt to perform property changes for a light on a non-light")
										end
										
									--// Handles Part Instances
									elseif b.InstanceType == "Part" then
										if TargetInstance:IsA("BasePart") then
											TargetInstance.Color = b.UnlitColor
											TargetInstance.Material = b.UnlitMaterial
										else
											warn("Attempt to perform property changes for a part on a non-part")
										end	
									end
								end
							
							--// Handles Child Relations
							elseif b.RelationType == "Child" then
								if TabulatedInstance:FindFirstChild(b.RelatedName) then
									local TargetInstance = TabulatedInstance:FindFirstChild(b.RelatedName)
									
									--// Handles Light Instances
									if b.InstanceType == "Light" then
										if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
											TargetInstance.Brightness = b.UnlitBrightness
										else
											warn("Attempt to perform property changes for a light on a non-light")
										end
										
									--// Handles Part Instances
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
		
		--// Parts Index
		if i == "Parts" then
			for x, c in pairs (v) do
				
				--// Creates InstanceTable
				if c.InstanceTable == nil then
					c.InstanceTable = module.GatherInstanceTable(c.InstanceName)
				end
				
				--// Turns Lights On
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
					
				--// Turns Lights Off
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
		
		--// Lights index
		elseif i == "Lights" then
			for x, c in pairs (v) do
				
				--// Creates InstanceTable
				if c.InstanceTable == nil then
					c.InstanceTable = module.GatherInstanceTable(c.InstanceName)
				end
				
				--// Turns Lights on
				if ActivateLights == true then
					for n, m in pairs (c.InstanceTable) do
						if module.LightRandomIllumination(c.ChanceOfIllumination) == true then
							local Tween = TweenService:Create(m, LightingTweenInformation, {Brightness = c.LitBrightness})
							Tween:Play()
						end
					end
					
				--// Turns Lights off
				elseif ActivateLights == false then
					for n, m in pairs (c.InstanceTable) do
						local Tween = TweenService:Create(m, LightingTweenInformation, {Brightness = c.UnlitBrightness})
						Tween:Play()
					end
				else
					warn("[DEF] Hmm, this warning should never be hit - contact https_KingPie!!")
				end
			end
			
		--// MultiInstances index
		elseif i == "MultiInstanceLights" then
			for x, c in pairs (v) do
				
				--// Creates InstanceTable
				if c.InstanceTable == nil then
					c.InstanceTable = module.GatherInstanceTable(c.ReferencePartName)
				end
				
				--// Turns lights on
				if ActivateLights == true then
					for n, TabulatedInstance in pairs (c.InstanceTable) do --// Access table of instances (value being TabulatedInstance)
						if module.LightRandomIllumination(c.ChanceOfIllumination) == true then
							
							--// Handles the reference part
							if c.ReferencePartType ~= nil then
								
								--// Handles ReferencePartType Light
								if c.ReferencePartType == "Light" then
									if TabulatedInstance:IsA("PointLight") or TabulatedInstance:IsA("SpotLight") or TabulatedInstance:IsA("SurfaceLight") then
										local Tween = TweenService:Create(TabulatedInstance, LightingTweenInformation, {Brightness = c.LitBrightness})
										Tween:Play()
									else
										warn("Attempt to perform property changes for a light on a non-light")
									end
									
								--// Handles ReferencePartType Part
								elseif c.ReferencePartType == "Part" then
									if TabulatedInstance:IsA("BasePart") then
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
							
							--// Handles Related Parts
							for a, b in pairs (c.RelatedParts) do
								
								--// Handles Parent Relations
								if b.RelationType == "Parent" then
									if b.RelatedName == TabulatedInstance.Parent.Name or b.RelatedName == nil then
										local TargetInstance = TabulatedInstance.Parent
										
										--// Handles InstanceType Light
										if b.InstanceType == "Light" then
											if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
												local Tween = TweenService:Create(TargetInstance, LightingTweenInformation, {Brightness = b.LitBrightness})
												Tween:Play()
											else
												warn("Attempt to perform property changes for a light on a non-light")
											end
											
										--// Handles InstanceType Part
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
									
								--// Handles Child Relations
								elseif b.RelationType == "Child" then
									if TabulatedInstance:FindFirstChild(b.RelatedName) then
										local TargetInstance = TabulatedInstance:FindFirstChild(b.RelatedName)
										
										--// Handles InstanceType Light
										if b.InstanceType == "Light" then
											if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
												local Tween = TweenService:Create(TargetInstance, LightingTweenInformation, {Brightness = b.LitBrightness})
												Tween:Play()
											else
												warn("Attempt to perform property changes for a light on a non-light")
											end
											
										--// Handles InstanceType Part
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
				
				--// Turns Lights Off
				elseif ActivateLights == false then
					for n, TabulatedInstance in pairs (c.InstanceTable) do
						
						--// Handles the reference part
							if c.ReferencePartType ~= nil then
								
								--// Handles ReferencePartType Light
								if c.ReferencePartType == "Light" then
									if TabulatedInstance:IsA("PointLight") or TabulatedInstance:IsA("SpotLight") or TabulatedInstance:IsA("SurfaceLight") then
										local Tween = TweenService:Create(TabulatedInstance, LightingTweenInformation, {Brightness = c.UnlitBrightness})
										Tween:Play()
									else
										warn("Attempt to perform property changes for a light on a non-light")
									end
									
								--// Handles ReferencePartType Part
								elseif c.ReferencePartType == "Part" then
									if TabulatedInstance:IsA("BasePart") then
										TabulatedInstance.Material = c.UnlitMaterial
										local Tween = TweenService:Create(TabulatedInstance, LightingTweenInformation, {Color = c.UnlitColor})
										Tween:Play()
									else
										warn("Attempt to perform property changes for a part on a non-part")
									end
								end
							end
						
						--// Handles RelatedParts
						for a, b in pairs (c.RelatedParts) do
							
							--// Handles Parent Relations
							if b.RelationType == "Parent" then
								if b.RelatedName == TabulatedInstance.Parent.Name or b.RelatedName == nil then
									local TargetInstance = TabulatedInstance.Parent
									
									--// Handles InstanceType Light
									if b.InstanceType == "Light" then
										if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
											local Tween = TweenService:Create(TargetInstance, LightingTweenInformation, {Brightness = b.UnlitBrightness})
											Tween:Play()
										else
											warn("Attempt to perform property changes for a light on a non-light")
										end
										
									--// Handles InstanceType Part
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
								
							--// Handles Child Relations
							elseif b.RelationType == "Child" then
								if TabulatedInstance:FindFirstChild(b.RelatedName) then
									local TargetInstance = TabulatedInstance:FindFirstChild(b.RelatedName)
									
									--// Handles InstanceType Light
									if b.InstanceType == "Light" then
										if TargetInstance:IsA("PointLight") or TargetInstance:IsA("SpotLight") or TargetInstance:IsA("SurfaceLight") then
											local Tween = TweenService:Create(TargetInstance, LightingTweenInformation, {Brightness = b.UnlitBrightness})
											Tween:Play()
										else
											warn("Attempt to perform property changes for a light on a non-light")
										end
									
									--// Handles InstanceType Part
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
	
	if InstanceName == "" or InstanceName == nil then --// Prevents unnecesssary searching
		return {}
	end
	
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
		WaitTime = 5 --// After some experimentation, five second usually gets the most accurate time adjustments (can obviously reduce those if you feel it will benefit your game more to reduce this)
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
	
	TimeAdjusted = true
end

return module

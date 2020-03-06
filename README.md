# DynamicLightingModule
Description: This is a powerful ModuleScript that enables developers greater freedom at customizing and designing games with advanced lighting

To view the script click [here!](ModuleScript.lua)

Table of Contents:

-[How it Works](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#how-it-works)

-[Cool Features](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#cool-features)

# How it Works
Fundamentally, the Module works by allow you, the developer, to specify different "Lighting Periods" within the ModuleScript.  Lighting Periods are simply ranges of time that have specific lighting settings in them.  

Here's an example of what this looks like visually (with some example Lighting Periods)
![Example of Lighting Features](https://i.gyazo.com/8e7d60361fb68c108a7670c00a351e17.png)

A very basic example of where this would be useful would be making the Ambient and Outdoor Ambient settings darker at night.  However, you can create as many Lighting Periods as you like!  This allows you to create lighting periods to replicate things like dawn, twilight, night-time (or even different stages of night as well)!  

Within your Lighting Periods you can specify a lot of settings.  Currently the lighting settings that you can adjust are: Ambient, OutdoorAmbient, and ShadowSoftness.  The list can definitely be expanded, I just felt that those were the most relevant to start with.  

That is just the basic foundation of the Module, but there are *tons* of other cool features!  Check out the [Cool Features](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#cool-features) section to see more!

# Cool Features
**Tween based changes**
It's 2020, tweens are awesome, they look great, this Module absolutely uses tweens to create gradual, smooth, and seamless animations.  'Nuff said.

**Smart (really smart???) set up**
I tried to make this Module as intuitive as possible in my quest to make it both strong, bug resistant (if you find any let me know), and intuitive.  Here are some cool smart features in the Module:
*Auto-syncronization with day/night scripts*
You do not need a certain day/night script for this to work properly (although you obviously do need one of some kind since time has to pass to hit each Lighting Period, right?)  The script will automatically detect the rate at which time is passing and make adjustments accordingly?  What kind of adjustments?  Read on, dear developer!

*Auto-calculated tween starts*
So early on I realized something key, which was that if tweens start at the beginning of Lighting Periods, there is going to a gap between when the lighting period begins and when the settings are actually in their final positions as determined in each Lighting Period.  Here's an example of what I mean if you're having trouble following: 
![Example of issue](https://i.gyazo.com/265de5b46b7d54e2ba45542d4032e12a.png)

**Weather Integration**
This Module is designed to be compatible with weather scripts!  Similarly to Lighting Periods, you can specify different settings for various weather conditions.  Once you've done that, just call different weather conditions by running the function 
```lua
module.TweenWeather(WeatherNameHere)
``` 
which will tween your current lighting settings to those of the weather.  This is useful for creating dark storms, gray/white snow storms, etc.  Currently the settings that can be adjusted in weather settings are FogEnd, FogColor, Size of BlurEffects, Intesity of SunRays, Brightness, Ambient, OutdoorAmbient, WaterReflectance, WaterWaveSize, and WaterWaveSpeed.  Just like Lighting Settings, this list can definitely be expanded - I just thought these were the most relevant to start with.

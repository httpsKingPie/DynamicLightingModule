# DynamicLightingModule
Description: This is a powerful ModuleScript that enables developers greater freedom at customizing and designing games with advanced lighting

To view the script click [here!](ModuleScript.lua)

Table of Contents:

- [How it Works](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#how-it-works)
- [Cool Features](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#cool-features)

  - [Tween Based Changes](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#tween-based-changes)

  - [Smart Set-up](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#smart-really-smart-set-up)

    - [Auto-Syncronization with Day/Night Scripts](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#auto-syncronization-with-daynight-scripts)
    - [Auto-calculated Tween Starts](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#auto-calculated-tween-starts)
    - [Compensating for Midnight/Multi-Day Time Periods](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#compensating-for-midnightmulti-day-time-periods)
    - [No Further Variable Specifications](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#no-further-variable-specifications)
  - [Weather Integration](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#weather-integration)

# How it Works
Fundamentally, the Module works by allow you, the developer, to specify different "Lighting Periods" within the ModuleScript.  Lighting Periods are simply ranges of time that have specific lighting settings in them.  

Here's an example of what this looks like visually (with some example Lighting Periods)
![Example of Lighting Features](https://i.gyazo.com/8e7d60361fb68c108a7670c00a351e17.png)

A very basic example of where this would be useful would be making the Ambient and Outdoor Ambient settings darker at night.  However, you can create as many Lighting Periods as you like!  This allows you to create lighting periods to replicate things like dawn, twilight, night-time (or even different stages of night as well)!  

Within your Lighting Periods you can specify a lot of settings.  Currently the lighting settings that you can adjust are: Ambient, OutdoorAmbient, and ShadowSoftness.  The list can definitely be expanded, I just felt that those were the most relevant to start with.  

That is just the basic foundation of the Module, but there are *tons* of other cool features!  Check out the [Cool Features](https://github.com/httpsKingPie/DynamicLightingModule/blob/master/README.md#cool-features) section to see more!

# Cool Features
## Tween Based Changes
It's 2020, tweens are awesome, they look great, this Module absolutely uses tweens to create gradual, smooth, and seamless animations.  'Nuff said.

## Turn on/off Lights (with randomization and multi-instance light capability)
This is one of my favorite features.  I always really like seeing a city come alive when night falls.  Lights come on and it just looks spectacular.  This Module enables just that!  Just name all the lights that you want to be treated the same thing, and you're good to go!  There are two ways this works: by modifying light instances (PointLight, SpotLight, SurfaceLight) or part instances (abuse the neon material to create the illusion of light).  Randomization is also supported.  An example of why this is necessary is that when you go down a neighborhood road, every house does not have every light turned on.  Some are on, some are off.  This Module enables randomization so that you can determine the percentage chance a instance will have of "turning on" (regardless of whether it is a part of light instance).  

Now, one key problem exists in this? **What if I have a multi-instance light - won't that create an error with regards to randomization**  Yes!  If you're not following what this error is, imagine a lantern model.  The lantern model has a bunch of wooden structure parts, a glass part, and a PointLight with the glass part.  I can set the PointLight to have a 50% chance of turning on, or I could set the glass part to have a 50% chance of turning on (again, abusing that neon effect and turning it maybe a yellow color).  However, if I set them both to turn on, there's only a 25% of them both turning on at the same time, and more than likely only one of them will turn on.  

The solution to that is a multi-instance light handler.  In the same way way as a regular light, specify the properties that you want these multi-instances to have and then determine their relation to a singular reference part.  In this case, I might make the glass part my reference part, define the relation of the PointLight to the glass part as a child, specify my randomization chances/lighting properties, and done!  Easy as that!

## Smart (really smart???) set up
I tried to make this Module as intuitive as possible in my quest to make it both strong, bug resistant (if you find any let me know), and intuitive.  Here are some cool smart features in the Module:

### Auto-syncronization with day/night scripts
You do not need a certain day/night script for this to work properly (although you obviously do need one of some kind since time has to pass to hit each Lighting Period, right?)  The script will automatically detect the rate at which time is passing and make adjustments accordingly?  What kind of adjustments?  Read on, dear developer!

### Auto-calculated tween starts
So early on I realized something key, which was that if tweens start at the beginning of Lighting Periods, there is going to a gap between when the lighting period begins and when the settings are actually in their final positions as determined in each Lighting Period.  Here's an example of what I mean if you're having trouble following: 
![Example of issue](https://i.gyazo.com/265de5b46b7d54e2ba45542d4032e12a.png)
*The black lines are the ranges of each lighting period and when we want those settings to be applied.  The red lines are approximately where those settings are going to be applied if the tween starts at the beginning of the lighting period.  This can result in Lighting Periods behaving as the developer does not intend*
So what's the solution to this?  ~~Make the developer eyeball it, trial and error, and take their best guess at times to make the lighting period line up with what they want~~ The solution is to use the auto-syncronization of day/night scripts, calculate the rate at which time passes, and adjust the ranges of lighting periods and create separate ranges so that your lighting period can be fully set up when you want it.  In-game example would be specifying my twilight period at 1830-1945.  If the tween settings are set up so that changes take 20 seconds to tween all the lighting settings and time passes in my game at a rate of approximately (.05 hours per second, then I would need to start my tween at 1730 in-game time.  The Module takes care of all of that for you.  

### Compensating for midnight/multi-day time periods
The Module is set up to understand when Lighting Periods cross over days.  There will not be an error if you specify Lighting Periods that begin at 2100 and end at 0500 or LightingPeriods that begin at 1200 and end at 1700.  The Module is designed to take those into account, so have no fear.

### No further variable specifications
Just set up your lighting periods and weather settings.  There are zero other variables you need to define or instances that you have to manually calibrate.  An example of this is the BlurEffect.  You don't have to go through the tedious process of configuring instances within the Module script to reference your BlurEffect.  The module will find it automatically and if it isn't there, it will create one.  Easier for everyone, but mostly you : D)

## Weather Integration
This Module is designed to be compatible with weather scripts!  Similarly to Lighting Periods, you can specify different settings for various weather conditions.  Once you've done that, just call different weather conditions by running the function 
```lua
module.TweenWeather(WeatherNameHere)
``` 
which will tween your current lighting settings to those of the weather.  This is useful for creating dark storms, gray/white snow storms, etc.  Currently the settings that can be adjusted in weather settings are FogEnd, FogColor, Size of BlurEffects, Intesity of SunRays, Brightness, Ambient, OutdoorAmbient, WaterReflectance, WaterWaveSize, and WaterWaveSpeed.  Just like Lighting Settings, this list can definitely be expanded - I just thought these were the most relevant to start with.

## Coroutine Compatability
Not super surprising, but always nice.  This can be run as a nice coroutine if necessary or desired.  

# mta-map-to-ipl

MTA:SA script that converts Map Editor (.map) to GTA:SA singleplayer IPL format

Purpose: help GTA:SA mod developers create maps in MTA and make them usable in the base game

Custom Object IDs are possible if the map was saved using objects created by [newmodels](https://github.com/Fernando-A-Rocha/mta-add-models)

Instructions:

- Place the `maptoipl` resource folder in your MTA:SA server's resources folder
- Start the resource with `start maptoipl` in the server console
- Grant the resource ACL permissions with command `aclrequest allow maptoipl all`
- Use the command `maptoipl <map name>` in the server console or in-game (must be a logged in Admin) to convert a map

Thank you to [zeko](https://dyom.gtagames.nl/profile/34385) for suggesting this idea and testing some converted maps

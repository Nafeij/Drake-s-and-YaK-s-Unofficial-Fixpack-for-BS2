# Drake's & YaK's Fixpack for BS2 - version 3.1

> for Banner Saga 2, Steam version 2.59.01 / GOG version 2.61.02

Drake's & YaK's Fixpack for BS2 is a legacy-support mod for Banner Saga 2, build on top of the original unofficial patch by YaK of all Trades (YaK#2186) and Drake713.

The mod corrects bugs, inconsistencies and typos in the video game Banner Saga 2 by Stoic Studios. It also restores some never-before-seen cut-content and features various QoL improvements.

Many thanks to:
 - Gestaltzerfall, who updated TBSDecompiler - http://www.mediafire.com/file/wun36alp6ojlkjk/TBS_Decompiler3.2.3.air/file
 - Ratatoskr
 - Drake713
 - Nafeij
 - Aleo

Please report any bugs in [Issues](../../issues).

# Latest release

> ## 3.1
> 26 Jan 2023
> - Classed-based chievements for kills continue to trigger and grant 5 Renown after the first time unlocking them, per battle, within the same playthrough. Fortunately, the game saves a variable named in the format `"acv_..._unlk"` when this happens, so we can check for it in `\engine\saga\Saga.triggerVariableHandler` and prevent multiple unlocks in the same save.
> - If one of your heroes with an item gets killed, and is possessed by Eyeless, defeating your hero grants you a duplicate of that item. The game also tags possesed entities with a unique `"POSSESSED"` tag, which can be checked in `engine\battle\entitiy\model\BattleEntity._handleDeath_pre` to prevent them from dropping their items.
> - The passive on all types of Dredge Hurlers, Distraught, isn't triggering properly. Apparently simply changing "responsePhase" to "POST_COMPLETE" in its corresponding entry in `_ability.index.json` is enought to fix this.
> - Some messiness with how the battle at Arberrang is handled, if you side with the king and call in archers. This took a while because it involved not one but TWO bugs:
>   1. For some reason, the game counts all the barricades in the arberrang fight as part of the enemy team, preventing the battle from ending upon killing all enemies. Changing some vars in btl_arberang_gate.json fixes this.
>   2. Even so, the battle still does not end if the last enemy is killed in a scripted event, a la Oddleif or Nid. The game only checks when for the victory conditions when an enemy (or prop) is killed, not when
    a turn is ended. This is a hunch, but I suspect the event triggered for the unit's death is discarded when the game is processing a scripted event (or happening), and 'killing' a barricade yourself triggers it again.
    Unfortunately, the fault is baked in to the game logic and unfeasible to fix; the workaround used is to relinquish control of Nid and Oddleif to the player when either side is down on units.
> - Some characters may get obscured in conversations due to poor positioning (e.g. Dusi gets obscured by Juno and Apostate gets obscured by Bolverk).
> - Miscellaneous typos.

---

# Installation

## Steam

1. Download the archive from [Releases](../../releases).
2. Uncompress the zip archive and place the `/tbs2` folder in your game folder (e.g. `.../steamapps/common`). It will ask you to overwrite some files.

## GOG

1. Follow the Steam installation steps above.
2. Additionally, download the archive `..._GOG.zip`, and patch this over the same files above.

## Mod-Enabler Integration

The root folders are structured to be compatible with mod-enablers like [OvGME](jweisner/ovgme) and [JSGME](https://www.subsim.com/radioroom/showthread.php?t=204594).

Simply place the extracted root folder (**NOT** the `/tbs2` folder) in the configuration mods folder (`/MODS` in JSGME) and load the mods into your game's root directory (e.g. `.../steamapps/common`).


## To Uninstall

`Properties -> Verify the integrity of game files` in Steam or `Manage installation -> Verify / Repair...` in GOG.

# See also

- [Spare Some Love To Banner Saga 1](../../../YaK-s-SSLTBS1-Fixpack)
- [Nafeij's BS3 Fixpack](../../../Nafeij-s-BS3-Fixpack)

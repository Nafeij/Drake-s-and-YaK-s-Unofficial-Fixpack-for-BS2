 3.1
 
    [FIXED] Classed-based chievements for kills continue to trigger and grant 5 Renown after the first time unlocking them, per battle, within the same playthrough. Fortunately, the game saves a variable named in the format `"acv_..._unlk"` when this happens, so we can check for it in `\engine\saga\Saga.triggerVariableHandler` and prevent multiple unlocks in the same save.
    
    [FIXED] If one of your heroes with an item gets killed, and is possessed by Eyeless, defeating your hero grants you a duplicate of that item. The game also tags possesed entities with a unique `"POSSESSED"` tag, which can be checked in `engine\battle\entitiy\model\BattleEntity._handleDeath_pre` to prevent them from dropping their items.
    
    [FIXED] The passive on all types of Dredge Hurlers, Distraught, isn't triggering properly. Apparently simply changing "responsePhase" to "POST_COMPLETE" in its corresponding entry in `_ability.index.json` is enought to fix this.
    
    [FIXED] Some messiness with how the battle at Arberrang is handled, if you side with the king and call in archers. This took a while because it involved not one but TWO bugs:
        1. For some reason, the game counts all the barricades in the arberrang fight as part of the enemy team, preventing the battle from ending upon killing all enemies. Changing some vars in btl_arberang_gate.json fixes this.
        2. Even so, the battle still does not end if the last enemy is killed in a scripted event, a la Oddleif or Nid. The game only checks when for the victory conditions when an enemy (or prop) is killed, not when
           a turn is ended. This is a hunch, but I suspect the event triggered for the unit's death is discarded when the game is processing a scripted event (or happening), and 'killing' a barricade yourself triggers it again.
           Unfortunately, the fault is baked in to the game logic and unfeasible to fix; the workaround used is to relinquish control of Nid and Oddleif to the player when either side is down on units.

 3.0
 
    [FIXED] Importing a save using a version of Saga 2 with the BS2 fixpack installed causes discrepancies with Nid's upgrade points. She receives 8 more points than she's supposed to and her base version has -2 points.
    
    [FIXED] Some of the animations are bugged during the chasm crossing sequence and when the serpent slides into the sea. The sprites would suddenly pop into existence and start moving, i.e. they don't have a persistent start state. Due to a missing "start_visible": true flag
    
    [FIXED] Item duplication exploit: Whatever item Mogun has equipped will become duplicated if he is felled in his mutiny event. Similarly, equipping an item on Bolverk before the Insult/Axe storm training challenge causes his equipped item to become duped and bugged. Fixed by adding UNIT_TRANSFER_ITEM flags before each fight.
    A related bug causes the player to lose whatever item he has equipped if they so choose to dismiss Hogun.
    
    [FIXED] Bug in which horseborn lose their first active abilities at rank 7.
    
    [FIXED] -WILL and -ARM per turn effects can cause willpower and armor stats to go negative. Fixed by adding Math.max cap in \engine\battle\entity\model\BattleEntity
    
    [FIXED] -WILL items can cause willpower to be 'lost' when using horn (The charge goes away but you get no WIL if it's above your "new max WIL"). Fixed by changing the getValue to getBase in \game\gui\HornHelper
    
    [FIXED] Several typos in conversations, popups and cutscene subtitles.
    
    [TWEAKED] Gave Stonesingers +1 range
    
    [TWEAKED] Nerfed the first training challenge in Saga 2. Only two enemies need to be damaged by Heavy Impact to pass the objective.
    
 1.40

    [FIXED] (ENG) Another three typos on the map, in the description of Skogr: "... the the beast …". The updated list of ALL changes in "strings.json", is here, download and open it in your browser)
    
    [FIXED] (ENG) Another two typos in conversations, full details here, new ones on top)
    
    [FIXED] No clansmen, fighters nor supplies are added when Aleo’s village joins. Now 39, 12 and 17 supplies are added after the conversation ends
    
    [TWEAKED][2] The achievements in such way that most of them cause the flying text to show and award renown after the very first time too! It's important to know that this will prevent the normal unlocking in Steam.


 1.33:

    [FIXED][3] In Ch12, after the population is scattered during the Serpent's attack, people that come out confused from the forest are not a [FIXED] number anymore, but in percentage. This is part of a bigger fix of the whole Serpent/Caravan Population issue
    
    [FIXED][3] In Ch14, AFTER you confront Rugga and have a truce with him, you get back not only all the caravan's member that were scattered after the attack of the Serpent, but also, AS A PLUS, another 200 clansmen, 80 fighters and 30 warrior. This was a leftover of the old implementation of the event and now is [FIXED] as a part of a bigger fix of the whole Serpent/Caravan Population issue
    
    [FIXED][3] At the beginning of Ch14, you could retrieve ALL the people lost in the Serpent's attack (if Rugga's peaceful) or just and half of them (if you have to fight). Now the numbers are [TWEAKED] to keep in count also the scattered people of Ch12. This is part of a bigger fix of the whole Serpent/Caravan population issues

    [RESTORED][1] A hidden achievement: "Not Done Yet", awarded if you clear also the second wave of the Dredge, during the cleaning of debris blockade on the river

    [FIXED] At the beginning of Ch11, if you stayed outstide, you will suffer an ambush, but the text at the end of the battle (Victor or Loss), in which you resolve to go inside to talk with the Valka / Got saved by Gudmundr, will actually shows AFTER you talked with Zefr, just before opening the cart in the barn;

    [FIXED][1] At the end of Ch13, after the battle, Gudmundr is mentioned also if dead. Added a new version of the dialogue without any reference to him that will show only in case he is dead
    
    [FIXED] (ENG) Quite a bunch of typos/missing words in the dialogues, thanks to Ratatosk, who spotted most of them (for a detailed list, look here)
    
    [FIXED] (ENG) Lots of typos in map's, heroes', items' and whatever's descriptions, again thanks to Ratatosk (changes in "strings.json", here)
    

    [FIXED] (ENG) Two lines in which the trainer refers to "Nid/Yrsa" as "Oddleif", when they use "Rain of Arrow" ability, and viceversa refers to "Yrsa/Oddleif" as "Nid", when they use "Bird of Prey" ability
    
 1.2

    [TWEAKED] The starting difficulty setting from "Normal" to "Hard". Too often i have started a new game and noticed it was at "Normal" instead of "Hard" only after quite a while, maybe screwing also the achievment for hard in the meanwhile. So the change, since switching from "Hard" to "Normal" don't break any achievement. It's a personal tweak, but so minimal that i won't create a keep updated totally different pack just for my personal use, so it's included
    
    [FIXED] In the first part of Ch8 "Ship Kids" there is a bug that prevented the second part to occur, now it's [FIXED];

    [FIXED] In the second part of the "Ship Kids" event, in Ch8, there is some odd text displayed and it removes on clansmen more than it's supposed to, now theese are [FIXED];

    [FIXED] When sailing the river and noticing a burning village, in Ch8, there is an unnecessary variable setted (dagre_alive=0) if you "Ignore the village and head down river". It should not affect the gameplay, but i could cause unobvious behaviour or unexpected bugs;

    [FIXED] In the ending of Ch8, there is a missing linkpath in the conversation with Iver and Oddleif, before Hakon confronts Bolverk;

    [RESTORED] A conversation between Bolverk and Krumr, in which he explain a few things on himself and why he decided to go with Bolverk. It was not implemented, but, im my opinion, it's a really nice addition. It will fire up as soon as you camp, at the beginning of Ch9;

    [FIXED] In Ch9 you should experience FOUR random events, but due to some bugs and typo, only TWO happens, now this is [FIXED];

    [FIXED] In Ch9, the second part of Oli's "Gathering" random event is broken, not awarding the correct reward in one of the five possibilities, not showing another one of the possibilities and causing a console error due to a wrong speaker tag. Now it's [FIXED] and working as intended;

    [FIXED] In Ch10 "Hunting" random event, you will not get any supplies if you choose "Let the hunters hunt" , now you're awarded +10 supplies;

    [FIXED] When you defend Lundar, in Ch10, the event are handled in an odd manner and you could end getting two times the reward (and the clansmen joining) or nothing at all. Now all the events is redon in a much more rational and correct way, without inconsistencies;

    [FIXED] When you search houses in Bindal, Ch11, it's clearly stated that you return with an old drunk lady and 12 childern, but no clansmen are added. Now you get +13 clansmen;

    [TWEAKED] A converstaion between Bolverk and Sparr, in Ch11, that would trigger only if, in the event in which some clansmen go missing in the caves, you end up in a battle with skulkers (not if you manage to avoid the fight). What a waste, it's an enjoiable conversation! Now it will always triggers after that event, regardless of your choices, not just if you have to fight;

    [FIXED] A bug in Ch11 that prevented some lines of text showing just before Nikels sacrifice himself, depinding on if you've told him there is NO WAY he could be a Raven or given him a possibility, when you'll arrive in Manharr;

    [FIXED] At the end of Ch11, choosing "Step back" in the conversation regarding the Stonesinger, abruptly ends the dialogue;

    [FIXED] In the first part of Ch10/12 "Witch" random event, no clasnmen is added if the old lady joins you, nor supplies are removed when you give her food and water, now it's [FIXED];

    [FIXED] In the second part of Ch12 "Witch" random event, not clansmen is removed when the "witch" depart, now it's [FIXED];

    [FIXED] In Ch12 "Blue Fires" random event no morale is awarded when "The clansmen cheer your bravery and adventurous spirit", now you get +15 morale;

    [FIXED] (ENG) A typo in a Ch12 conversation with Rugga, after the fire in Ettingbekr event;

    [FIXED] In the dialogue at the end of Ch12, a line of text shows twice;

    [FIXED] In Ch13 "Hole" random event, "The others all cheer at your words" but no morale it's awarded, now you get +10 morale;

    [FIXED] In Ch13, Fasolt would like to take revenge of Rook/Alette for destroying the bridge in Saga1 when they don't and acts in a normal way if they've destroyed it. Now the conditions are correctly switched;

    [RESTORED] In Ch14 a random event that should have triggered after Canary and his herd join you, but it was probably left out (or it was a bug, who knows). It involves clansmen complaining on horseborns, cause they are "naked". Tweaking this event also have the side effect of letting Canary be avaible in the roster at the end of her first conversation, after the bridge battle, and not only in the last Arberrang battle. Probably in an early version of the game that series of events was planned to be a bit more complex, since in the gamefiles there are also leftovers of her joining with around 300 fighters and more. Anyway i don't want to umbalance the game, so just the text is [RESTORED] and you will not gain any fighters nor supplies;

    [FIXED] In Ch14, during the last fight in Arberrang sided with the King, chosing "Hakon, can you stop them at the gate?" will start a battle with the default "Charge" unit placement, now it's [FIXED] and in this case Hakon is properly ahead of the other units in a really forward (and risky) position.


[1]: These changes to work need some new strings/branch of dialogues, so they fully work only in English. In the other localizations their mechanics (rewards, bonus, malus etc.) work, but a “Missing text” message will be displayed instead of the current text. Sorry, I can’t translate those things in every localization, it would be really time consuming and I can’t even speak most of them!

[2]: Some achievements  correctly displays the flying text, but don’t award renown (“Against all Odds”, “The Saga continues”) and all the class ones (Kill 3 enemis with “X”), if unlocked in the training tent will not award renown too (works normally in other battles). Anyway I am pretty sure this happens also in the unmodified games, so there is no REAL loss of income in any case.

[3]: The whole handling of caravan's population lost/retrieved had a few logical flaws. Due to leftovers that added people out of nowhere and the rejoining of people saved by Rugga (Truce=100%; Battle=50% of people lost), not counting the few people retrieved just after the attack, you'll always end with more than you started. Oddly, the better result (around +300 people) happens in the case you should have retrieved just half of them. Enough talking, this is an example of how it works now,  with numbers taken directly from my current game:
   
------------------------------------------------------------------

Drake's & YaK's Fixpack for BS2 - version 2.0
[Works with the current version of Banner Saga 2, 2.39.02]

This is the active branch of the original Fixpack for Banner Saga 2, by YaK of all Trades (YaK#2186) and Drake713.

This corrects nasty bugs, inconsistencies and typos in the video game Banner Saga 2 by Stoic Studios.

Many thanks to:
Gestaltzerfall, who updated TBSDecompiler - http://www.mediafire.com/file/wun36alp6ojlkjk/TBS_Decompiler3.2.3.air/file
Ratatoskr
Drake713
Nafeij
Aleo

Please report any bugs in Issues.

------------------------------------------------------------------
INSTALLATION:
    Select 'CODE > Download ZIP'. Uncompress the zip archive and place the /tbs2 folder in your "../steamapps/common" folder. It will ask you to overwrite some files.
    
UNINSTALLATION:
    Just delete the files and rename the backups OR verify the integrity of game files in Steam.
    
------------------------------------------------------------------ 

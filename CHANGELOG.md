# Release Notes
> ## 3.1
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

> ## 3.0
> 16 May 2022
> - Importing a save using a version of Saga 2 with the BS2 fixpack installed causes discrepancies with Nid's upgrade points. She receives 8 more points than she's supposed to and her base version has -2 points.
> - Some of the animations are bugged during the chasm crossing sequence and when the serpent slides into the sea. The sprites would suddenly pop into existence and start moving, i.e. they don't have a persistent start state. Due to a missing `"start_visible": true` flag
> - Item duplication exploit: Whatever item Mogun has equipped will become duplicated if he is felled in his mutiny event. Similarly, equipping an item on Bolverk before the Insult/Axe storm training challenge causes his equipped item to become duped and bugged. Fixed by adding `UNIT_TRANSFER_ITEM` flags before each fight.
A related bug causes the player to lose whatever item he has equipped if they so choose to dismiss Hogun.
> - Bug in which horseborn lose their first active abilities at rank 7.
> - -WILL and -ARM per turn effects can cause willpower and armor stats to go negative. Fixed by adding `Math.max` cap in `\engine\battle\entity\model\BattleEntity`
> - -WILL items can cause willpower to be 'lost' when using horn (The charge goes away but you get no WIL if it's above your "new max WIL"). Fixed by changing the `getValue` to `getBase` in `\game\gui\HornHelper`
> - Several typos in conversations, popups and cutscene subtitles.
> - Gave Stonesingers +1 range
> - Nerfed the first training challenge in Saga 2. Only two enemies need to be damaged by Heavy Impact to pass the objective.

> ## 1.40
> - (ENG) Another three typos on the map, in the description of Skogr: "... the the beast …". The updated list of ALL changes in "strings.json", is here, download and open it in your browser)
> - (ENG) Another two typos in conversations, full details here, new ones on top)
> - No clansmen, fighters nor supplies are added when Aleo’s village joins. Now 39, 12 and 17 supplies are added after the conversation ends
> - The achievements in such way that most of them cause the flying text to show and award renown after the very first time too! It's important to know that this will prevent the normal unlocking in Steam.

> ## 1.33:
> - In Ch12, after the population is scattered during the Serpent's attack, people that come out confused from the forest are not a > - number anymore, but in percentage. This is part of a bigger fix of the whole Serpent/Caravan Population issue
> - In Ch14, AFTER you confront Rugga and have a truce with him, you get back not only all the caravan's member that were scattered after the attack of the Serpent, but also, AS A PLUS, another 200 clansmen, 80 fighters and 30 warrior. This was a leftover of the old implementation of the event and now is > - as a part of a bigger fix of the whole Serpent/Caravan Population issue
> - At the beginning of Ch14, you could retrieve ALL the people lost in the Serpent's attack (if Rugga's peaceful) or just and half of them (if you have to fight). Now the numbers are tweaked to keep in count also the scattered people of Ch12. This is part of a bigger fix of the whole Serpent/Caravan population issues
> - A hidden achievement: "Not Done Yet", awarded if you clear also the second wave of the Dredge, during the cleaning of debris blockade on the river
> - At the beginning of Ch11, if you stayed outstide, you will suffer an ambush, but the text at the end of the battle (Victor or Loss), in which you resolve to go inside to talk with the Valka / Got saved by Gudmundr, will actually shows AFTER you talked with Zefr, just before opening the cart in the barn;
> - At the end of Ch13, after the battle, Gudmundr is mentioned also if dead. Added a new version of the dialogue without any reference to him that will show only in case he is dead
> - (ENG) Quite a bunch of typos/missing words in the dialogues, thanks to Ratatosk, who spotted most of them (for a detailed list, look here)
> - (ENG) Lots of typos in map's, heroes', items' and whatever's descriptions, again thanks to Ratatosk (changes in "strings.json", here)
> - (ENG) Two lines in which the trainer refers to "Nid/Yrsa" as "Oddleif", when they use "Rain of Arrow" ability, and viceversa refers to "Yrsa/Oddleif" as "Nid", when they use "Bird of Prey" ability

> ## 1.2
> - The starting difficulty setting from "Normal" to "Hard". Too often i have started a new game and noticed it was at "Normal" instead of "Hard" only after quite a while, maybe screwing also the achievment for hard in the meanwhile. So the change, since switching from "Hard" to "Normal" don't break any achievement. It's a personal tweak, but so minimal that i won't create a keep updated totally different pack just for my personal use, so it's included
> - In the first part of Ch8 "Ship Kids" there is a bug that prevented the second part to occur, now it's > - ;
> - In the second part of the "Ship Kids" event, in Ch8, there is some odd text displayed and it removes on clansmen more than it's supposed to, now theese are > - ;
> - When sailing the river and noticing a burning village, in Ch8, there is an unnecessary variable setted (dagre_alive=0) if you "Ignore the village and head down river". It should not affect the gameplay, but i could cause unobvious behaviour or unexpected bugs;
> - In the ending of Ch8, there is a missing linkpath in the conversation with Iver and Oddleif, before Hakon confronts Bolverk;
> - A conversation between Bolverk and Krumr, in which he explain a few things on himself and why he decided to go with Bolverk. It was not implemented, but, im my opinion, it's a really nice addition. It will fire up as soon as you camp, at the beginning of Ch9;
> - In Ch9 you should experience FOUR random events, but due to some bugs and typo, only TWO happens, now this is > - ;
> - In Ch9, the second part of Oli's "Gathering" random event is broken, not awarding the correct reward in one of the five possibilities, not showing another one of the possibilities and causing a console error due to a wrong speaker tag. Now it's > - and working as intended;
> - In Ch10 "Hunting" random event, you will not get any supplies if you choose "Let the hunters hunt" , now you're awarded +10 supplies;
> - When you defend Lundar, in Ch10, the event are handled in an odd manner and you could end getting two times the reward (and the clansmen joining) or nothing at all. Now all the events is redon in a much more rational and correct way, without inconsistencies;
> - When you search houses in Bindal, Ch11, it's clearly stated that you return with an old drunk lady and 12 childern, but no clansmen are added. Now you get +13 clansmen;
> - A converstaion between Bolverk and Sparr, in Ch11, that would trigger only if, in the event in which some clansmen go missing in the caves, you end up in a battle with skulkers (not if you manage to avoid the fight). What a waste, it's an enjoiable conversation! Now it will always triggers after that event, regardless of your choices, not just if you have to fight;
> - A bug in Ch11 that prevented some lines of text showing just before Nikels sacrifice himself, depinding on if you've told him there is NO WAY he could be a Raven or given him a possibility, when you'll arrive in Manharr;
> - At the end of Ch11, choosing "Step back" in the conversation regarding the Stonesinger, abruptly ends the dialogue;
> - In the first part of Ch10/12 "Witch" random event, no clasnmen is added if the old lady joins you, nor supplies are removed when you give her food and water, now it's > - ;
> - In the second part of Ch12 "Witch" random event, not clansmen is removed when the "witch" depart, now it's > - ;
> - In Ch12 "Blue Fires" random event no morale is awarded when "The clansmen cheer your bravery and adventurous spirit", now you get +15 morale;
> - (ENG) A typo in a Ch12 conversation with Rugga, after the fire in Ettingbekr event;
> - In the dialogue at the end of Ch12, a line of text shows twice;
> - In Ch13 "Hole" random event, "The others all cheer at your words" but no morale it's awarded, now you get +10 morale;
> - In Ch13, Fasolt would like to take revenge of Rook/Alette for destroying the bridge in Saga1 when they don't and acts in a normal way if they've destroyed it. Now the conditions are correctly switched;
> - In Ch14 a random event that should have triggered after Canary and his herd join you, but it was probably left out (or it was a bug, who knows). It involves clansmen complaining on horseborns, cause they are "naked". Tweaking this event also have the side effect of letting Canary be avaible in the roster at the end of her first conversation, after the bridge battle, and not only in the last Arberrang battle. Probably in an early version of the game that series of events was planned to be a bit more complex, since in the gamefiles there are also leftovers of her joining with around 300 fighters and more. Anyway i don't want to umbalance the game, so just the text is > - and you will not gain any fighters nor supplies;
> - In Ch14, during the last fight in Arberrang sided with the King, chosing "Hakon, can you stop them at the gate?" will start a battle with the default "Charge" unit placement, now it's > - and in this case Hakon is properly ahead of the other units in a really forward (and risky) position.
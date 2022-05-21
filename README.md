 2.1 (Unreleased)
 
    [FIXED] Importing a save using a version of Saga 2 with the BS2 fixpack installed causes discrepancies with Nid's upgrade points. She receives 8 more points than she's supposed to and her base version has -2 points.
    
 2.0 
 
    [FIXED] (ENG) Typo: during Alette's final mending talk with Eyvind, before the serpent attacks, one line has a hanging character name, as follows: "[ evyind] You listen attentively..."
    
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
    Just uncompress the .zip in your "../steamapps/common" folder. It will ask you to overwrite some files, it's all right! The archive comes with backups just in case! (the ones with a .orig extension).
UNINSTALLATION:
    Just delete the files and rename the backups OR verify the integrity of game files in Steam.
    
------------------------------------------------------------------

Mirrors -  | 
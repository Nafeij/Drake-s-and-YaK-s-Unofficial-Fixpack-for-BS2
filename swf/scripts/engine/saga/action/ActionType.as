package engine.saga.action
{
   import engine.core.util.Enum;
   
   public class ActionType extends Enum
   {
      
      public static const NONE:ActionType = new ActionType("NONE",enumCtorKey);
      
      public static const SCENE:ActionType = new ActionType("SCENE",enumCtorKey);
      
      public static const TRAVEL:ActionType = new ActionType("TRAVEL",enumCtorKey);
      
      public static const CAMP:ActionType = new ActionType("CAMP",enumCtorKey);
      
      public static const DECAMP:ActionType = new ActionType("DECAMP",enumCtorKey);
      
      public static const TOWN:ActionType = new ActionType("TOWN",enumCtorKey);
      
      public static const CONVO:ActionType = new ActionType("CONVO",enumCtorKey);
      
      public static const POPUP:ActionType = new ActionType("POPUP",enumCtorKey);
      
      public static const TRAINING_SPAR:ActionType = new ActionType("TRAINING_SPAR",enumCtorKey);
      
      public static const BATTLE:ActionType = new ActionType("BATTLE",enumCtorKey);
      
      public static const BATTLE_ITEMS_DISABLED:ActionType = new ActionType("BATTLE_ITEMS_DISABLED",enumCtorKey);
      
      public static const BATTLE_DIFFICULTY_ENABLE:ActionType = new ActionType("BATTLE_DIFFICULTY_ENABLE",enumCtorKey);
      
      public static const BATTLE_MORALE_ENABLE:ActionType = new ActionType("BATTLE_MORALE_ENABLE",enumCtorKey);
      
      public static const BATTLE_MUSIC:ActionType = new ActionType("BATTLE_MUSIC",enumCtorKey);
      
      public static const BATTLE_STOP_MUSIC:ActionType = new ActionType("BATTLE_STOP_MUSIC",enumCtorKey);
      
      public static const BATTLE_WIN_MUSIC:ActionType = new ActionType("BATTLE_WIN_MUSIC",enumCtorKey);
      
      public static const BATTLE_LOSE_MUSIC:ActionType = new ActionType("BATTLE_LOSE_MUSIC",enumCtorKey);
      
      public static const BATTLE_HALT:ActionType = new ActionType("BATTLE_HALT",enumCtorKey);
      
      public static const BATTLE_RESPAWN:ActionType = new ActionType("BATTLE_RESPAWN",enumCtorKey);
      
      public static const BATTLE_SURRENDER:ActionType = new ActionType("BATTLE_SURRENDER",enumCtorKey);
      
      public static const BATTLE_UNIT_USE:ActionType = new ActionType("BATTLE_UNIT_USE",enumCtorKey);
      
      public static const BATTLE_UNIT_ENABLE:ActionType = new ActionType("BATTLE_UNIT_ENABLE",enumCtorKey);
      
      public static const BATTLE_UNIT_VISIBLE:ActionType = new ActionType("BATTLE_UNIT_VISIBLE",enumCtorKey);
      
      public static const BATTLE_UNIT_REMOVE:ActionType = new ActionType("BATTLE_UNIT_REMOVE",enumCtorKey);
      
      public static const BATTLE_UNIT_TELEPORT:ActionType = new ActionType("BATTLE_UNIT_TELEPORT",enumCtorKey);
      
      public static const BATTLE_UNIT_INTERACT:ActionType = new ActionType("BATTLE_UNIT_INTERACT",enumCtorKey);
      
      public static const BATTLE_UNIT_ACTIVATE:ActionType = new ActionType("BATTLE_UNIT_ACTIVATE",enumCtorKey);
      
      public static const BATTLE_SPAWN:ActionType = new ActionType("BATTLE_SPAWN",enumCtorKey);
      
      public static const BATTLE_READY:ActionType = new ActionType("BATTLE_READY",enumCtorKey);
      
      public static const BATTLE_UNIT_ABILITY:ActionType = new ActionType("BATTLE_UNIT_ABILITY",enumCtorKey);
      
      public static const BATTLE_UNIT_MOVE:ActionType = new ActionType("BATTLE_UNIT_MOVE",enumCtorKey);
      
      public static const BATTLE_NEXT_TURN:ActionType = new ActionType("BATTLE_NEXT_TURN",enumCtorKey);
      
      public static const BATTLE_GUI_ENABLE:ActionType = new ActionType("BATTLE_GUI_ENABLE",enumCtorKey);
      
      public static const BATTLE_CAMERA_CENTER:ActionType = new ActionType("BATTLE_CAMERA_CENTER",enumCtorKey);
      
      public static const BATTLE_MATCH_RESOLUTION_ENABLE:ActionType = new ActionType("BATTLE_MATCH_RESOLUTION_ENABLE",enumCtorKey);
      
      public static const BATTLE_WAIT_DEPLOYMENT_START:ActionType = new ActionType("BATTLE_WAIT_DEPLOYMENT_START",enumCtorKey);
      
      public static const BATTLE_SNAPSHOT_STORE:ActionType = new ActionType("BATTLE_SNAPSHOT_STORE",enumCtorKey);
      
      public static const BATTLE_SNAPSHOT_LOAD:ActionType = new ActionType("BATTLE_SNAPSHOT_LOAD",enumCtorKey);
      
      public static const BATTLE_WAIT_OBJECTIVE_OPENED:ActionType = new ActionType("BATTLE_WAIT_OBJECTIVE_OPENED",enumCtorKey);
      
      public static const BATTLE_WALKABLE:ActionType = new ActionType("BATTLE_WALKABLE",enumCtorKey);
      
      public static const BATTLE_ATTRACTOR_ENABLE:ActionType = new ActionType("BATTLE_ATTRACTOR_ENABLE",enumCtorKey);
      
      public static const BATTLE_UNIT_SHITLIST:ActionType = new ActionType("BATTLE_UNIT_SHITLIST",enumCtorKey);
      
      public static const BATTLE_UNIT_ON_START_TURN:ActionType = new ActionType("BATTLE_UNIT_ON_START_TURN",enumCtorKey);
      
      public static const BATTLE_UNIT_ON_END_TURN:ActionType = new ActionType("BATTLE_UNIT_ON_END_TURN",enumCtorKey);
      
      public static const BATTLE_UNIT_STAT:ActionType = new ActionType("BATTLE_UNIT_STAT",enumCtorKey);
      
      public static const BATTLE_INITIATIVE_RESET:ActionType = new ActionType("BATTLE_INITIATIVE_RESET",enumCtorKey);
      
      public static const BATTLE_CONTROLLER_CONFIG:ActionType = new ActionType("BATTLE_CONTROLLER_CONFIG",enumCtorKey);
      
      public static const BATTLE_HUD_CONFIG:ActionType = new ActionType("BATTLE_HUD_CONFIG",enumCtorKey);
      
      public static const BATTLE_TILE_MARKER:ActionType = new ActionType("BATTLE_TILE_MARKER",enumCtorKey);
      
      public static const BATTLE_SUPPRESS_FINISH:ActionType = new ActionType("BATTLE_SUPPRESS_FINISH",enumCtorKey);
      
      public static const BATTLE_SUPPRESS_TURN_END:ActionType = new ActionType("BATTLE_SUPPRESS_TURN_END",enumCtorKey);
      
      public static const BATTLE_SUPPRESS_PILLAGE:ActionType = new ActionType("BATTLE_SUPPRESS_PILLAGE",enumCtorKey);
      
      public static const BATTLE_WAIT_MOVE_START:ActionType = new ActionType("BATTLE_WAIT_MOVE_START",enumCtorKey);
      
      public static const BATTLE_WAIT_MOVE_STOP:ActionType = new ActionType("BATTLE_WAIT_MOVE_STOP",enumCtorKey);
      
      public static const BATTLE_WAIT_UNIT_KILLED:ActionType = new ActionType("BATTLE_WAIT_UNIT_KILLED",enumCtorKey);
      
      public static const BATTLE_WAIT_UNIT_INTERACTED:ActionType = new ActionType("BATTLE_WAIT_UNIT_INTERACTED",enumCtorKey);
      
      public static const BATTLE_WAIT_TURN_ABILITY:ActionType = new ActionType("BATTLE_WAIT_TURN_ABILITY",enumCtorKey);
      
      public static const BATTLE_END:ActionType = new ActionType("BATTLE_END",enumCtorKey);
      
      public static const BATTLE_TRIGGER_ENABLE:ActionType = new ActionType("BATTLE_TRIGGER_ENABLE",enumCtorKey);
      
      public static const FADEOUT:ActionType = new ActionType("FADEOUT",enumCtorKey);
      
      public static const BATTLE_AI_ENABLE:ActionType = new ActionType("BATTLE_AI_ENABLE",enumCtorKey);
      
      public static const BATTLE_UNIT_ATTRACT:ActionType = new ActionType("BATTLE_UNIT_ATTRACT",enumCtorKey);
      
      public static const VIDEO:ActionType = new ActionType("VIDEO",enumCtorKey);
      
      public static const CARAVAN:ActionType = new ActionType("CARAVAN",enumCtorKey);
      
      public static const CARAVAN_MERGE:ActionType = new ActionType("CARAVAN_MERGE",enumCtorKey);
      
      public static const LEADER:ActionType = new ActionType("LEADER",enumCtorKey);
      
      public static const VARIABLE_SET:ActionType = new ActionType("VARIABLE_SET",enumCtorKey);
      
      public static const VARIABLE_MODIFY:ActionType = new ActionType("VARIABLE_MODIFY",enumCtorKey);
      
      public static const VARIABLE_TWEEN:ActionType = new ActionType("VARIABLE_TWEEN",enumCtorKey);
      
      public static const HAPPENING:ActionType = new ActionType("HAPPENING",enumCtorKey);
      
      public static const HAPPENING_STOP:ActionType = new ActionType("HAPPENING_STOP",enumCtorKey);
      
      public static const BOOKMARK:ActionType = new ActionType("BOOKMARK",enumCtorKey);
      
      public static const ROSTER_REMOVE:ActionType = new ActionType("ROSTER_REMOVE",enumCtorKey);
      
      public static const ROSTER_ADD:ActionType = new ActionType("ROSTER_ADD",enumCtorKey);
      
      public static const ROSTER_CLEAR:ActionType = new ActionType("ROSTER_CLEAR",enumCtorKey);
      
      public static const PARTY_ADD:ActionType = new ActionType("PARTY_ADD",enumCtorKey);
      
      public static const PARTY_REMOVE:ActionType = new ActionType("PARTY_REMOVE",enumCtorKey);
      
      public static const PARTY_CLEAR:ActionType = new ActionType("PARTY_CLEAR",enumCtorKey);
      
      public static const KILL:ActionType = new ActionType("KILL",enumCtorKey);
      
      public static const ANNIHILATE:ActionType = new ActionType("ANNIHILATE",enumCtorKey);
      
      public static const WAIT:ActionType = new ActionType("WAIT",enumCtorKey);
      
      public static const SPEAK:ActionType = new ActionType("SPEAK",enumCtorKey);
      
      public static const HALT:ActionType = new ActionType("HALT",enumCtorKey);
      
      public static const WAR:ActionType = new ActionType("WAR",enumCtorKey);
      
      public static const SOUND_PLAY:ActionType = new ActionType("SOUND_PLAY",enumCtorKey);
      
      public static const SOUND_PLAY_SCENE:ActionType = new ActionType("SOUND_PLAY_SCENE",enumCtorKey);
      
      public static const SOUND_PLAY_EVENT:ActionType = new ActionType("SOUND_PLAY_EVENT",enumCtorKey);
      
      public static const SOUND_STOP:ActionType = new ActionType("SOUND_STOP",enumCtorKey);
      
      public static const SOUND_PARAM:ActionType = new ActionType("SOUND_PARAM",enumCtorKey);
      
      public static const SOUND_PARAM_EVENT:ActionType = new ActionType("SOUND_PARAM_EVENT",enumCtorKey);
      
      public static const ENABLE_LAYER:ActionType = new ActionType("ENABLE_LAYER",enumCtorKey);
      
      public static const ENABLE_SPRITE:ActionType = new ActionType("ENABLE_SPRITE",enumCtorKey);
      
      public static const ENABLE_CLICKABLE:ActionType = new ActionType("ENABLE_CLICKABLE",enumCtorKey);
      
      public static const SHOW_CARAVAN:ActionType = new ActionType("SHOW_CARAVAN",enumCtorKey);
      
      public static const CAMP_MAP:ActionType = new ActionType("CAMP_MAP",enumCtorKey);
      
      public static const FLASH_PAGE:ActionType = new ActionType("FLASH_PAGE",enumCtorKey);
      
      public static const MUSIC_START:ActionType = new ActionType("MUSIC_START",enumCtorKey);
      
      public static const MUSIC_STOP:ActionType = new ActionType("MUSIC_STOP",enumCtorKey);
      
      public static const MUSIC_PARAM:ActionType = new ActionType("MUSIC_PARAM",enumCtorKey);
      
      public static const MUSIC_ONESHOT:ActionType = new ActionType("MUSIC_ONESHOT",enumCtorKey);
      
      public static const MUSIC_INCIDENTAL:ActionType = new ActionType("MUSIC_INCIDENTAL",enumCtorKey);
      
      public static const MUSIC_OUTRO:ActionType = new ActionType("MUSIC_OUTRO",enumCtorKey);
      
      public static const VO:ActionType = new ActionType("VO",enumCtorKey);
      
      public static const ANIM_PLAY:ActionType = new ActionType("ANIM_PLAY",enumCtorKey);
      
      public static const ANIM_PATH_START:ActionType = new ActionType("ANIM_PATH_START",enumCtorKey);
      
      public static const WAIT_SCENE_VISIBLE:ActionType = new ActionType("WAIT_SCENE_VISIBLE",enumCtorKey);
      
      public static const WAIT_OPTIONS_SHOWING:ActionType = new ActionType("WAIT_OPTIONS_SHOWING",enumCtorKey);
      
      public static const WAIT_CLICK:ActionType = new ActionType("WAIT_CLICK",enumCtorKey);
      
      public static const WAIT_MAP_INFO:ActionType = new ActionType("WAIT_MAP_INFO",enumCtorKey);
      
      public static const WAIT_PAGE:ActionType = new ActionType("WAIT_PAGE",enumCtorKey);
      
      public static const WAIT_VARIABLE_INCREMENT:ActionType = new ActionType("WAIT_VARIABLE_INCREMENT",enumCtorKey);
      
      public static const WAIT_READY:ActionType = new ActionType("WAIT_READY",enumCtorKey);
      
      public static const WAIT_TRAVEL_FALL_COMPLETE:ActionType = new ActionType("WAIT_TRAVEL_FALL_COMPLETE",enumCtorKey);
      
      public static const WAIT_BATTLE_SETUP:ActionType = new ActionType("WAIT_BATTLE_SETUP",enumCtorKey);
      
      public static const CAMERA_PAN:ActionType = new ActionType("CAMERA_PAN",enumCtorKey);
      
      public static const CAMERA_SPLINE:ActionType = new ActionType("CAMERA_SPLINE",enumCtorKey);
      
      public static const CAMERA_SPLINE_PAUSE:ActionType = new ActionType("CAMERA_SPLINE_PAUSE",enumCtorKey);
      
      public static const CAMERA_CARAVAN_LOCK:ActionType = new ActionType("CAMERA_CARAVAN_LOCK",enumCtorKey);
      
      public static const CAMERA_CARAVAN_ANCHOR:ActionType = new ActionType("CAMERA_CARAVAN_ANCHOR",enumCtorKey);
      
      public static const CAMERA_GLOBAL_LOCK:ActionType = new ActionType("CAMERA_GLOBAL_LOCK",enumCtorKey);
      
      public static const CAMERA_ZOOM:ActionType = new ActionType("CAMERA_ZOOM",enumCtorKey);
      
      public static const ITEM_ADD:ActionType = new ActionType("ITEM_ADD",enumCtorKey);
      
      public static const ITEM_REMOVE:ActionType = new ActionType("ITEM_REMOVE",enumCtorKey);
      
      public static const ITEM_ALL:ActionType = new ActionType("ITEM_ALL",enumCtorKey);
      
      public static const MARKET_RESET_ITEMS:ActionType = new ActionType("MARKET_RESET_ITEMS",enumCtorKey);
      
      public static const MARKET_SHOW:ActionType = new ActionType("MARKET_SHOW",enumCtorKey);
      
      public static const SAVE_STORE:ActionType = new ActionType("SAVE_STORE",enumCtorKey);
      
      public static const SAVE_LOAD:ActionType = new ActionType("SAVE_LOAD",enumCtorKey);
      
      public static const SAVE_LOAD_MOST_RECENT:ActionType = new ActionType("SAVE_LOAD_MOST_RECENT",enumCtorKey);
      
      public static const SAVE_LOAD_SHOW_GUI:ActionType = new ActionType("SAVE_LOAD_SHOW_GUI",enumCtorKey);
      
      public static const DRIVING_SPEED:ActionType = new ActionType("DRIVING_SPEED",enumCtorKey);
      
      public static const MAP_SPLINE:ActionType = new ActionType("MAP_SPLINE",enumCtorKey);
      
      public static const ACHIEVEMENT:ActionType = new ActionType("ACHIEVEMENT",enumCtorKey);
      
      public static const UNIT_KILL_ADD:ActionType = new ActionType("UNIT_KILL_ADD",enumCtorKey);
      
      public static const UNIT_ABILITY_ADD:ActionType = new ActionType("UNIT_ABILITY_ADD",enumCtorKey);
      
      public static const UNIT_ABILITY_REMOVE:ActionType = new ActionType("UNIT_ABILITY_REMOVE",enumCtorKey);
      
      public static const UNIT_ABILITY_ENABLED:ActionType = new ActionType("UNIT_ABILITY_ENABLED",enumCtorKey);
      
      public static const UNIT_PASSIVE_ENABLED:ActionType = new ActionType("UNIT_PASSIVE_ENABLED",enumCtorKey);
      
      public static const UNIT_COPY_STAT:ActionType = new ActionType("UNIT_COPY_STAT",enumCtorKey);
      
      public static const UNIT_STAT:ActionType = new ActionType("UNIT_STAT",enumCtorKey);
      
      public static const UNIT_TRANSFER_ITEM:ActionType = new ActionType("UNIT_TRANSFER_ITEM",enumCtorKey);
      
      public static const UNIT_INJURE:ActionType = new ActionType("UNIT_INJURE",enumCtorKey);
      
      public static const UNIT_UNINJURE:ActionType = new ActionType("UNIT_UNINJURE",enumCtorKey);
      
      public static const UNIT_APPEARANCE:ActionType = new ActionType("UNIT_APPEARANCE",enumCtorKey);
      
      public static const END_CREDITS:ActionType = new ActionType("END_CREDITS",enumCtorKey);
      
      public static const END_CREDITS_WAITABLE:ActionType = new ActionType("END_CREDITS_WAITABLE",enumCtorKey);
      
      public static const GA_EVENT:ActionType = new ActionType("GA_EVENT",enumCtorKey);
      
      public static const GA_PAGE:ActionType = new ActionType("GA_PAGE",enumCtorKey);
      
      public static const GMA_EVENT:ActionType = new ActionType("GMA_EVENT",enumCtorKey);
      
      public static const WIPE_IN_CONFIG:ActionType = new ActionType("WIPE_IN_CONFIG",enumCtorKey);
      
      public static const START_PAGE:ActionType = new ActionType("START_PAGE",enumCtorKey);
      
      public static const FLYTEXT:ActionType = new ActionType("FLYTEXT",enumCtorKey);
      
      public static const TUTORIAL_POPUP:ActionType = new ActionType("TUTORIAL_POPUP",enumCtorKey);
      
      public static const TUTORIAL_REMOVE_ALL:ActionType = new ActionType("TUTORIAL_REMOVE_ALL",enumCtorKey);
      
      public static const ENABLE_SNOW:ActionType = new ActionType("ENABLE_SNOW",enumCtorKey);
      
      public static const CINEMA_FF_MARKER:ActionType = new ActionType("CINEMA_FF_MARKER",enumCtorKey);
      
      public static const FASTALL:ActionType = new ActionType("FASTALL",enumCtorKey);
      
      public static const GUI_SURVIVAL_SETUP:ActionType = new ActionType("GUI_SURVIVAL_SETUP",enumCtorKey);
      
      public static const GUI_SURVIVAL_BATTLE_POPUP:ActionType = new ActionType("GUI_SURVIVAL_BATTLE_POPUP",enumCtorKey);
      
      public static const GUI_DIALOG:ActionType = new ActionType("GUI_DIALOG",enumCtorKey);
      
      public static const SURVIVAL_WIN_PAGE:ActionType = new ActionType("SURVIVAL_WIN_PAGE",enumCtorKey);
      
      public static const SURVIVAL_COMPUTE_SCORE:ActionType = new ActionType("SURVIVAL_COMPUTE_SCORE",enumCtorKey);
      
      public static const OPEN_URL:ActionType = new ActionType("OPEN_URL",enumCtorKey);
      
      public static const DISPLAY_SHATTER_GUI:ActionType = new ActionType("DISPLAY_SHATTER_GUI",enumCtorKey);
      
      public static const DISPLAY_TALLY:ActionType = new ActionType("DISPLAY_TALLY",enumCtorKey);
      
      public static const DARKNESS_GUI_TRANSITION:ActionType = new ActionType("DARKNESS_GUI_TRANSITION",enumCtorKey);
      
      public static const SUBTITLE:ActionType = new ActionType("SUBTITLE",enumCtorKey);
      
      public static const PROP_SET_USABILITY:ActionType = new ActionType("PROP_SET_USABILITY",enumCtorKey);
      
      public static const ASSET_BUNDLE_CREATE:ActionType = new ActionType("ASSET_BUNDLE_CREATE",enumCtorKey);
      
      public static const ASSET_BUNDLE_RELEASE:ActionType = new ActionType("ASSET_BUNDLE_RELEASE",enumCtorKey);
      
      public static const ASSET_BUNDLE_MANIFEST:ActionType = new ActionType("ASSET_BUNDLE_MANIFEST",enumCtorKey);
      
      public static const ASSET_BUNDLE_WAIT:ActionType = new ActionType("ASSET_BUNDLE_WAIT",enumCtorKey);
       
      
      public function ActionType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}

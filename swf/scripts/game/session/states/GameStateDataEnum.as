package game.session.states
{
   import engine.core.fsm.StateDataEnum;
   
   public class GameStateDataEnum extends StateDataEnum
   {
      
      public static const NEW_GAME_PROFILE:GameStateDataEnum = new GameStateDataEnum("NEW_GAME_PROFILE",enumCtorKey);
      
      public static const SCENE_LOADER:GameStateDataEnum = new GameStateDataEnum("SCENE_LOADER",enumCtorKey);
      
      public static const SCENE_URL:GameStateDataEnum = new GameStateDataEnum("SCENE_URL",enumCtorKey);
      
      public static const BATTLE_SCENE_ID:GameStateDataEnum = new GameStateDataEnum("BATTLE_SCENE_ID",enumCtorKey);
      
      public static const BATTLE_TIMER_SECS:GameStateDataEnum = new GameStateDataEnum("BATTLE_TIMER_SECS",enumCtorKey);
      
      public static const FORCE_OPPONENT_ID:GameStateDataEnum = new GameStateDataEnum("FORCE_OPPONENT_ID",enumCtorKey);
      
      public static const BATTLE_CREATE_DATA:GameStateDataEnum = new GameStateDataEnum("BATTLE_CREATE_DATA",enumCtorKey);
      
      public static const BATTLE_FRIEND_LOBBY_ID:GameStateDataEnum = new GameStateDataEnum("BATTLE_FRIEND_LOBBY_ID",enumCtorKey);
      
      public static const SCENELOADER_PRESERVE:GameStateDataEnum = new GameStateDataEnum("SCENELOADER_PRESERVE",enumCtorKey);
      
      public static const LOCAL_TIMER_SECS:GameStateDataEnum = new GameStateDataEnum("LOCAL_TIMER_SECS",enumCtorKey);
      
      public static const LOCAL_PARTY:GameStateDataEnum = new GameStateDataEnum("LOCAL_PARTY",enumCtorKey);
      
      public static const OPPONENT_ID:GameStateDataEnum = new GameStateDataEnum("OPPONENT_ID",enumCtorKey);
      
      public static const OPPONENT_NAME:GameStateDataEnum = new GameStateDataEnum("OPPONENT_NAME",enumCtorKey);
      
      public static const OPPONENT_PARTY:GameStateDataEnum = new GameStateDataEnum("OPPONENT_PARTY",enumCtorKey);
      
      public static const PLAYER_ORDER:GameStateDataEnum = new GameStateDataEnum("PLAYER_ORDER",enumCtorKey);
      
      public static const SERVER_MESSAGE:GameStateDataEnum = new GameStateDataEnum("SERVER_MESSAGE",enumCtorKey);
      
      public static const AUTOLOGIN:GameStateDataEnum = new GameStateDataEnum("AUTOLOGIN",enumCtorKey);
      
      public static const BUILD_NUMBER:GameStateDataEnum = new GameStateDataEnum("BUILD_NUMBER",enumCtorKey);
      
      public static const SHOW_LOGIN_SCREEN:GameStateDataEnum = new GameStateDataEnum("SHOW_LOGIN_SCREEN",enumCtorKey);
      
      public static const REMATCH:GameStateDataEnum = new GameStateDataEnum("REMATCH",enumCtorKey);
      
      public static const VIDEO_NEXT_STATE:GameStateDataEnum = new GameStateDataEnum("VIDEO_NEXT_STATE",enumCtorKey);
      
      public static const VIDEO_PARAMS:GameStateDataEnum = new GameStateDataEnum("VIDEO_PARAMS",enumCtorKey);
      
      public static const FLASH_URL:GameStateDataEnum = new GameStateDataEnum("FLASH_URL",enumCtorKey);
      
      public static const FLASH_TIME:GameStateDataEnum = new GameStateDataEnum("FLASH_TIME",enumCtorKey);
      
      public static const FLASH_MSG:GameStateDataEnum = new GameStateDataEnum("FLASH_MSG",enumCtorKey);
      
      public static const FLASH_LOCALE:GameStateDataEnum = new GameStateDataEnum("FLASH_LOCALE",enumCtorKey);
      
      public static const DISABLE_PAGE_CLOSE_BUTTON:GameStateDataEnum = new GameStateDataEnum("DISABLE_PAGE_CLOSE_BUTTON",enumCtorKey);
      
      public static const VERSUS_TOURNEY_ID:GameStateDataEnum = new GameStateDataEnum("VERSUS_TOURNEY_ID",enumCtorKey);
      
      public static const VERSUS_RESTART:GameStateDataEnum = new GameStateDataEnum("VERSUS_RESTART",enumCtorKey);
      
      public static const SCENE_AUTOPAN:GameStateDataEnum = new GameStateDataEnum("SCENE_AUTOPAN",enumCtorKey);
      
      public static const VERSUS_TYPE:GameStateDataEnum = new GameStateDataEnum("VERSUS_TYPE",enumCtorKey);
      
      public static const CONVO:GameStateDataEnum = new GameStateDataEnum("CONVO",enumCtorKey);
      
      public static const SAGA_URL:GameStateDataEnum = new GameStateDataEnum("SAGA_URL",enumCtorKey);
      
      public static const HAPPENING_ID:GameStateDataEnum = new GameStateDataEnum("HAPPENING_ID",enumCtorKey);
      
      public static const SAGA_SAVELOAD:GameStateDataEnum = new GameStateDataEnum("SAGA_SAVELOAD",enumCtorKey);
      
      public static const SAGA_SAVELOAD_PROFILE:GameStateDataEnum = new GameStateDataEnum("SAGA_SAVELOAD_PROFILE",enumCtorKey);
      
      public static const AUTH_REQUIRE:GameStateDataEnum = new GameStateDataEnum("AUTH_REQUIRE",enumCtorKey);
      
      public static const TRAVEL_LOCATOR:GameStateDataEnum = new GameStateDataEnum("TRAVEL_LOCATOR",enumCtorKey);
      
      public static const TRAVEL_FALL_DATA:GameStateDataEnum = new GameStateDataEnum("TRAVEL_FALL_DATA",enumCtorKey);
      
      public static const SCENE_IS_TOWN:GameStateDataEnum = new GameStateDataEnum("SCENE_IS_TOWN",enumCtorKey);
      
      public static const BATTLE_INFO:GameStateDataEnum = new GameStateDataEnum("BATTLE_INFO",enumCtorKey);
      
      public static const BATTLE_MUSIC_DEF_URL:GameStateDataEnum = new GameStateDataEnum("BATTLE_MUSIC_DEF_URL",enumCtorKey);
      
      public static const BATTLE_MUSIC_OVERRIDE:GameStateDataEnum = new GameStateDataEnum("BATTLE_MUSIC_OVERRIDE",enumCtorKey);
      
      public static const BATTLE_VITALITIES:GameStateDataEnum = new GameStateDataEnum("BATTLE_VITALITIES",enumCtorKey);
      
      public static const WIPEIN_HOLD:GameStateDataEnum = new GameStateDataEnum("WIPEIN_HOLD",enumCtorKey);
      
      public static const WIPEIN_DURATION:GameStateDataEnum = new GameStateDataEnum("WIPEIN_DURATION",enumCtorKey);
       
      
      public function GameStateDataEnum(param1:String, param2:*)
      {
         super(param1,param2);
      }
   }
}

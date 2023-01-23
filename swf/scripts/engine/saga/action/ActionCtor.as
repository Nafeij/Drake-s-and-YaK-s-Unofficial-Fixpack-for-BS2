package engine.saga.action
{
   import engine.saga.Saga;
   
   public class ActionCtor
   {
       
      
      public function ActionCtor()
      {
         super();
      }
      
      public static function ctor(param1:ActionDef, param2:Saga) : Action
      {
         switch(param1.type)
         {
            case ActionType.TRAVEL:
               return new Action_Travel(param1,param2);
            case ActionType.CAMP:
               return new Action_Camp(param1,param2);
            case ActionType.CAMP_MAP:
               return new Action_CampMap(param1,param2);
            case ActionType.DECAMP:
               return new Action_Decamp(param1,param2);
            case ActionType.HALT:
               return new Action_Halt(param1,param2);
            case ActionType.TOWN:
               return new Action_Town(param1,param2);
            case ActionType.CONVO:
               return new Action_Convo(param1,param2);
            case ActionType.POPUP:
               return new Action_Convo(param1,param2);
            case ActionType.VIDEO:
               return new Action_Video(param1,param2);
            case ActionType.CARAVAN:
               return new Action_Caravan(param1,param2);
            case ActionType.VARIABLE_TWEEN:
               return new Action_TweenVariable(param1,param2);
            case ActionType.VARIABLE_SET:
               return new Action_VariableSet(param1,param2);
            case ActionType.VARIABLE_MODIFY:
               return new Action_VariableModify(param1,param2);
            case ActionType.HAPPENING:
               return new Action_Happening(param1,param2);
            case ActionType.HAPPENING_STOP:
               return new Action_HappeningStop(param1,param2);
            case ActionType.BOOKMARK:
               return new Action_Bookmark(param1,param2);
            case ActionType.KILL:
               return new Action_Kill(param1,param2);
            case ActionType.ANNIHILATE:
               return new Action_Annihilate(param1,param2);
            case ActionType.ROSTER_CLEAR:
               return new Action_RosterClear(param1,param2);
            case ActionType.ROSTER_REMOVE:
               return new Action_RosterRemove(param1,param2);
            case ActionType.ROSTER_ADD:
               return new Action_RosterAdd(param1,param2);
            case ActionType.PARTY_ADD:
               return new Action_PartyAdd(param1,param2);
            case ActionType.PARTY_REMOVE:
               return new Action_PartyRemove(param1,param2);
            case ActionType.PARTY_CLEAR:
               return new Action_PartyClear(param1,param2);
            case ActionType.WAIT:
               return new Action_Wait(param1,param2);
            case ActionType.SPEAK:
               return new Action_Speak(param1,param2);
            case ActionType.BATTLE:
               return new Action_Battle(param1,param2);
            case ActionType.SCENE:
               return new Action_Scene(param1,param2);
            case ActionType.WAR:
               return new Action_War(param1,param2);
            case ActionType.SOUND_PLAY:
               return new Action_SoundPlay(param1,param2);
            case ActionType.SOUND_PLAY_SCENE:
               return new Action_SoundPlayScene(param1,param2);
            case ActionType.SOUND_PLAY_EVENT:
               return new Action_SoundPlayEvent(param1,param2);
            case ActionType.SOUND_STOP:
               return new Action_SoundStop(param1,param2);
            case ActionType.SOUND_PARAM:
               return new Action_SoundParam(param1,param2);
            case ActionType.SOUND_PARAM_EVENT:
               return new Action_SoundParamEvent(param1,param2);
            case ActionType.ENABLE_LAYER:
               return new Action_EnableLayer(param1,param2);
            case ActionType.ENABLE_SPRITE:
               return new Action_EnableSprite(param1,param2);
            case ActionType.ENABLE_CLICKABLE:
               return new Action_EnableClickable(param1,param2);
            case ActionType.SHOW_CARAVAN:
               return new Action_ShowCaravan(param1,param2);
            case ActionType.FLASH_PAGE:
               return new Action_FlashPage(param1,param2);
            case ActionType.MUSIC_START:
               return new Action_MusicStart(param1,param2);
            case ActionType.MUSIC_STOP:
               return new Action_MusicStop(param1,param2);
            case ActionType.MUSIC_PARAM:
               return new Action_MusicParam(param1,param2);
            case ActionType.MUSIC_ONESHOT:
               return new Action_MusicOneshot(param1,param2);
            case ActionType.MUSIC_OUTRO:
               return new Action_MusicOutro(param1,param2);
            case ActionType.MUSIC_INCIDENTAL:
               return new Action_MusicIncidental(param1,param2);
            case ActionType.VO:
               return new Action_Vo(param1,param2);
            case ActionType.ANIM_PLAY:
               return new Action_AnimPlay(param1,param2);
            case ActionType.ANIM_PATH_START:
               return new Action_AnimPathStart(param1,param2);
            case ActionType.WAIT_READY:
               return new Action_WaitReady(param1,param2);
            case ActionType.WAIT_TRAVEL_FALL_COMPLETE:
               return new Action_WaitTravelFallComplete(param1,param2);
            case ActionType.WAIT_VARIABLE_INCREMENT:
               return new Action_WaitVariableIncrement(param1,param2);
            case ActionType.WAIT_SCENE_VISIBLE:
               return new Action_WaitSceneVisible(param1,param2);
            case ActionType.WAIT_BATTLE_SETUP:
               return new Action_WaitBattleSetup(param1,param2);
            case ActionType.CAMERA_PAN:
               return new Action_CameraPan(param1,param2);
            case ActionType.CAMERA_SPLINE:
               return new Action_CameraSpline(param1,param2);
            case ActionType.CAMERA_SPLINE_PAUSE:
               return new Action_CameraSplinePause(param1,param2);
            case ActionType.CAMERA_CARAVAN_LOCK:
               return new Action_CameraCaravanLock(param1,param2);
            case ActionType.CAMERA_GLOBAL_LOCK:
               return new Action_CameraGlobalLock(param1,param2);
            case ActionType.CAMERA_ZOOM:
               return new Action_CameraZoom(param1,param2);
            case ActionType.CAMERA_CARAVAN_ANCHOR:
               return new Action_CameraCaravanAnchor(param1,param2);
            case ActionType.ITEM_ADD:
               return new Action_ItemAdd(param1,param2);
            case ActionType.ITEM_REMOVE:
               return new Action_ItemRemove(param1,param2);
            case ActionType.ITEM_ALL:
               return new Action_ItemAll(param1,param2);
            case ActionType.MARKET_RESET_ITEMS:
               return new Action_MarketResetItems(param1,param2);
            case ActionType.SAVE_STORE:
               return new Action_SaveStore(param1,param2);
            case ActionType.SAVE_LOAD:
               return new Action_SaveLoad(param1,param2);
            case ActionType.DRIVING_SPEED:
               return new Action_DrivingSpeed(param1,param2);
            case ActionType.MAP_SPLINE:
               return new Action_MapSpline(param1,param2);
            case ActionType.LEADER:
               return new Action_Leader(param1,param2);
            case ActionType.ACHIEVEMENT:
               return new Action_Achievement(param1,param2);
            case ActionType.UNIT_KILL_ADD:
               return new Action_UnitKillAdd(param1,param2);
            case ActionType.UNIT_ABILITY_ADD:
               return new Action_UnitAbilityAdd(param1,param2);
            case ActionType.UNIT_ABILITY_REMOVE:
               return new Action_UnitAbilityRemove(param1,param2);
            case ActionType.UNIT_ABILITY_ENABLED:
               return new Action_UnitAbilityEnabled(param1,param2);
            case ActionType.UNIT_PASSIVE_ENABLED:
               return new Action_UnitPassiveEnabled(param1,param2);
            case ActionType.UNIT_COPY_STAT:
               return new Action_UnitCopyStat(param1,param2);
            case ActionType.UNIT_TRANSFER_ITEM:
               return new Action_UnitTransferItem(param1,param2);
            case ActionType.UNIT_INJURE:
               return new Action_UnitInjure(param1,param2);
            case ActionType.UNIT_UNINJURE:
               return new Action_UnitUninjure(param1,param2);
            case ActionType.UNIT_STAT:
               return new Action_UnitStat(param1,param2);
            case ActionType.UNIT_APPEARANCE:
               return new Action_UnitAppearance(param1,param2);
            case ActionType.END_CREDITS:
               return new Action_EndCredits(param1,param2);
            case ActionType.END_CREDITS_WAITABLE:
               return new Action_EndCreditsWaitable(param1,param2);
            case ActionType.GA_EVENT:
               return new Action_GaEvent(param1,param2);
            case ActionType.GA_PAGE:
               return new Action_GaPage(param1,param2);
            case ActionType.GMA_EVENT:
               return new Action_GmaEvent(param1,param2);
            case ActionType.WIPE_IN_CONFIG:
               return new Action_WipeInConfig(param1,param2);
            case ActionType.SAVE_LOAD_MOST_RECENT:
               return new Action_SaveLoadMostRecent(param1,param2);
            case ActionType.SAVE_LOAD_SHOW_GUI:
               return new Action_SaveLoadShowGui(param1,param2);
            case ActionType.START_PAGE:
               return new Action_StartPage(param1,param2);
            case ActionType.CARAVAN_MERGE:
               return new Action_CaravanMerge(param1,param2);
            case ActionType.FLYTEXT:
               return new Action_FlyText(param1,param2);
            case ActionType.BATTLE_MUSIC:
               return new Action_BattleMusic(param1,param2);
            case ActionType.BATTLE_STOP_MUSIC:
               return new Action_BattleStopMusic(param1,param2);
            case ActionType.BATTLE_WIN_MUSIC:
               return new Action_BattleWinMusic(param1,param2);
            case ActionType.BATTLE_LOSE_MUSIC:
               return new Action_BattleLoseMusic(param1,param2);
            case ActionType.BATTLE_HALT:
               return new Action_BattleHalt(param1,param2);
            case ActionType.BATTLE_SURRENDER:
               return new Action_BattleSurrender(param1,param2);
            case ActionType.TUTORIAL_POPUP:
               return new Action_TutorialPopup(param1,param2);
            case ActionType.TUTORIAL_REMOVE_ALL:
               return new Action_TutorialRemoveAll(param1,param2);
            case ActionType.ENABLE_SNOW:
               return new Action_EnableSnow(param1,param2);
            case ActionType.BATTLE_UNIT_ENABLE:
               return new Action_BattleUnitEnable(param1,param2);
            case ActionType.BATTLE_UNIT_USE:
               return new Action_BattleUnitUse(param1,param2);
            case ActionType.BATTLE_UNIT_INTERACT:
               return new Action_BattleUnitInteract(param1,param2);
            case ActionType.BATTLE_READY:
               return new Action_BattleReady(param1,param2);
            case ActionType.BATTLE_UNIT_ABILITY:
               return new Action_BattleUnitAbility(param1,param2);
            case ActionType.BATTLE_UNIT_MOVE:
               return new Action_BattleUnitMove(param1,param2);
            case ActionType.BATTLE_WAIT_UNIT_INTERACTED:
               return new Action_BattleWaitUnitInteracted(param1,param2);
            case ActionType.BATTLE_WAIT_TURN_ABILITY:
               return new Action_BattleWaitTurnAbility(param1,param2);
            case ActionType.BATTLE_NEXT_TURN:
               return new Action_BattleNextTurn(param1,param2);
            case ActionType.BATTLE_GUI_ENABLE:
               return new Action_BattleGuiEnable(param1,param2);
            case ActionType.BATTLE_CAMERA_CENTER:
               return new Action_BattleCameraCenter(param1,param2);
            case ActionType.BATTLE_UNIT_STAT:
               return new Action_BattleUnitStat(param1,param2);
            case ActionType.BATTLE_INITIATIVE_RESET:
               return new Action_BattleInitiativeReset(param1,param2);
            case ActionType.BATTLE_WAIT_MOVE_STOP:
               return new Action_BattleWaitMoveStop(param1,param2);
            case ActionType.BATTLE_WAIT_MOVE_START:
               return new Action_BattleWaitMoveStart(param1,param2);
            case ActionType.BATTLE_WAIT_UNIT_KILLED:
               return new Action_BattleWaitUnitKilled(param1,param2);
            case ActionType.BATTLE_AI_ENABLE:
               return new Action_BattleAiEnable(param1,param2);
            case ActionType.BATTLE_CONTROLLER_CONFIG:
               return new Action_BattleControllerConfig(param1,param2);
            case ActionType.BATTLE_HUD_CONFIG:
               return new Action_BattleHudConfig(param1,param2);
            case ActionType.BATTLE_TILE_MARKER:
               return new Action_BattleTileMarker(param1,param2);
            case ActionType.BATTLE_SUPPRESS_TURN_END:
               return new Action_BattleSuppressTurnEnd(param1,param2);
            case ActionType.BATTLE_SUPPRESS_FINISH:
               return new Action_BattleSuppressFinish(param1,param2);
            case ActionType.BATTLE_SUPPRESS_PILLAGE:
               return new Action_BattleSuppressPillage(param1,param2);
            case ActionType.BATTLE_MATCH_RESOLUTION_ENABLE:
               return new Action_BattleMatchResolutionEnable(param1,param2);
            case ActionType.BATTLE_WAIT_DEPLOYMENT_START:
               return new Action_BattleWaitDeploymentStart(param1,param2);
            case ActionType.BATTLE_END:
               return new Action_BattleEnd(param1,param2);
            case ActionType.BATTLE_TRIGGER_ENABLE:
               return new Action_BattleTriggerEnable(param1,param2);
            case ActionType.FADEOUT:
               return new Action_Fadeout(param1,param2);
            case ActionType.BATTLE_UNIT_ACTIVATE:
               return new Action_BattleUnitActivate(param1,param2);
            case ActionType.BATTLE_SPAWN:
               return new Action_BattleSpawn(param1,param2);
            case ActionType.BATTLE_RESPAWN:
               return new Action_BattleRespawn(param1,param2);
            case ActionType.BATTLE_UNIT_ON_START_TURN:
               return new Action_BattleUnitOnStartTurn(param1,param2);
            case ActionType.BATTLE_UNIT_ON_END_TURN:
               return new Action_BattleUnitOnEndTurn(param1,param2);
            case ActionType.FASTALL:
               return new Action_Fastall(param1,param2);
            case ActionType.BATTLE_DIFFICULTY_ENABLE:
               return new Action_BattleDifficultyEnable(param1,param2);
            case ActionType.BATTLE_MORALE_ENABLE:
               return new Action_BattleMoraleEnable(param1,param2);
            case ActionType.TRAINING_SPAR:
               return new Action_TrainingSpar(param1,param2);
            case ActionType.MARKET_SHOW:
               return new Action_MarketShow(param1,param2);
            case ActionType.BATTLE_SNAPSHOT_STORE:
               return new Action_BattleSnapshotStore(param1,param2);
            case ActionType.BATTLE_SNAPSHOT_LOAD:
               return new Action_BattleSnapshotLoad(param1,param2);
            case ActionType.GUI_DIALOG:
               return new Action_GuiDialog(param1,param2);
            case ActionType.BATTLE_UNIT_REMOVE:
               return new Action_BattleUnitRemove(param1,param2);
            case ActionType.BATTLE_UNIT_TELEPORT:
               return new Action_BattleUnitTeleport(param1,param2);
            case ActionType.BATTLE_WAIT_OBJECTIVE_OPENED:
               return new Action_BattleWaitObjectiveOpened(param1,param2);
            case ActionType.BATTLE_ITEMS_DISABLED:
               return new Action_BattleItemsDisabled(param1,param2);
            case ActionType.WAIT_PAGE:
               return new Action_WaitPage(param1,param2);
            case ActionType.WAIT_CLICK:
               return new Action_WaitClick(param1,param2);
            case ActionType.WAIT_MAP_INFO:
               return new Action_WaitMapInfo(param1,param2);
            case ActionType.WAIT_OPTIONS_SHOWING:
               return new Action_WaitOptionsShowing(param1,param2);
            case ActionType.GUI_SURVIVAL_SETUP:
               return new Action_GuiSurvivalSetup(param1,param2);
            case ActionType.GUI_SURVIVAL_BATTLE_POPUP:
               return new Action_GuiSurvivalBattlePopup(param1,param2);
            case ActionType.SURVIVAL_WIN_PAGE:
               return new Action_SurvivalWin(param1,param2);
            case ActionType.SURVIVAL_COMPUTE_SCORE:
               return new Action_SurvivalComputeScore(param1,param2);
            case ActionType.BATTLE_UNIT_VISIBLE:
               return new Action_BattleUnitVisible(param1,param2);
            case ActionType.BATTLE_UNIT_ATTRACT:
               return new Action_BattleUnitAttract(param1,param2);
            case ActionType.BATTLE_UNIT_SHITLIST:
               return new Action_BattleUnitShitlist(param1,param2);
            case ActionType.OPEN_URL:
               return new Action_OpenUrl(param1,param2);
            case ActionType.DISPLAY_SHATTER_GUI:
               return new Action_DisplayShatterGui(param1,param2);
            case ActionType.DISPLAY_TALLY:
               return new Action_DisplayTally(param1,param2);
            case ActionType.BATTLE_ATTRACTOR_ENABLE:
               return new Action_BattleAttractorEnable(param1,param2);
            case ActionType.BATTLE_WALKABLE:
               return new Action_BattleWalkable(param1,param2);
            case ActionType.DARKNESS_GUI_TRANSITION:
               return new Action_DarknessGuiTransition(param1,param2);
            case ActionType.SUBTITLE:
               return new Action_Subtitle(param1,param2);
            case ActionType.PROP_SET_USABILITY:
               return new Action_PropSetUsability(param1,param2);
            case ActionType.ASSET_BUNDLE_CREATE:
               return new Action_AssetBundleCreate(param1,param2);
            case ActionType.ASSET_BUNDLE_RELEASE:
               return new Action_AssetBundleCreate(param1,param2);
            case ActionType.ASSET_BUNDLE_MANIFEST:
               return new Action_AssetBundleCreate(param1,param2);
            case ActionType.ASSET_BUNDLE_WAIT:
               return new Action_AssetBundleCreate(param1,param2);
            default:
               throw new ArgumentError("Not handled: " + param1);
         }
      }
   }
}

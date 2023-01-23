package game.gui
{
   import engine.ability.IAbilityDef;
   import engine.achievement.AchievementDef;
   import engine.battle.SceneListDef;
   import engine.entity.UnitStatCosts;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityClassDef;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.ITitleDef;
   import engine.gui.BattleHudConfig;
   import engine.gui.IEngineGuiContext;
   import engine.gui.IGuiSound;
   import engine.resource.ResourceGroup;
   import engine.saga.ISaga;
   import engine.saga.Saga;
   import engine.session.IIapManager;
   import engine.tourney.TourneyDefList;
   import flash.events.IEventDispatcher;
   import tbs.srv.data.FriendData;
   import tbs.srv.data.FriendsData;
   import tbs.srv.util.PurchaseCounts;
   import tbs.srv.util.Tourney;
   import tbs.srv.util.TourneyProgressData;
   import tbs.srv.util.TourneyWinnerData;
   import tbs.srv.util.UnlockData;
   
   public interface IGuiContext extends IEventDispatcher, IGuiSound, IEngineGuiContext
   {
       
      
      function get account_id() : int;
      
      function get username() : String;
      
      function get displayname() : String;
      
      function get saga() : Saga;
      
      function get iSaga() : ISaga;
      
      function getAchievementDef(param1:String) : AchievementDef;
      
      function getEntityClassPortrait(param1:IEntityDef, param2:Boolean) : GuiIcon;
      
      function getEntityIconAtAppIndex(param1:IEntityClassDef, param2:EntityIconType, param3:int) : GuiIcon;
      
      function getEntityIcon(param1:IEntityDef, param2:EntityIconType) : GuiIcon;
      
      function getAwardIcon(param1:String) : GuiIcon;
      
      function getAbilityBuffIcon(param1:IAbilityDef) : GuiIcon;
      
      function getTitleBuffIcon(param1:ITitleDef) : GuiIcon;
      
      function getAbilityIcon(param1:IAbilityDef) : GuiIcon;
      
      function getLargeAbilityIcon(param1:IAbilityDef) : GuiIcon;
      
      function getEntityVersusPortrait(param1:IEntityDef) : GuiIcon;
      
      function getEntityAppearancePromotePortrait(param1:IEntityAppearanceDef) : GuiIcon;
      
      function getEntityClassPromotePortraitAtAppIndex(param1:IEntityClassDef, param2:int) : GuiIcon;
      
      function getEntityPromotePortrait(param1:IEntityDef) : GuiIcon;
      
      function getFriendAvatar(param1:FriendData, param2:int) : GuiIcon;
      
      function getAnimClip(param1:String) : GuiIcon;
      
      function getIcon(param1:String) : GuiIcon;
      
      function getIconResourceGroup(param1:String, param2:ResourceGroup) : GuiIcon;
      
      function get statCosts() : UnitStatCosts;
      
      function getCrownChitIcon() : GuiIcon;
      
      function getCrownIcon() : GuiIcon;
      
      function createDialog() : IGuiDialog;
      
      function removeDialog(param1:IGuiDialog) : void;
      
      function get dialog() : IGuiDialog;
      
      function get friends() : FriendsData;
      
      function get sceneList() : SceneListDef;
      
      function get iap() : IIapManager;
      
      function getUnlock(param1:String) : UnlockData;
      
      function hasUnlock(param1:String) : Boolean;
      
      function get purchases() : PurchaseCounts;
      
      function get tourney() : Tourney;
      
      function get tourneyWinner() : TourneyWinnerData;
      
      function get tourneyProgress() : TourneyProgressData;
      
      function joinTourney(param1:int, param2:Function) : void;
      
      function get tourneyDefList() : TourneyDefList;
      
      function setTutorialPopupVisible(param1:int, param2:Boolean) : void;
      
      function get battleHudConfig() : BattleHudConfig;
      
      function get isSagaStartPage() : Boolean;
      
      function showOptions() : void;
      
      function get censorId() : String;
      
      function get isSagaPaused() : Boolean;
      
      function get isShowingOptions() : Boolean;
      
      function showGaOptStateDialog(param1:IGaOptStateDialogListener) : void;
   }
}

package game.session.states.tutorial
{
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.scene.view.SceneViewSprite;
   import flash.events.Event;
   import game.session.states.TownState;
   
   public class TutorialTownState extends TownState
   {
       
      
      private var _view:SceneViewSprite;
      
      public var helper:HelperTutorialState;
      
      public function TutorialTownState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
         this.helper = new HelperTutorialState(this,[this.mode_help,this.mode_meadhouse]);
      }
      
      public function mode_help(param1:Function) : void
      {
         var self:Function = param1;
         helpEnabled = true;
         this.helper.tt = config.tutorialLayer.createTooltip("TownPage|assets.corner_help_se",TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.LEFT,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_town_help_mode"),true,false,0);
         logger.info("mode_help register " + this._view);
         this._view.addEventListener(SceneViewSprite.EVENT_SHOW_HELP,function helpHandler(param1:Event):void
         {
            logger.info("mode_help saw " + _view);
            _view.removeEventListener(SceneViewSprite.EVENT_SHOW_HELP,helpHandler);
            helper.next(self);
         });
      }
      
      public function mode_meadhouse(param1:Function) : void
      {
         helpEnabled = false;
         scene.setClickableEnabled("click_meadhouse",true,"TutorialTownState.mode_meadhouose");
         var _loc2_:String = "TownPage|scene_view|landscape_view|back_5 (trophy, weavers, meadhouse)|sprite_ui_meadhouse_1";
         var _loc3_:Number = 75;
         this.helper.tt = config.tutorialLayer.createTooltip(_loc2_,TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,_loc3_,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_town_meadhouse_mode"),true,false,0);
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
      }
      
      override public function handlePageReady() : void
      {
         super.handlePageReady();
         gameFsm.updateGameLocation("loc_tutorial");
         chatEnabled = false;
         bannerButtonEnabled = false;
         helpEnabled = false;
         scene.allClickablesDisabled = true;
         config.alerts.enabled = false;
         this._view = loader.viewSprite;
         this.helper.next(null);
      }
      
      override protected function handleCleanup() : void
      {
      }
      
      override public function handleLandscapeClick(param1:String) : Boolean
      {
         if(param1 == "click_meadhouse")
         {
            bannerButtonEnabled = true;
            scene.allClickablesDisabled = false;
            scene.setClickableEnabled("click_meadhouse",false,"TutorialTownState.handleLandscapeClick");
            this.helper.next(null);
            config.fsm.transitionTo(TutorialMeadHouseState,data);
            return true;
         }
         return super.handleLandscapeClick(param1);
      }
   }
}

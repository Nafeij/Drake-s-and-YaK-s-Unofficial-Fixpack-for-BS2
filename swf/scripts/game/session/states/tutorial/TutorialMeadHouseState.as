package game.session.states.tutorial
{
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.State;
   import engine.core.fsm.StateData;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import flash.events.Event;
   import game.session.states.MeadHouseState;
   import game.view.TutorialTooltip;
   
   public class TutorialMeadHouseState extends MeadHouseState
   {
      
      public static const TUTORIAL_RENOWN_POST_BATTLE:int = 75;
       
      
      private var helper:HelperTutorialState;
      
      public function TutorialMeadHouseState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
         this.helper = new HelperTutorialState(this,[this.mode_intro,this.mode_renown,this.mode_hire,this.mode_pg]);
      }
      
      public function mode_intro(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = config.tutorialLayer.createTooltip("MeadHousePage|container|assets.mead_house|killCounter",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,-100,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_meadhouse_intro_mode"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_renown(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = config.tutorialLayer.createTooltip("MeadHousePage|container|assets.mead_house|button_renown",TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.LEFT,30,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_meadhouse_renown_mode"),true,true,20);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_hire(param1:Function) : void
      {
         guiConfig.allow_hire = true;
         guiConfig.notify();
         this.helper.tt = config.tutorialLayer.createTooltip("MeadHousePage|container|assets.mead_house|renownCost",TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.LEFT,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_meadhouse_hire_mode"),true,false,0);
      }
      
      public function mode_pg(param1:Function) : void
      {
         this.helper.tt = config.tutorialLayer.createTooltip("MeadHousePage|container|assets.mead_house|popupDialog|pgButton",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_meadhouse_pg_mode"),true,false,0);
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
         config.accountInfo.legend.renown = TUTORIAL_RENOWN_POST_BATTLE;
         if(config.factions)
         {
            config.factions.legend.renown = TUTORIAL_RENOWN_POST_BATTLE;
         }
         var _loc1_:IEntityDef = config.legend.roster.getEntityDefById("thrasher_start_0");
         if(_loc1_)
         {
            config.legend.party.removeMember("thrasher_start_0");
            config.legend.roster.removeEntityDef(_loc1_);
         }
         guiConfig.show_unit_id = "axeman_exp";
         guiConfig.disabled = true;
         guiConfig.allow_hire = false;
         guiConfig.fake_hire = true;
         guiConfig.notify();
      }
      
      override protected function handleCleanup() : void
      {
         this.helper.tt = null;
         this.helper = null;
         guiConfig.disabled = false;
         guiConfig.allow_hire = true;
         guiConfig.fake_hire = false;
         guiConfig.notify();
      }
      
      override public function handlePageReady() : void
      {
         super.handlePageReady();
         this.helper.next(null);
      }
      
      override public function handleHired(param1:IEntityDef) : void
      {
         this.helper.next(null);
      }
      
      override public function handleGoToProvingGrounds() : void
      {
         this.helper.clearToolTip();
         var _loc1_:State = config.fsm.current;
         config.fsm.transitionTo(TutorialProvingGroundsState,_loc1_.data);
      }
   }
}

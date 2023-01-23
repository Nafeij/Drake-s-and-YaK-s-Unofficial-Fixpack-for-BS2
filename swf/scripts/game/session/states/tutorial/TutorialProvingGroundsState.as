package game.session.states.tutorial
{
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import flash.events.Event;
   import game.session.states.ProvingGroundsState;
   import game.view.TutorialTooltip;
   
   public class TutorialProvingGroundsState extends ProvingGroundsState
   {
       
      
      private var helper:HelperTutorialState;
      
      public function TutorialProvingGroundsState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
         this.helper = new HelperTutorialState(this,[this.mode_intro,this.mode_party,this.mode_promote,this.mode_promote_confirm,this.mode_variation,this.mode_variation_confirm,this.mode_name,this.mode_stats,this.mode_close_question,this.mode_complete,this.mode_town]);
      }
      
      public function mode_intro(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = config.tutorialLayer.createTooltip("ProvingGroundsPage|container|assets.proving_grounds|roster",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,-400,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_pg_intro_mode"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_party(param1:Function) : void
      {
         guiConfig.roster.allowCharacterDetails = true;
         this.helper.tt = config.tutorialLayer.createTooltip("ProvingGroundsPage|container|assets.proving_grounds|roster|iconRowParty|icon5",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_pg_party_mode"),true,false,0);
      }
      
      public function mode_promote(param1:Function) : void
      {
         guiConfig.allowPromotion = true;
         this.helper.tt = config.tutorialLayer.createTooltip("ProvingGroundsPage|container|assets.proving_grounds|details|promoteBanner",TutorialTooltipAlign.TOP,TutorialTooltipAnchor.TOP,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_pg_promote_mode"),true,false,0);
      }
      
      public function mode_promote_confirm(param1:Function) : void
      {
         guiConfig.allowPromotion = false;
         guiConfig.promotion.allowConfirm = true;
         this.helper.tt = config.tutorialLayer.createTooltip("ProvingGroundsPage|container|assets.proving_grounds|details|promotion|renown_total",TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.LEFT,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_pg_promote_confirm_mode"),true,false,0);
      }
      
      public function mode_variation(param1:Function) : void
      {
         this.helper.tt = config.tutorialLayer.createTooltip("ProvingGroundsPage|container|assets.proving_grounds|details|promotion|promoteVariation|_0",TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.LEFT,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_pg_variation_mode"),true,false,0);
      }
      
      public function mode_variation_confirm(param1:Function) : void
      {
         guiConfig.promotion.allowVariation = false;
         guiConfig.promotion.allowConfirm = true;
         this.helper.tt = config.tutorialLayer.createTooltip("ProvingGroundsPage|container|assets.proving_grounds|details|promotion|renown_total",TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.LEFT,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_pg_variation_confirm_mode"),true,false,0);
      }
      
      public function mode_name(param1:Function) : void
      {
         guiConfig.promotion.allowConfirm = false;
         guiConfig.promotion.allowAccept = true;
         this.helper.tt = config.tutorialLayer.createTooltip("ProvingGroundsPage|container|assets.proving_grounds|details|promotion|overlay_naming|accept",TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.LEFT,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_pg_name_mode"),true,false,0);
      }
      
      public function mode_stats(param1:Function) : void
      {
         guiConfig.allowQuestionMark = true;
         this.helper.tt = config.tutorialLayer.createTooltip("ProvingGroundsPage|container|assets.proving_grounds|question_button",TutorialTooltipAlign.LEFT,TutorialTooltipAnchor.LEFT,0,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_pg_stats_mode"),true,false,0);
      }
      
      public function mode_close_question(param1:Function) : void
      {
         this.helper.tt = null;
      }
      
      public function mode_complete(param1:Function) : void
      {
         var self:Function = param1;
         this.helper.tt = config.tutorialLayer.createTooltip("ProvingGroundsPage|container|assets.proving_grounds|roster",TutorialTooltipAlign.BOTTOM,TutorialTooltipAnchor.BOTTOM,-350,config.context.locale.translate(LocaleCategory.TUTORIAL,"tut_pg_complete_mode"),false,true,0);
         this.helper.tt.addEventListener(TutorialTooltip.EVENT_BUTTON,function callback(param1:Event):void
         {
            helper.tt.removeEventListener(TutorialTooltip.EVENT_BUTTON,callback);
            helper.next(self);
         });
      }
      
      public function mode_town(param1:Function) : void
      {
         this.helper.tt = null;
         fsm.transitionTo(TutorialTownFinishState,fsm.current.data);
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:String = null;
         var _loc2_:IEntityDef = null;
         super.handleEnteredState();
         if(config.legend.party.numMembers != 5)
         {
            _loc1_ = config.legend.party.getMemberId(5);
            _loc2_ = config.legend.party.getMember(5);
            logger.error("Wrong number of party members pre add = " + config.legend.party.numMembers + " 6=" + _loc2_);
            phase = StatePhase.FAILED;
            return;
         }
         config.legend.party.addMember("axeman_exp_0");
         if(config.legend.party.numMembers != 6)
         {
            logger.error("Wrong number of party members post add = " + config.legend.party.numMembers);
            phase = StatePhase.FAILED;
            return;
         }
         guiConfig.disabled = true;
         guiConfig.roster.allowCharacterDetails = false;
         guiConfig.roster.disabled = true;
         guiConfig.roster.partyClickSlot = 5;
         guiConfig.promotion.disabled = true;
         guiConfig.allowQuestionMark = false;
         guiConfig.characterStats.disabled = true;
      }
      
      override public function handlePageReady() : void
      {
         super.handlePageReady();
         this.helper.next(null);
      }
      
      override public function handleDisplayCharacterDetails(param1:IEntityDef) : void
      {
         this.helper.next(null);
      }
      
      override public function handleDisplayPromotion(param1:IEntityDef) : void
      {
         promotionAutoName(true);
         promotionShowClass("thrasher","Thrasher");
         this.helper.next(null);
      }
      
      override public function handlePromotion(param1:IEntityDef) : void
      {
         this.helper.next(null);
      }
      
      override public function handleProvingGroundsCloseQuestionPages() : void
      {
         this.helper.next(null);
      }
      
      override public function handleProvingGroundsQuestionClick() : void
      {
         this.helper.next(null);
      }
      
      override public function handleProvingGroundsNamingAccept() : void
      {
      }
      
      override public function handleProvingGroundsNamingMode() : void
      {
         this.helper.next(null);
      }
      
      override public function handleProvingGroundsVariationOpened() : void
      {
         this.helper.next(null);
      }
      
      override public function handleProvingGroundsVariationSelected() : void
      {
         this.helper.next(null);
      }
   }
}

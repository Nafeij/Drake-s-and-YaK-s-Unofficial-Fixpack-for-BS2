package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Legend;
   import flash.events.Event;
   import game.gui.page.GuiProvingGroundsConfig;
   import game.session.GameState;
   import game.session.actions.ArrangePartyTxn;
   
   public class ProvingGroundsState extends GameState
   {
      
      public static const EVENT_AUTO_NAME:String = "ProvingGroundsState.EVENT_AUTO_NAME";
      
      public static const EVENT_SHOW_CLASS:String = "ProvingGroundsState.EVENT_SHOW_CLASS";
       
      
      public var txn:ArrangePartyTxn;
      
      public var auto_name:Boolean;
      
      public var show_class_id:String;
      
      public var use_unit_name:String;
      
      public var guiConfig:GuiProvingGroundsConfig;
      
      private var legend:Legend;
      
      public function ProvingGroundsState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         this.guiConfig = new GuiProvingGroundsConfig();
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         gameFsm.updateGameLocation("loc_proving_grounds");
         this.legend = config.legend;
         if(this.legend)
         {
            this.legend.party.addEventListener(Event.CHANGE,this.partyChangeHandler);
         }
         this.guiConfig.promotion.enableName = true;
      }
      
      override protected function handleCleanup() : void
      {
         if(this.legend)
         {
            this.legend.party.removeEventListener(Event.CHANGE,this.partyChangeHandler);
         }
         this.legend = null;
         this.guiConfig.reset();
      }
      
      protected function partyChangeHandler(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.txn)
         {
            this.txn.abort();
         }
         if(!config.accountInfo.tutorial)
         {
            _loc2_ = 2000;
            _loc3_ = 0;
            if(config.factions)
            {
               config.factions.lobbyManager.current.options.lobby_id;
               if(config.legend.party.numMembers == 0)
               {
                  config.factions.lobbyManager.current.ready = false;
               }
               this.txn = new ArrangePartyTxn(config.fsm.credentials,null,logger,config.legend.party.copyMemberIds,_loc3_);
               this.txn.send(config.fsm.communicator,null,_loc2_);
            }
         }
      }
      
      public function handleDisplayCharacterDetails(param1:IEntityDef) : void
      {
      }
      
      public function handleDisplayPromotion(param1:IEntityDef) : void
      {
      }
      
      public function handlePromotion(param1:IEntityDef) : void
      {
      }
      
      protected function promotionAutoName(param1:Boolean) : void
      {
         this.auto_name = param1;
         dispatchEvent(new Event(EVENT_AUTO_NAME));
      }
      
      protected function promotionShowClass(param1:String, param2:String) : void
      {
         this.use_unit_name = param2;
         this.show_class_id = param1;
         dispatchEvent(new Event(EVENT_SHOW_CLASS));
      }
      
      public function handleProvingGroundsCloseQuestionPages() : void
      {
      }
      
      public function handleProvingGroundsQuestionClick() : void
      {
      }
      
      public function handleProvingGroundsNamingAccept() : void
      {
      }
      
      public function handleProvingGroundsNamingMode() : void
      {
      }
      
      public function handleProvingGroundsVariationOpened() : void
      {
      }
      
      public function handleProvingGroundsVariationSelected() : void
      {
      }
   }
}

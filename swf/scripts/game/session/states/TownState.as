package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import engine.scene.model.SceneEvent;
   import game.gui.IGuiDialog;
   
   public class TownState extends SceneState
   {
       
      
      public function TownState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
         data.setValue(GameStateDataEnum.LOCAL_PARTY,null);
      }
      
      override protected function sceneExitHandler(param1:SceneEvent) : void
      {
      }
      
      override protected function handleEnteredState() : void
      {
         gameFsm.updateGameLocation("loc_strand");
         super.handleEnteredState();
      }
      
      private function onDialogClose(param1:String) : void
      {
         var _loc2_:String = config.gameGuiContext.translate("yes");
         if(param1 == _loc2_)
         {
            config.context.appInfo.exitGame("Firetower");
         }
      }
      
      override public function handleLandscapeClick(param1:String) : Boolean
      {
         var _loc2_:IGuiDialog = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         if(super.handleLandscapeClick(param1))
         {
            return true;
         }
         switch(param1)
         {
            case "click_hall_of_valor":
               config.fsm.transitionTo(HallOfValorState,data);
               return true;
            case "click_greathall":
               config.fsm.transitionTo(GreatHallState,data);
               return true;
            case "click_trophytower":
               return true;
            case "click_weavershut":
               return true;
            case "click_meadhouse":
               config.fsm.transitionTo(MeadHouseState,data);
               return true;
            case "click_provinggrounds":
               config.fsm.transitionTo(ProvingGroundsState,data);
               return true;
            case "click_marketplace":
               config.pageManager.marketplace.showMarketplace(true,null,null,null);
               return true;
            case "click_firetower":
               if(config.runMode.mainMenu)
               {
                  config.fsm.transitionTo(MainMenuState,data);
               }
               else
               {
                  _loc2_ = config.gameGuiContext.createDialog();
                  _loc3_ = config.gameGuiContext.translate("quit_game_title");
                  _loc4_ = config.gameGuiContext.translate("quit_game_body");
                  _loc5_ = config.gameGuiContext.translate("yes");
                  _loc6_ = config.gameGuiContext.translate("no");
                  _loc2_.openTwoBtnDialog(_loc3_,_loc4_,_loc5_,_loc6_,this.onDialogClose);
               }
               return true;
            default:
               return false;
         }
      }
   }
}

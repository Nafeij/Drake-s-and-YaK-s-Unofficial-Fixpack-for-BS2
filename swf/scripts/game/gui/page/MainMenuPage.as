package game.gui.page
{
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.session.states.FactionsState;
   import game.session.states.PreAuthState;
   
   public class MainMenuPage extends GamePage implements IGuiMainMenuListener
   {
       
      
      public function MainMenuPage(param1:GameConfig)
      {
         super(param1);
      }
      
      override protected function handleStart() : void
      {
      }
      
      override protected function handleLoaded() : void
      {
         var _loc1_:IGuiMainMenu = null;
         if(fullScreenMc)
         {
            _loc1_ = fullScreenMc as IGuiMainMenu;
            _loc1_.init(config.gameGuiContext,this);
         }
      }
      
      protected function buttonClickHandler() : void
      {
         if(config.soundSystem.controller)
         {
            config.soundSystem.controller.playSound("menu_item_selected",null);
         }
      }
      
      public function optionClickHandler() : void
      {
         this.buttonClickHandler();
         config.fsm.transitionTo(PreAuthState,null);
      }
      
      public function sagaClickHandler() : void
      {
         this.buttonClickHandler();
      }
      
      public function combatClickHandler() : void
      {
         this.buttonClickHandler();
         config.fsm.transitionTo(FactionsState,null);
      }
   }
}

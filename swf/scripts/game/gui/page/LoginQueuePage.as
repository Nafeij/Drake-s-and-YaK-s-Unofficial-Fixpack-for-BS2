package game.gui.page
{
   import engine.core.fsm.FsmEvent;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.session.states.GameStateDataEnum;
   
   public class LoginQueuePage extends GamePage implements IGuiLoginQueueListener
   {
       
      
      private var guiLogin:IGuiLoginQueue;
      
      public function LoginQueuePage(param1:GameConfig)
      {
         super(param1);
         mouseChildren = true;
         param1.fsm.addEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
      }
      
      override public function cleanup() : void
      {
         config.fsm.removeEventListener(FsmEvent.CURRENT,this.fsmCurrentHandler);
         this.guiLogin = null;
      }
      
      private function fsmCurrentHandler(param1:FsmEvent) : void
      {
      }
      
      override protected function handleStart() : void
      {
      }
      
      override protected function canBeReady() : Boolean
      {
         return !config.runMode.autologin && !config.fsm.current.data.getValue(GameStateDataEnum.AUTOLOGIN);
      }
      
      override protected function handleLoaded() : void
      {
         if(Boolean(fullScreenMc) && !this.guiLogin)
         {
            this.guiLogin = fullScreenMc as IGuiLoginQueue;
            this.guiLogin.init(config.gameGuiContext,this);
         }
      }
      
      public function onExit() : void
      {
      }
   }
}

package game.gui.page
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.logging.Log;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   
   public class SagaPairingPrompt extends GamePage implements IGuiSagaPairingPromptListener
   {
      
      public static var mcClazz:Class;
       
      
      private var gui:IGuiPairingPrompt;
      
      private var cmd_ok:Cmd;
      
      private var scenePage:ScenePage;
      
      private var initialized:Boolean;
      
      public function SagaPairingPrompt(param1:GameConfig, param2:ScenePage)
      {
         this.cmd_ok = new Cmd("cmd_ok",this.func_cmd_ok);
         super(param1);
         allowPageScaling = false;
         this.scenePage = param2;
         setFullPageMovieClipClass(mcClazz);
         blockTranslate = true;
         this.initialized = false;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         if(param1 && !this.initialized)
         {
            Log.getLogger("TBS-0").info("Saga pairing prompt loaded");
            this.initialized = true;
            if(Boolean(fullScreenMc) && !this.gui)
            {
               fullScreenMc.visible = true;
               this.gui = fullScreenMc as IGuiPairingPrompt;
               this.gui.init(config.gameGuiContext,this);
            }
            config.context.appInfo.establishInitialUser();
         }
      }
      
      private function func_cmd_ok(param1:CmdExec) : void
      {
         Log.getLogger("TBS-0").info("Press A! Press A!");
      }
   }
}

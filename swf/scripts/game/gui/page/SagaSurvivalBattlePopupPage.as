package game.gui.page
{
   import engine.core.render.BoundedCamera;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiSagaSurvivalBattlePopup;
   
   public class SagaSurvivalBattlePopupPage extends GamePage
   {
      
      public static var mc_clazz:Class;
       
      
      private var gui:IGuiSagaSurvivalBattlePopup;
      
      private var msg:String;
      
      private var callback:Function;
      
      public function SagaSurvivalBattlePopupPage(param1:GameConfig, param2:String, param3:Function)
      {
         super(param1);
         this.msg = param2;
         this.callback = param3;
         param1.addEventListener(GameConfig.EVENT_FF,this.configFfHandler);
      }
      
      override protected function handleStart() : void
      {
         setFullPageMovieClipClass(mc_clazz);
      }
      
      override protected function handleLoaded() : void
      {
         if(Boolean(fullScreenMc) && !this.gui)
         {
            removeChildFromContainer(fullScreenMc);
            addChild(fullScreenMc);
            fullScreenMc.x = 0;
            fullScreenMc.y = 0;
            this.gui = fullScreenMc as IGuiSagaSurvivalBattlePopup;
            this.gui.init(config.gameGuiContext,this.msg);
            this.gui.addEventListener(Event.COMPLETE,this.guiCompleteHandler);
            this.resizeHandler();
         }
      }
      
      private function guiCompleteHandler(param1:Event) : void
      {
         config.pageManager.hideSagaSurvivalBattlePopup();
         var _loc2_:Function = this.callback;
         this.callback = null;
         if(_loc2_ != null)
         {
            _loc2_();
         }
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         if(this.gui)
         {
            fullScreenMc.scaleX = fullScreenMc.scaleY = BoundedCamera.computeDpiScaling(width,height);
            fullScreenMc.x = width / 2;
            fullScreenMc.y = height / 2;
         }
      }
      
      override public function cleanup() : void
      {
         config.removeEventListener(GameConfig.EVENT_FF,this.configFfHandler);
         if(this.gui)
         {
            this.gui.cleanup();
            this.gui = null;
         }
         if(parent)
         {
            parent.removeChild(this);
         }
         super.cleanup();
      }
      
      private function configFfHandler(param1:Event) : Boolean
      {
         this.guiCompleteHandler(null);
         return false;
      }
   }
}

package game.gui.page
{
   import engine.saga.Saga;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   
   public class SagaSurvivalWinPage extends GamePage implements IGuiSagaSurvivalWinListener
   {
      
      public static var mcClazz_survivalWin:Class;
       
      
      private var _gui:IGuiSagaSurvivalWin;
      
      public function SagaSurvivalWinPage(param1:GameConfig, param2:int = 2731, param3:int = 1536)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleStart() : void
      {
         var _loc1_:Saga = Saga.instance;
         if(_loc1_)
         {
            _loc1_.trackPageView("survival_win");
         }
         setFullPageMovieClipClass(mcClazz_survivalWin);
      }
      
      override public function cleanup() : void
      {
         if(this._gui)
         {
            this._gui.removeEventListener(Event.COMPLETE,this.winCompleteHandler);
            this._gui.cleanup();
         }
         this._gui = null;
         super.cleanup();
      }
      
      override protected function handleLoaded() : void
      {
         if(Boolean(fullScreenMc) && !this._gui)
         {
            this._gui = fullScreenMc as IGuiSagaSurvivalWin;
            this._gui.init(config.gameGuiContext,this,config.saga,config.context.appInfo);
            this._gui.resizeHandler(width,height);
            this._gui.addEventListener(Event.COMPLETE,this.winCompleteHandler);
            fullScreenMc.visible = true;
            resizeHandler();
         }
      }
      
      private function winCompleteHandler(param1:Event) : void
      {
         if(!this._gui)
         {
            return;
         }
         var _loc2_:Saga = Saga.instance;
         config.loadSaga(_loc2_.def.url,null,null,_loc2_.difficulty,-1);
      }
   }
}

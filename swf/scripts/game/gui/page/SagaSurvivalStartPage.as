package game.gui.page
{
   import engine.saga.Saga;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   
   public class SagaSurvivalStartPage extends GamePage implements IGuiSagaSurvivalStartListener
   {
      
      public static var mcClazz_survivalStart:Class;
       
      
      private var _gui:IGuiSagaSurvivalStart;
      
      public function SagaSurvivalStartPage(param1:GameConfig, param2:int = 2731, param3:int = 1536)
      {
         super(param1,param2,param3);
         logger.info("SagaSurvivalStartPage ctor");
      }
      
      override protected function handleStart() : void
      {
         var _loc1_:Saga = Saga.instance;
         if(_loc1_)
         {
            _loc1_.trackPageView("survival_start");
         }
         setFullPageMovieClipClass(mcClazz_survivalStart);
      }
      
      override public function cleanup() : void
      {
         if(this._gui)
         {
            this._gui.removeEventListener(Event.COMPLETE,this.newGameCompleteHandler);
            this._gui.cleanup();
         }
         this._gui = null;
         super.cleanup();
      }
      
      override protected function handleLoaded() : void
      {
         if(Boolean(fullScreenMc) && !this._gui)
         {
            fullScreenMc.visible = true;
            this._gui = fullScreenMc as IGuiSagaSurvivalStart;
            this._gui.init(config.gameGuiContext,this,config.saga,config.context.appInfo);
            this._gui.resizeHandler(width,height);
            this._gui.addEventListener(Event.COMPLETE,this.newGameCompleteHandler);
            resizeHandler();
         }
      }
      
      private function newGameCompleteHandler(param1:Event) : void
      {
         if(!this._gui)
         {
            return;
         }
      }
   }
}

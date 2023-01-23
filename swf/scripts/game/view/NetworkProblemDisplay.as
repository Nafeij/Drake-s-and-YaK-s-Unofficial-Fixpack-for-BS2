package game.view
{
   import engine.core.http.HttpCommunicator;
   import engine.core.http.HttpErrorState;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.gui.core.GuiSprite;
   import engine.gui.core.GuiSpriteEvent;
   import engine.resource.ResourceManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import game.cfg.GameConfig;
   
   public class NetworkProblemDisplay
   {
      
      public static var mcClazz:Class;
       
      
      private var container:GuiSprite;
      
      private var communicator:HttpCommunicator;
      
      private var mc:MovieClip;
      
      private var locale:Locale;
      
      private var config:GameConfig;
      
      public function NetworkProblemDisplay(param1:GuiSprite, param2:GameConfig, param3:HttpCommunicator, param4:ResourceManager, param5:Locale)
      {
         super();
         this.container = param1;
         this.communicator = param3;
         this.locale = param5;
         this.config = param2;
         this.createGui();
         param3.errorState.addEventListener(HttpErrorState.EVENT_ERROR_STATE,this.errorStateHandler);
         param1.addEventListener(GuiSpriteEvent.RESIZE,this.resizeHandler);
         param2.addEventListener(GameConfig.EVENT_FACTIONS,this.factionsHandler);
      }
      
      private function factionsHandler(param1:Event) : void
      {
         this.checkStatus();
      }
      
      private function resizeHandler(param1:GuiSpriteEvent) : void
      {
         if(Boolean(this.mc) && Boolean(this.mc.parent))
         {
            this.mc.x = this.container.width / 2;
         }
      }
      
      private function errorStateHandler(param1:Event) : void
      {
         this.checkStatus();
      }
      
      private function createGui() : void
      {
         if(mcClazz)
         {
            this.mc = new mcClazz() as MovieClip;
            this.mc.mouseEnabled = this.mc.mouseChildren = false;
            this.mc.y = 200;
            this.locale.translateDisplayObjects(LocaleCategory.GUI,this.mc,this.config.logger);
         }
         this.checkStatus();
      }
      
      private function checkStatus() : void
      {
         if(!this.mc)
         {
            return;
         }
         if(this.communicator.errorState.error && Boolean(this.config.factions))
         {
            if(!this.mc.parent)
            {
               this.container.addChild(this.mc);
               this.resizeHandler(null);
            }
            else
            {
               this.container.bringChildToFront(this.mc);
            }
         }
         else if(this.mc.parent)
         {
            this.mc.parent.removeChild(this.mc);
         }
      }
   }
}

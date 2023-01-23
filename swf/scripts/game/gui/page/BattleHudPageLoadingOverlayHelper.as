package game.gui.page
{
   import game.cfg.GameConfig;
   import game.gui.battle.IGuiLoadingOverlay;
   
   public class BattleHudPageLoadingOverlayHelper
   {
      
      public static var mcClazzLoadingOverlay:Class;
       
      
      private var _loadingOverlay:IGuiLoadingOverlay;
      
      private var _bhPage:BattleHudPage;
      
      private var _config:GameConfig;
      
      public function BattleHudPageLoadingOverlayHelper(param1:BattleHudPage, param2:GameConfig)
      {
         super();
         this._bhPage = param1;
         this._config = param2;
      }
      
      private function instantiateLoadingOverlay() : void
      {
         if(mcClazzLoadingOverlay && !this._loadingOverlay && Boolean(this._bhPage))
         {
            this._loadingOverlay = new mcClazzLoadingOverlay() as IGuiLoadingOverlay;
            this._bhPage.addChild(this._loadingOverlay.displayObject);
            this._loadingOverlay.init(this._config.gameGuiContext,this._bhPage);
         }
      }
      
      public function showLoadingOverlay() : void
      {
         if(!this._loadingOverlay)
         {
            this.instantiateLoadingOverlay();
         }
         else
         {
            this._loadingOverlay.visible = true;
         }
      }
      
      public function update(param1:int) : void
      {
         if(this._loadingOverlay)
         {
            this._loadingOverlay.update(param1);
         }
      }
      
      public function hideLoadingOverlay() : void
      {
         if(!this._loadingOverlay)
         {
            return;
         }
         this._loadingOverlay.visible = false;
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
         if(this._loadingOverlay)
         {
            this._loadingOverlay.resizeHandler(param1,param2);
         }
      }
      
      public function cleanup() : void
      {
         if(this._loadingOverlay)
         {
            if(Boolean(this._bhPage) && this._loadingOverlay.displayObject.parent == this._bhPage)
            {
               this._bhPage.removeChild(this._loadingOverlay.displayObject);
            }
            this._loadingOverlay.cleanup();
            this._loadingOverlay = null;
         }
      }
   }
}

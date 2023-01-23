package game.view
{
   import engine.core.fsm.State;
   import engine.core.locale.LocaleCategory;
   import flash.display.MovieClip;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.IGuiDialog;
   import game.gui.page.IGuiMarketplace;
   import game.gui.page.ProvingGroundsPage;
   
   public class GamePageManagerAdapterMarketplace
   {
      
      public static var marketCheck:Function;
      
      public static var mcClazz:Class;
       
      
      public var config:GameConfig;
      
      public var marketplace:IGuiMarketplace;
      
      private var marketplaceCloseCallback:Function;
      
      private var adapter:GamePageManagerAdapter;
      
      private var marketplaceOverlayNotificationShown:Boolean;
      
      private var lastMarketplacePage:GamePage;
      
      public function GamePageManagerAdapterMarketplace(param1:GamePageManagerAdapter)
      {
         super();
         this.config = param1.config;
         this.adapter = param1;
         this.config.addEventListener(GameConfig.EVENT_FACTIONS,this.factionsSagaHandler);
         this.config.addEventListener(GameConfig.EVENT_SAGA,this.factionsSagaHandler);
         this.factionsSagaHandler(null);
      }
      
      private function factionsSagaHandler(param1:Event) : void
      {
         if(this.marketplace)
         {
            this.marketplace.cleanup();
            this.marketplace = null;
         }
         if(this.config.factions)
         {
            this.checkMarketplace();
         }
      }
      
      public function escapeFromMarket() : Boolean
      {
         if(Boolean(this.marketplace) && this.marketplace.movieClip.visible)
         {
            this.showMarketplace(false,null,null,null);
            return true;
         }
         return false;
      }
      
      private function checkMarketplace() : void
      {
         var _loc1_:MovieClip = null;
         if(Boolean(mcClazz) && !this.marketplace)
         {
            if(this.config.factions && this.config.factions.ready && Boolean(this.config.factions.iapManager))
            {
               _loc1_ = new mcClazz() as MovieClip;
               this.marketplace = _loc1_ as IGuiMarketplace;
               this.marketplace.init(this.config.gameGuiContext);
               this.marketplace.addEventListener(Event.CLOSE,this.marketplaceCloseHandler);
               this.config.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.marketplace.movieClip,this.config.logger);
               _loc1_.visible = false;
            }
         }
      }
      
      private function marketplaceCloseHandler(param1:Event) : void
      {
         if(this.marketplaceCloseCallback != null)
         {
            this.marketplaceCloseCallback();
         }
         this.showMarketplace(false,null,null,null);
      }
      
      private function checkMarketplaceOverlayNotification() : void
      {
         if(this.marketplaceOverlayNotificationShown)
         {
            return;
         }
         if(marketCheck != null && !marketCheck())
         {
            return;
         }
         this.marketplaceOverlayNotificationShown = true;
         var _loc1_:IGuiDialog = this.config.gameGuiContext.createDialog();
         var _loc2_:String = this.config.gameGuiContext.translate("ok");
         var _loc3_:String = this.config.gameGuiContext.translate("steam_overlay_missing_title");
         var _loc4_:String = this.config.gameGuiContext.translate("steam_overlay_missing_body");
         _loc1_.openDialog(_loc3_,_loc4_,_loc2_,null);
      }
      
      public function showMarketplace(param1:Boolean, param2:String, param3:String, param4:Function) : void
      {
         var _loc6_:GamePage = null;
         if(!this.marketplace)
         {
            return;
         }
         this.marketplaceCloseCallback = param4;
         var _loc5_:MovieClip = this.marketplace.movieClip;
         if(this.lastMarketplacePage)
         {
            if(this.lastMarketplacePage.overlay == _loc5_)
            {
               this.lastMarketplacePage.overlay = null;
            }
         }
         if(param1)
         {
            this.checkMarketplaceOverlayNotification();
            _loc5_.visible = true;
            _loc6_ = this.adapter.currentPage as GamePage;
            this.lastMarketplacePage = _loc6_;
            if(_loc6_)
            {
               _loc6_.overlay = _loc5_;
            }
            if(param2)
            {
               this.marketplace.showPage(param2,param3);
            }
            this.marketplace.addEventListener(this.marketplace.EVENT_PROVING_GROUND,this.marketplaceProvingGroundsHandler);
         }
         else
         {
            this.lastMarketplacePage = null;
            _loc5_.visible = false;
         }
      }
      
      private function marketplaceProvingGroundsHandler(param1:Event) : void
      {
         var _loc2_:State = null;
         if(Boolean(this.marketplace) && this.marketplace.movieClip.visible)
         {
            _loc2_ = this.config.fsm.current;
            this.config.fsm.transitionTo(ProvingGroundsPage,_loc2_.data);
         }
      }
   }
}

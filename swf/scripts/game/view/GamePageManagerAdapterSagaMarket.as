package game.view
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.locale.LocaleCategory;
   import engine.saga.Saga;
   import engine.saga.SagaEvent;
   import engine.saga.SagaPresenceManager;
   import engine.saga.SagaPresenceState;
   import flash.display.MovieClip;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.GuiBitmapHolderHelper;
   import game.gui.page.IGuiSagaMarket;
   
   public class GamePageManagerAdapterSagaMarket
   {
      
      public static var mcClazz:Class;
       
      
      public var config:GameConfig;
      
      public var sagaMarket:IGuiSagaMarket;
      
      private var sagaMarketCloseCallback:Function;
      
      private var adapter:GamePageManagerAdapter;
      
      private var sagaMarketOverlayNotificationShown:Boolean;
      
      private var _saga:Saga;
      
      private var bmpholderHelper:GuiBitmapHolderHelper;
      
      private var sagaPresenceState:SagaPresenceState;
      
      private var lastSagaMarketPage:GamePage;
      
      public function GamePageManagerAdapterSagaMarket(param1:GamePageManagerAdapter)
      {
         super();
         this.config = param1.config;
         this.adapter = param1;
         this.config.addEventListener(GameConfig.EVENT_FACTIONS,this.factionsSagaHandler);
         this.config.addEventListener(GameConfig.EVENT_SAGA,this.factionsSagaHandler);
         this.factionsSagaHandler(null);
      }
      
      public function cleanup() : void
      {
         if(this.bmpholderHelper)
         {
            this.bmpholderHelper.cleanup();
            this.bmpholderHelper = null;
         }
      }
      
      private function factionsSagaHandler(param1:Event) : void
      {
         if(this.sagaMarket)
         {
            this.sagaMarket.cleanup();
            this.sagaMarket = null;
         }
         this.saga = this.config.saga;
      }
      
      public function escapeFromMarket() : Boolean
      {
         if(Boolean(this.sagaMarket) && this.sagaMarket.movieClip.visible)
         {
            this.showSagaMarket(false,null);
            return true;
         }
         return false;
      }
      
      private function checkSagaMarket() : void
      {
         var mc:MovieClip = null;
         if(!this._saga)
         {
            return;
         }
         if(Boolean(mcClazz) && !this.sagaMarket)
         {
            try
            {
               this.bmpholderHelper = new GuiBitmapHolderHelper(this.config.resman,this.bmpHolderCallbackComplete);
               mc = new mcClazz() as MovieClip;
               this.bmpholderHelper.loadGuiBitmaps(mc);
               this.sagaMarket = mc as IGuiSagaMarket;
               this.sagaMarket.init(this.config.gameGuiContext);
               this.sagaMarket.addEventListener(Event.CLOSE,this.sagaMarketCloseHandler);
               this.config.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.sagaMarket.movieClip,this.config.logger);
               mc.visible = false;
               if(!this.bmpholderHelper.isComplete)
               {
                  this.adapter.loading = true;
               }
            }
            catch(err:Error)
            {
               config.logger.error("Failed to create market:\n" + err.getStackTrace());
            }
         }
         if(this.sagaMarket)
         {
            this.sagaMarket.saga = this._saga;
         }
      }
      
      private function destroySagaMarket() : void
      {
         if(this.bmpholderHelper)
         {
            this.bmpholderHelper.cleanup();
            this.bmpholderHelper = null;
            this.adapter.loading = false;
         }
         if(this.sagaMarket)
         {
            this.sagaMarket.removeEventListener(Event.CLOSE,this.sagaMarketCloseHandler);
            this.sagaMarket.cleanup();
            this.sagaMarket = null;
         }
      }
      
      private function sagaMarketCloseHandler(param1:Event) : void
      {
         if(this.sagaMarketCloseCallback != null)
         {
            this.sagaMarketCloseCallback();
         }
         this.showSagaMarket(false,null);
      }
      
      public function showSagaMarket(param1:Boolean, param2:Function) : void
      {
         var _loc4_:GamePage = null;
         if(param1)
         {
            this.sagaPresenceState = SagaPresenceManager.pushNewState(SagaPresenceManager.StateAtMarket);
            this.checkSagaMarket();
         }
         else if(this.sagaPresenceState)
         {
            this.sagaPresenceState.remove();
            this.sagaPresenceState = null;
         }
         if(!this.sagaMarket)
         {
            return;
         }
         this.sagaMarketCloseCallback = param2;
         var _loc3_:MovieClip = this.sagaMarket.movieClip;
         if(this.lastSagaMarketPage)
         {
            if(this.lastSagaMarketPage.overlay == _loc3_)
            {
               this.lastSagaMarketPage.overlay = null;
            }
         }
         if(param1)
         {
            _loc3_.visible = true;
            _loc4_ = this.adapter.currentPage as GamePage;
            this.lastSagaMarketPage = _loc4_;
            if(_loc4_)
            {
               _loc4_.overlay = _loc3_;
            }
            this.sagaMarket.showMarket();
            this.saga.pause("market");
         }
         else
         {
            this.lastSagaMarketPage = null;
            _loc3_.visible = false;
            this.destroySagaMarket();
            this.saga.unpause("market");
         }
         this.saga.market.showing = param1;
      }
      
      private function bmpHolderCallbackComplete(param1:GuiBitmapHolderHelper) : void
      {
         if(param1 == this.bmpholderHelper)
         {
            if(Boolean(this.saga) && Boolean(this.saga.market))
            {
               if(this.saga.market.showing)
               {
                  this.adapter.loading = false;
               }
            }
         }
      }
      
      public function get saga() : Saga
      {
         return this._saga;
      }
      
      public function set saga(param1:Saga) : void
      {
         if(this._saga == param1)
         {
            return;
         }
         if(this._saga)
         {
            this._saga.removeEventListener(SagaEvent.EVENT_SHOW_MARKET,this.sagaShowMarketHandler);
         }
         this._saga = param1;
         if(this._saga)
         {
            this._saga.addEventListener(SagaEvent.EVENT_SHOW_MARKET,this.sagaShowMarketHandler);
         }
      }
      
      private function sagaShowMarketHandler(param1:Event) : void
      {
         PlatformInput.dispatcher.dispatchEvent(new Event(PlatformInput.EVENT_CURSOR_LOST_FOCUS));
         this.showSagaMarket(true,null);
      }
      
      public function update(param1:int) : void
      {
         if(Boolean(this.sagaMarket) && this.sagaMarket.movieClip.visible)
         {
            this.sagaMarket.update(param1);
         }
      }
   }
}

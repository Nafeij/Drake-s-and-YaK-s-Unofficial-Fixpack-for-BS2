package game.view
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.locale.LocaleCategory;
   import engine.landscape.view.WeatherManager;
   import engine.saga.Saga;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.ui.Keyboard;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.gui.GuiBitmapHolderHelper;
   import game.gui.page.IGuiSagaHeraldry;
   
   public class GamePageManagerAdapterSagaHeraldry extends EventDispatcher
   {
      
      public static const EVENT_SHOWING:String = "GamePageManagerAdapterSagaHeraldry.EVENT_SHOWING";
      
      public static var mcClazz:Class;
       
      
      public var config:GameConfig;
      
      public var gui:IGuiSagaHeraldry;
      
      private var adapter:GamePageManagerAdapter;
      
      private var sagaMarketOverlayNotificationShown:Boolean;
      
      private var _saga:Saga;
      
      private var bmpholderHelper:GuiBitmapHolderHelper;
      
      private var cmd_back:Cmd;
      
      private var lastSagaHeraldryPage:GamePage;
      
      public function GamePageManagerAdapterSagaHeraldry(param1:GamePageManagerAdapter)
      {
         this.cmd_back = new Cmd("cmd_back",this.cmdfunc_back);
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
         if(this.gui)
         {
            this.gui.cleanup();
            this.gui = null;
         }
         this.saga = this.config.saga;
      }
      
      public function escapeFromHeraldry() : Boolean
      {
         if(Boolean(this.gui) && this.gui.movieClip.visible)
         {
            this.showSagaHeraldry(false);
            return true;
         }
         return false;
      }
      
      private function checkSagaHeraldry() : void
      {
         var _loc1_:MovieClip = null;
         if(!this._saga)
         {
            return;
         }
         if(Boolean(mcClazz) && !this.gui)
         {
            this.bmpholderHelper = new GuiBitmapHolderHelper(this.config.resman,null);
            _loc1_ = new mcClazz() as MovieClip;
            this.bmpholderHelper.loadGuiBitmaps(_loc1_);
            this.gui = _loc1_ as IGuiSagaHeraldry;
            this.gui.init(this.config.gameGuiContext,this.config.resman);
            this.gui.addEventListener(Event.CLOSE,this.sagaHeraldryCloseHandler);
            this.gui.addEventListener(Event.CHANGE,this.sagaHeraldryChangeHandler);
            this.config.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.gui.movieClip,this.config.logger);
            _loc1_.visible = false;
         }
      }
      
      private function destroySagaHeraldry() : void
      {
         if(this.bmpholderHelper)
         {
            this.bmpholderHelper.cleanup();
            this.bmpholderHelper = null;
         }
         if(this.gui)
         {
            this.gui.removeEventListener(Event.CLOSE,this.sagaHeraldryCloseHandler);
            this.gui.removeEventListener(Event.CHANGE,this.sagaHeraldryChangeHandler);
            this.gui.cleanup();
            this.gui = null;
         }
      }
      
      private function sagaHeraldryChangeHandler(param1:Event) : void
      {
      }
      
      private function sagaHeraldryCloseHandler(param1:Event) : void
      {
         this.showSagaHeraldry(false);
      }
      
      public function showSagaHeraldry(param1:Boolean) : void
      {
         var _loc3_:GamePage = null;
         if(param1)
         {
            this.checkSagaHeraldry();
         }
         if(!this.gui)
         {
            return;
         }
         var _loc2_:MovieClip = this.gui.movieClip;
         if(this.lastSagaHeraldryPage)
         {
            if(this.lastSagaHeraldryPage.overlay == _loc2_)
            {
               this.lastSagaHeraldryPage.overlay = null;
            }
         }
         if(param1)
         {
            this.config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_back,"");
            _loc2_.visible = true;
            _loc3_ = this.adapter.currentPage as GamePage;
            this.lastSagaHeraldryPage = _loc3_;
            if(_loc3_)
            {
               _loc3_.overlay = _loc2_;
            }
            this.gui.showGuiHeraldry(this.config.heraldrySystem);
            WeatherManager.PAUSED = true;
            this.config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,_loc2_);
         }
         else
         {
            this.lastSagaHeraldryPage = null;
            _loc2_.visible = false;
            this.gui.hideGuiHeraldry();
            this.config.keybinder.unbind(this.cmd_back);
            this.destroySagaHeraldry();
            WeatherManager.PAUSED = false;
         }
         dispatchEvent(new Event(EVENT_SHOWING));
      }
      
      public function get visible() : Boolean
      {
         var _loc1_:MovieClip = !!this.gui ? this.gui.movieClip : null;
         return Boolean(_loc1_) && _loc1_.visible;
      }
      
      public function cmdfunc_back(param1:CmdExec) : void
      {
         this.showSagaHeraldry(false);
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
         this._saga = param1;
      }
      
      public function notifyShowingOptionsChange(param1:Boolean) : void
      {
         if(this.gui)
         {
            this.gui.notifyOverlayChange(param1);
         }
      }
   }
}

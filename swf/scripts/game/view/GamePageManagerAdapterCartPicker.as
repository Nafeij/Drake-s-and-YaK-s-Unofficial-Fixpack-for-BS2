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
   import game.gui.page.IGuiCartPicker;
   
   public class GamePageManagerAdapterCartPicker extends EventDispatcher
   {
      
      public static const EVENT_SHOWING:String = "GamePageManagerAdapterCartPicker.EVENT_SHOWING";
      
      public static var mcClazz:Class;
       
      
      public var config:GameConfig;
      
      public var gui:IGuiCartPicker;
      
      private var adapter:GamePageManagerAdapter;
      
      private var sagaMarketOverlayNotificationShown:Boolean;
      
      private var _saga:Saga;
      
      private var bmpholderHelper:GuiBitmapHolderHelper;
      
      private var lastCartPickerPage:GamePage;
      
      private var cmd_back:Cmd;
      
      public function GamePageManagerAdapterCartPicker(param1:GamePageManagerAdapter)
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
         if(this.gui)
         {
            this.gui.removeEventListener(Event.CLOSE,this.cartPickerCloseHandler);
            this.gui.cleanup();
            this.gui = null;
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
      
      public function escapeFromCartPicker() : Boolean
      {
         if(Boolean(this.gui) && this.gui.movieClip.visible)
         {
            this.showCartPicker(false);
            return true;
         }
         return false;
      }
      
      private function checkCartPicker() : void
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
            this.gui = _loc1_ as IGuiCartPicker;
            this.gui.init(this.config.gameGuiContext);
            this.gui.addEventListener(Event.CLOSE,this.cartPickerCloseHandler);
            this.config.context.locale.translateDisplayObjects(LocaleCategory.GUI,this.gui.movieClip,this.config.logger);
            _loc1_.visible = false;
         }
      }
      
      private function cartPickerCloseHandler(param1:Event) : void
      {
         this.showCartPicker(false);
      }
      
      public function showCartPicker(param1:Boolean) : void
      {
         var _loc3_:GamePage = null;
         if(param1)
         {
            this.checkCartPicker();
         }
         if(!this.gui)
         {
            return;
         }
         var _loc2_:MovieClip = this.gui.movieClip;
         if(this.lastCartPickerPage)
         {
            if(this.lastCartPickerPage.overlay == _loc2_)
            {
               this.lastCartPickerPage.overlay = null;
            }
         }
         if(param1)
         {
            this.config.keybinder.bind(false,false,false,Keyboard.BACK,this.cmd_back,"");
            _loc2_.visible = true;
            _loc3_ = this.adapter.currentPage as GamePage;
            this.lastCartPickerPage = _loc3_;
            if(_loc3_)
            {
               _loc3_.overlay = _loc2_;
            }
            this.gui.showGuiCartPicker();
            WeatherManager.PAUSED = true;
            this.config.gameGuiContext.translateDisplayObjects(LocaleCategory.GUI,_loc2_);
         }
         else
         {
            this.lastCartPickerPage = null;
            _loc2_.visible = false;
            this.gui.hideGuiCartPicker();
            this.config.keybinder.unbind(this.cmd_back);
            this.cleanup();
            WeatherManager.PAUSED = false;
         }
         dispatchEvent(new Event(EVENT_SHOWING));
      }
      
      public function get visible() : Boolean
      {
         var _loc1_:MovieClip = !!this.gui ? this.gui.movieClip : null;
         return Boolean(_loc1_) && _loc1_.visible;
      }
      
      public function update(param1:int) : void
      {
         if(this.gui)
         {
            this.gui.update(param1);
         }
      }
      
      public function cmdfunc_back(param1:CmdExec) : void
      {
         this.showCartPicker(false);
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

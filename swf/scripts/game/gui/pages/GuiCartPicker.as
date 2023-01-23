package game.gui.pages
{
   import engine.core.locale.LocaleCategory;
   import engine.core.util.MovieClipAdapter;
   import engine.gui.GuiContextEvent;
   import engine.landscape.travel.def.CartDef;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiChitsGroup;
   import game.gui.GuiIcon;
   import game.gui.GuiIconLayoutType;
   import game.gui.IGuiContext;
   import game.gui.page.IGuiCartPicker;
   
   public class GuiCartPicker extends GuiBase implements IGuiCartPicker
   {
      
      private static const CART_PICKER_FPS:int = 20;
       
      
      public var button$left:ButtonWithIndex;
      
      public var button$right:ButtonWithIndex;
      
      public var button$close:ButtonWithIndex;
      
      public var button$confirm:ButtonWithIndex;
      
      public var text_cartTitle:TextField;
      
      public var text$ks_cart_thanks:TextField;
      
      private var _cartChits:GuiChitsGroup;
      
      private var _yox:MovieClip;
      
      private var _banner:MovieClip;
      
      private var _peeps:MovieClip;
      
      private var _cartPosition:MovieClip;
      
      private var _backgroundMatte:MovieClip;
      
      private var _peeps_mca:MovieClipAdapter;
      
      private var _banner_mca:MovieClipAdapter;
      
      private var _yox_mca:MovieClipAdapter;
      
      private var _selectedCart:CartDef;
      
      private var _cart:GuiIcon;
      
      private var _cartPicker_Gp:GuiCartPicker_Gp;
      
      private var _currentIndex:int;
      
      public function GuiCartPicker()
      {
         super();
         this._cartPicker_Gp = new GuiCartPicker_Gp(this);
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
         this._cartChits = requireGuiChild("chits") as GuiChitsGroup;
         this.button$right = requireGuiChild("button$right") as ButtonWithIndex;
         this.button$left = requireGuiChild("button$left") as ButtonWithIndex;
         this.button$confirm = requireGuiChild("button$confirm") as ButtonWithIndex;
         this.button$close = requireGuiChild("button$close") as ButtonWithIndex;
         this.text_cartTitle = requireGuiChild("text_cart_title") as TextField;
         this.text$ks_cart_thanks = requireGuiChild("text$ks_cart_thanks") as TextField;
         this.button$right.guiButtonContext = param1;
         this.button$left.guiButtonContext = param1;
         this.button$confirm.guiButtonContext = param1;
         this.button$close.guiButtonContext = param1;
         this.button$right.setDownFunction(this.buttonRightHandler);
         this.button$left.setDownFunction(this.buttonLeftHandler);
         this.button$confirm.setDownFunction(this.buttonConfirmHandler);
         this.button$close.setDownFunction(this.buttonCloseHandler);
         this._cartChits.init(param1);
         registerScalableTextfield(this.text_cartTitle);
         registerScalableTextfield(this.text$ks_cart_thanks);
         this._yox = requireGuiChild("yox") as MovieClip;
         this._banner = requireGuiChild("banner") as MovieClip;
         this._peeps = requireGuiChild("caravan_peeps") as MovieClip;
         this._cartPosition = requireGuiChild("cart_position") as MovieClip;
         this._backgroundMatte = requireGuiChild("background_matte") as MovieClip;
         this._yox_mca = new MovieClipAdapter(this._yox,CART_PICKER_FPS,0,false,param1.logger);
         this._banner_mca = new MovieClipAdapter(this._banner,CART_PICKER_FPS,0,false,param1.logger);
         this._peeps_mca = new MovieClipAdapter(this._peeps,CART_PICKER_FPS,0,false,param1.logger);
         this.localeChangedHandler(null);
         this.initializeCart();
      }
      
      public function cleanup() : void
      {
         this._cartChits = null;
         this.button$right.cleanup();
         this.button$left.cleanup();
         this.button$close.cleanup();
         this.button$confirm.cleanup();
         this._cartPicker_Gp.cleanup();
      }
      
      public function update(param1:int) : void
      {
         if(this._cart)
         {
            this._cart.update(param1);
         }
      }
      
      private function initializeCart() : void
      {
         this._selectedCart = _context.saga.getCartDef();
         if(!this._selectedCart)
         {
            this._selectedCart = _context.saga.def.cartDefs.getCartDefAt(0);
            this._currentIndex = 0;
         }
         else
         {
            this._currentIndex = this._getCurCartIndex();
         }
      }
      
      private function updateCart() : void
      {
         var _loc1_:String = "";
         if(this._cart)
         {
            if(this._selectedCart)
            {
               _loc1_ = this.getCartResourceUrl(this._selectedCart);
               if(Boolean(this._cart.resource) && this._cart.resource.url == _loc1_)
               {
                  return;
               }
            }
            this._cart.release();
            this._cart = null;
         }
         if(!this._selectedCart)
         {
            return;
         }
         this.localeChangedHandler(null);
         if(!_loc1_)
         {
            _loc1_ = this.getCartResourceUrl(this._selectedCart);
         }
         this._cart = _context.getAnimClip(_loc1_);
         this._cart.mouseChildren = false;
         this._cart.mouseEnabled = false;
         this._cartPosition.parent.addChildAt(this._cart,this._cartPosition.parent.getChildIndex(this._cartPosition));
         this._cart.x = this._cartPosition.x;
         this._cart.layout = GuiIconLayoutType.ACTUAL;
         this._cart.y = this._cartPosition.y;
         this._cartChits.numVisibleChits = _context.saga.def.cartDefs.getCartCount();
         this._cartChits.activeChitIndex = this._currentIndex;
      }
      
      private function getCartResourceUrl(param1:CartDef) : String
      {
         return context.saga.caravan.animBaseUrl + param1.animId + ".clip";
      }
      
      private function _getCurCartIndex() : int
      {
         if(!this._selectedCart)
         {
            return -1;
         }
         return _context.saga.def.cartDefs.getCartIndex(this._selectedCart);
      }
      
      private function _getCartAt(param1:int) : CartDef
      {
         return _context.saga.def.cartDefs.getCartDefAt(param1);
      }
      
      public function showGuiCartPicker() : void
      {
         this._yox_mca.playLooping();
         this._banner_mca.playLooping();
         this._peeps_mca.playLooping();
         this.visible = true;
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
         this.localeChangedHandler(null);
         this._cartPicker_Gp.activate();
         this.updateCart();
      }
      
      public function hideGuiCartPicker() : void
      {
         this._yox_mca.stop();
         this._banner_mca.stop();
         this._peeps_mca.stop();
         _context.removeEventListener(GuiContextEvent.LOCALE,this.localeChangedHandler);
         this._cartPicker_Gp.deactivate();
      }
      
      private function buttonRightHandler(param1:ButtonWithIndex) : void
      {
         this._selectedCart = this._getNextCart(true);
         this.updateCart();
      }
      
      private function buttonLeftHandler(param1:ButtonWithIndex) : void
      {
         this._selectedCart = this._getNextCart(false);
         this.updateCart();
      }
      
      private function _getNextCart(param1:Boolean) : CartDef
      {
         var _loc2_:int = this._getCurCartIndex();
         var _loc3_:int = _context.saga.def.cartDefs.getCartCount();
         if(param1)
         {
            _loc2_ = (_loc2_ + _loc3_ + 1) % _loc3_;
         }
         else
         {
            _loc2_ = (_loc2_ + _loc3_ - 1) % _loc3_;
         }
         this._currentIndex = _loc2_;
         return this._getCartAt(_loc2_);
      }
      
      private function buttonConfirmHandler(param1:ButtonWithIndex) : void
      {
         _context.saga.cartId = this._selectedCart.id;
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      private function buttonCloseHandler(param1:ButtonWithIndex) : void
      {
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      private function localeChangedHandler(param1:GuiContextEvent) : void
      {
         if(this._selectedCart)
         {
            this.text_cartTitle.text = _context.translateCategory(this._selectedCart.id,LocaleCategory.CARTS);
         }
         scaleTextfields();
      }
      
      public function notifyOverlayChange(param1:Boolean) : void
      {
      }
   }
}

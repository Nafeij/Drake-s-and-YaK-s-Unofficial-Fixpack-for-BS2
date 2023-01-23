package game.gui.pages.saga_market
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.entity.def.ItemDef;
   import flash.text.TextField;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   
   public class GuiSagaMarketTabItems extends GuiBase
   {
       
      
      private var market:GuiSagaMarket;
      
      public var _textDescription:TextField;
      
      public var tabs:Vector.<GuiSagaMarketTabItem>;
      
      private var gap:int = 0;
      
      private var _hovering:GuiSagaMarketTabItem;
      
      private var item:ItemDef;
      
      public function GuiSagaMarketTabItems()
      {
         this.tabs = new Vector.<GuiSagaMarketTabItem>();
         super();
      }
      
      public function setHovering(param1:GuiSagaMarketTabItem, param2:Boolean) : void
      {
         if(param2)
         {
            this.hovering = param1;
         }
         else if(this.hovering == param1)
         {
            this.hovering = null;
         }
      }
      
      public function cleanup() : void
      {
         var _loc2_:GuiSagaMarketTabItem = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.tabs.length)
         {
            _loc2_ = this.tabs[_loc1_];
            _loc2_.cleanup();
            _loc1_++;
         }
         this.tabs = null;
      }
      
      public function init(param1:IGuiContext, param2:GuiSagaMarket) : void
      {
         var i:int;
         var other:GuiSagaMarketTabItem = null;
         var c:GuiSagaMarketTabItem = null;
         var context:IGuiContext = param1;
         var market:GuiSagaMarket = param2;
         super.initGuiBase(context);
         this.market = market;
         this._textDescription = getChildByName("textDescription") as TextField;
         this._textDescription.visible = false;
         this._textDescription.mouseEnabled = false;
         this._textDescription.selectable = false;
         i = 0;
         while(i < numChildren)
         {
            c = getChildAt(i) as GuiSagaMarketTabItem;
            if(c)
            {
               c.init(context,this);
               this.tabs.push(c);
            }
            i++;
         }
         this.tabs.sort(function(param1:GuiSagaMarketTabItem, param2:GuiSagaMarketTabItem):int
         {
            return param1.x - param2.x;
         });
         if(this.tabs.length > 1)
         {
            this.gap = this.tabs[1].x - this.tabs[0].x;
         }
      }
      
      public function update() : void
      {
         var _loc3_:int = 0;
         var _loc5_:GuiSagaMarketTabItem = null;
         var _loc6_:ItemDef = null;
         var _loc1_:int = this.market._saga.market.numItemDefs;
         var _loc2_:int = Math.max(0,this.gap * (_loc1_ - 1));
         _loc3_ = -_loc2_ / 2;
         var _loc4_:int = 0;
         while(_loc4_ < this.tabs.length)
         {
            _loc5_ = this.tabs[_loc4_];
            if(_loc4_ < _loc1_)
            {
               _loc5_.visible = true;
               _loc5_.x = _loc3_ + this.gap * _loc4_;
               _loc6_ = this.market._saga.market.getItemDef(_loc4_);
               _loc5_.setItemInfo(_loc6_);
            }
            else
            {
               _loc5_.visible = false;
               _loc5_.x = 0;
            }
            _loc4_++;
         }
      }
      
      private function get hovering() : GuiSagaMarketTabItem
      {
         return this._hovering;
      }
      
      private function set hovering(param1:GuiSagaMarketTabItem) : void
      {
         this._hovering = param1;
         this.updateHoverText();
      }
      
      private function updateHoverText() : void
      {
         if(this._hovering)
         {
            this._textDescription.htmlText = this._hovering.itemDef.description + "<br>" + this._hovering.itemDef.brief;
            this._textDescription.visible = true;
            _context.locale.fixTextFieldFormat(this._textDescription,null,null,true);
         }
         else
         {
            this._textDescription.htmlText = "";
            this._textDescription.visible = false;
         }
      }
      
      private function doClicked(param1:GuiSagaMarketTabItem) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc8_:* = null;
         this.item = param1.itemDef;
         var _loc2_:IGuiDialog = context.createDialog();
         var _loc3_:String = context.translate("ok");
         var _loc4_:String = context.translate("cancel");
         var _loc7_:int = this.market.sagaRenown;
         if(this.item.price > _loc7_)
         {
            _loc5_ = context.translate("mkt_insufficient_renown_title");
            _loc6_ = context.translate("mkt_insufficient_renown_body");
            _loc6_ = _loc6_.replace("$RENOWN",this.item.price.toString());
            _loc6_ = _loc6_.replace("$ITEM",this.item.colorizedName);
            _loc2_.openDialog(_loc5_,_loc6_,_loc3_);
         }
         else
         {
            _loc5_ = context.translate("mkt_confirm_purchase_title");
            _loc6_ = context.translate("mkt_confirm_purchase_body");
            _loc6_ = _loc6_.replace("$RENOWN",this.item.price.toString());
            _loc8_ = this.item.colorizedName + "<br>";
            _loc8_ += this.item.description + "<br><br>";
            _loc8_ += this.item.brief + "<br><br>";
            _loc8_ += _loc6_;
            _loc2_.openTwoBtnDialog(_loc5_,_loc8_,_loc3_,_loc4_,this.dialogHandler);
         }
         this.market.onClickedItem(this.item);
      }
      
      public function handleClicked(param1:GuiSagaMarketTabItem) : void
      {
         if(!PlatformInput.isTouch)
         {
            this.doClicked(param1);
         }
      }
      
      public function handleReleased(param1:GuiSagaMarketTabItem) : void
      {
         if(PlatformInput.isTouch)
         {
            this.doClicked(param1);
         }
      }
      
      private function dialogHandler(param1:String) : void
      {
         var _loc2_:String = context.translate("ok");
         if(param1 == _loc2_)
         {
            this.market.handleItemPurchase(this.item);
            context.playSound("ui_travel_press");
         }
      }
      
      public function updateDisplayText() : void
      {
         var _loc2_:GuiSagaMarketTabItem = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.tabs.length)
         {
            _loc2_ = this.tabs[_loc1_];
            _loc2_.updateDisplayText();
            _loc1_++;
         }
         this.updateHoverText();
      }
   }
}

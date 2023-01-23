package game.gui.pages.saga_market
{
   import engine.entity.def.ItemDef;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiIcon;
   import game.gui.IGuiContext;
   
   public class GuiSagaMarketTabItem extends ButtonWithIndex
   {
       
      
      public var itemDef:ItemDef;
      
      public var _textName:TextField;
      
      public var _placeholderIcon:MovieClip;
      
      public var _textRank:TextField;
      
      public var _textPrice:TextField;
      
      private var _icon:GuiIcon;
      
      private var iconIndex:int;
      
      private var tabs:GuiSagaMarketTabItems;
      
      public function GuiSagaMarketTabItem()
      {
         super();
      }
      
      public function init(param1:IGuiContext, param2:GuiSagaMarketTabItems) : void
      {
         super.guiButtonContext = param1;
         this.tabs = param2;
         this._textName = getChildByName("textName") as TextField;
         this._placeholderIcon = getChildByName("placeholderIcon") as MovieClip;
         this._textRank = getChildByName("textRank") as TextField;
         this._textPrice = getChildByName("textPrice") as TextField;
         setDownFunction(this.clickHandler);
         setUpFunction(this.releaseHandler);
         this.iconIndex = getChildIndex(this._placeholderIcon);
         this._placeholderIcon.visible = false;
         this._textName.mouseEnabled = false;
         this._textRank.mouseEnabled = false;
         this._textPrice.mouseEnabled = false;
      }
      
      private function clickHandler(param1:ButtonWithIndex) : void
      {
         this.tabs.handleClicked(this);
      }
      
      private function releaseHandler(param1:ButtonWithIndex) : void
      {
         this.tabs.handleReleased(this);
      }
      
      private function rollOutHandler(param1:MouseEvent) : void
      {
         this.tabs.setHovering(this,false);
      }
      
      private function rollOverHandler(param1:MouseEvent) : void
      {
         this.tabs.setHovering(this,true);
      }
      
      public function setItemInfo(param1:ItemDef) : void
      {
         this.itemDef = param1;
         if(param1)
         {
            this.updateDisplayText();
            this._textRank.text = param1.rank.toString();
            this._textPrice.text = param1.price.toString();
            this.icon = _context.getIcon(param1.icon);
            addEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
            addEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
            visible = true;
         }
         else
         {
            removeEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
            removeEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
            visible = false;
         }
      }
      
      public function updateDisplayText() : void
      {
         if(Boolean(this._textName) && Boolean(this.itemDef))
         {
            this._textName.htmlText = this.itemDef.colorizedName;
            _context.currentLocale.fixTextFieldFormat(this._textName,null,this.itemDef.color);
         }
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         removeEventListener(MouseEvent.ROLL_OUT,this.rollOutHandler);
         removeEventListener(MouseEvent.ROLL_OVER,this.rollOverHandler);
      }
      
      public function get icon() : GuiIcon
      {
         return this._icon;
      }
      
      public function set icon(param1:GuiIcon) : void
      {
         if(this._icon == param1)
         {
            return;
         }
         if(this._icon)
         {
            removeChild(this._icon);
            this._icon.release();
            this._icon = null;
         }
         this._icon = param1;
         if(this._icon)
         {
            addChildAt(this._icon,this.iconIndex);
            this._icon.x = this._placeholderIcon.x;
            this._icon.y = this._placeholderIcon.y;
         }
      }
      
      override public function setHovering(param1:Boolean) : void
      {
         super.setHovering(param1);
         this.tabs.setHovering(this,param1);
      }
   }
}

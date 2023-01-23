package game.gui
{
   import engine.core.locale.Locale;
   import engine.entity.def.ItemDef;
   import engine.gui.GuiUtil;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class GuiItemInfo extends GuiBase
   {
       
      
      private var _itemDef:ItemDef;
      
      public var _textName:TextField;
      
      public var _textDescription:TextField;
      
      private var _textDescriptionSize:Point;
      
      public function GuiItemInfo()
      {
         this._textDescriptionSize = new Point();
         super();
         this._textName = getChildByName("textName") as TextField;
         this._textDescription = getChildByName("textDescription") as TextField;
         this._textDescriptionSize.x = this._textDescription.width;
         this._textDescriptionSize.y = this._textDescription.height;
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
         initContainer();
         visible = false;
      }
      
      public function get itemDef() : ItemDef
      {
         return this._itemDef;
      }
      
      public function set itemDef(param1:ItemDef) : void
      {
         this._itemDef = param1;
         if(this._itemDef)
         {
            this.handleLocaleChange();
            visible = true;
         }
         else
         {
            visible = false;
         }
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         if(!this._itemDef)
         {
            return;
         }
         var _loc1_:Locale = _context.currentLocale;
         var _loc2_:String = this._itemDef.colorizedName;
         this._textName.htmlText = _loc2_;
         this._textDescription.htmlText = this._itemDef.description + "<br>" + this._itemDef.brief;
         _loc1_.fixTextFieldFormat(this._textName,null,null,true);
         _loc1_.fixTextFieldFormat(this._textDescription,null,null,true);
         GuiUtil.scaleTextToFit2dWordwrap(this._textDescription,this._textDescriptionSize.x,this._textDescriptionSize.y);
      }
   }
}

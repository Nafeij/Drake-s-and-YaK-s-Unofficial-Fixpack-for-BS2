package game.gui.pages
{
   import engine.core.analytic.Ga;
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleFont;
   import engine.core.locale.LocaleInfo;
   import engine.gui.GuiContextEvent;
   import engine.gui.GuiUtil;
   import engine.gui.SagaNews;
   import engine.gui.SagaNewsEntry;
   import flash.filters.BitmapFilterQuality;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.StyleSheet;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import game.gui.GuiBase;
   import game.gui.GuiIcon;
   import game.gui.GuiIconLayoutType;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   
   public class GuiSagaNewsEntry extends GuiBase
   {
       
      
      public var entry:SagaNewsEntry;
      
      public var icon:GuiIcon;
      
      public var iconHover:GuiIcon;
      
      private var _text:TextField;
      
      public var guiNews:GuiSagaNews;
      
      private var _hovering:Boolean;
      
      private var _dialog:IGuiDialog;
      
      private var _dialogEntry:SagaNewsEntry;
      
      public function GuiSagaNewsEntry()
      {
         super();
         super.visible = false;
      }
      
      public function get hovering() : Boolean
      {
         return this._hovering;
      }
      
      public function set hovering(param1:Boolean) : void
      {
         this._hovering = param1;
         if(this.iconHover)
         {
            this.iconHover.visible = this._hovering;
         }
      }
      
      public function init(param1:IGuiContext, param2:GuiSagaNews, param3:SagaNews, param4:SagaNewsEntry) : void
      {
         var _loc5_:String = null;
         super.initGuiBase(param1);
         this.guiNews = param2;
         this._text = param2._text;
         this.entry = param4;
         if(param4.image.url)
         {
            _loc5_ = param4.translateUrl(param4.image.url,param3.baseUrl);
            _context.logger.info("loading news icon [" + _loc5_ + "]");
            this.icon = _context.getIcon(_loc5_);
            this.icon.layout = GuiIconLayoutType.ACTUAL;
            this.icon.x = param4.image.rect.x;
            this.icon.y = param4.image.rect.y;
            addChildAt(this.icon,0);
         }
         if(param4.hoverUrl)
         {
            this.iconHover = _context.getIcon(param4.hoverUrl);
            this.iconHover.layout = GuiIconLayoutType.ACTUAL;
            this.iconHover.x = param4.image.rect.x;
            this.iconHover.y = param4.image.rect.y;
            addChildAt(this.iconHover,0);
         }
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.performLayout();
      }
      
      public function cleanup() : void
      {
         if(this.icon)
         {
            this.icon.release();
            this.icon = null;
         }
         _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         super.cleanupGuiBase();
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         this.performLayout();
      }
      
      public function performLayout() : void
      {
         var _loc5_:Rectangle = null;
         var _loc6_:LocaleInfo = null;
         var _loc7_:LocaleFont = null;
         var _loc8_:LocaleFont = null;
         var _loc9_:StyleSheet = null;
         var _loc10_:String = null;
         if(!super.visible)
         {
            return;
         }
         var _loc1_:Object = this.entry.text.glow;
         if(_loc1_)
         {
            this._text.filters = [new GlowFilter(_loc1_.color,_loc1_.alpha,_loc1_.blur,_loc1_.blur,_loc1_.strength,BitmapFilterQuality.HIGH)];
         }
         else
         {
            this._text.filters = [];
         }
         this._text.visible = true;
         var _loc2_:Locale = _context.locale;
         var _loc3_:String = _loc2_.id.id;
         var _loc4_:String = this.entry.getText(_loc3_);
         if(this._text.styleSheet)
         {
            this._text.styleSheet = null;
         }
         if(this.entry.text.css)
         {
            _loc6_ = _loc2_.info;
            _loc7_ = _loc6_.font_m;
            _loc8_ = _loc6_.font_v;
            _loc9_ = new StyleSheet();
            for each(_loc10_ in this.entry.text.css)
            {
               if(_loc7_)
               {
                  _loc10_ = _loc10_.replace(/\"Minion Pro.*?\";/,"\"" + _loc7_.face + "\";");
               }
               if(_loc8_)
               {
                  _loc10_ = _loc10_.replace(/\"Vinque.*?\";/,"\"" + _loc8_.face + "\";");
               }
               _loc9_.parseCSS(_loc10_);
            }
            this._text.styleSheet = _loc9_;
         }
         this._text.htmlText = _loc4_;
         this._text.multiline = this.entry.text.multiline;
         this._text.autoSize = TextFieldAutoSize.NONE;
         this._text.wordWrap = this.entry.text.multiline;
         _loc5_ = this.entry.text.rect;
         this._text.x = _loc5_.x;
         this._text.y = _loc5_.y;
         this._text.width = _loc5_.width;
         this._text.height = _loc5_.height;
         this._text.opaqueBackground = this.entry.text.opaqueBackground;
         GuiUtil.scaleTextToFit2d(this._text,_loc5_.width,_loc5_.height,false);
         this._text.x = _loc5_.x;
         this._text.y = _loc5_.y;
      }
      
      public function performClick() : void
      {
         var _loc1_:URLRequest = null;
         var _loc2_:String = null;
         var _loc3_:Array = null;
         _context.playSound("ui_willpower_select");
         Ga.normal("news","click",this.entry.id,1);
         if(this.entry.hyperlink)
         {
            _loc1_ = new URLRequest(this.entry.hyperlink);
            _context.logger.info("GuiSagaNewsEntry [" + this.entry.id + "] navigating to [" + _loc1_.url + "]");
            _context.saga.appinfo.navigateToURL(_loc1_);
         }
         if(this._dialog)
         {
            this._dialog.closeDialog(null);
         }
         this._dialogEntry = this.entry.dialog;
         if(this._dialogEntry)
         {
            _context.logger.info("GuiSagaNewsEntry [" + this.entry.id + "] opening dialog [" + this.entry.dialog.id + "]");
            this._dialog = _context.createDialog();
            _loc2_ = this._dialogEntry.getText(_context.locale.id.id);
            _loc3_ = this._dialogEntry.buttons;
            if(!_loc3_ || _loc3_.length == 0)
            {
               this._dialog.openDialog("news",_loc2_,null,this.dialogClosedHandler);
               this._dialog.setCloseButtonVisible(true);
            }
            else if(_loc3_.length == 1)
            {
               this._dialog.openDialog("news",_loc2_,_loc3_[0].label,this.dialogClosedHandler);
            }
            else
            {
               this._dialog.openTwoBtnDialog("news",_loc2_,_loc3_[0].label,_loc3_[1].label,this.dialogClosedHandler);
            }
         }
      }
      
      public function dialogClosedHandler(param1:*) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:URLRequest = null;
         param1 = param1;
         if(!this._dialogEntry || !this._dialog)
         {
            this._dialog = null;
            this._dialogEntry = null;
            return;
         }
         for each(_loc2_ in this._dialogEntry.buttons)
         {
            if(_loc2_.label == param1)
            {
               _loc3_ = String(_loc2_.hyperlink);
               if(_loc3_)
               {
                  _loc4_ = new URLRequest(_loc3_);
                  _context.logger.info("GuiSagaNewsEntry.dialogClosedHander(" + param1 + ") [" + this.entry.id + "] navigating to [" + _loc4_.url + "]");
                  navigateToURL(_loc4_);
                  break;
               }
            }
         }
         this._dialog = null;
         this._dialogEntry = null;
      }
   }
}

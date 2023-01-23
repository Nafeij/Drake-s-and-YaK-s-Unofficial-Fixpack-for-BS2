package engine.gui
{
   import engine.core.locale.LocaleCategory;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class GuiCaption extends MovieClip
   {
      
      public static var mcClazz:Class;
       
      
      private var _text:TextField;
      
      private var _bg:MovieClip;
      
      private var _context:IEngineGuiContext;
      
      private var _token:String;
      
      private var _rightAligned:Boolean;
      
      private var _canShow:Boolean;
      
      public function GuiCaption()
      {
         super();
         this._text = getChildByName("text") as TextField;
         this._bg = getChildByName("bg") as MovieClip;
         super.visible = false;
      }
      
      public static function ctor(param1:IEngineGuiContext, param2:String) : GuiCaption
      {
         if(mcClazz == null)
         {
            return null;
         }
         var _loc3_:GuiCaption = new mcClazz() as GuiCaption;
         _loc3_.init(param1,param2);
         return _loc3_;
      }
      
      public function set scale(param1:Number) : void
      {
         this.scaleX = this.scaleY = param1;
      }
      
      public function init(param1:IEngineGuiContext, param2:String) : GuiCaption
      {
         this._context = param1;
         this._context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         this.setToken(param2);
         return this;
      }
      
      public function cleanup() : void
      {
         if(this._context)
         {
            this._context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         }
      }
      
      private function localeHandler(param1:Event) : void
      {
         this.updateText();
      }
      
      public function setRightAligned(param1:Boolean) : void
      {
         this._rightAligned = param1;
      }
      
      public function setToken(param1:String) : void
      {
         if(this._token == param1)
         {
            return;
         }
         this._token = param1;
         this.updateText();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(param1 == this._canShow)
         {
            return;
         }
         this._canShow = param1;
         this.checkVisible();
      }
      
      private function checkVisible() : void
      {
         super.visible = this._canShow && Boolean(this._token);
      }
      
      public function updateText() : void
      {
         this.checkVisible();
         if(!this._context || !this._token)
         {
            return;
         }
         var _loc1_:Number = this.width;
         var _loc2_:String = this._context.translateCategory(this._token,LocaleCategory.GP);
         this._text.width = 1000;
         this._text.text = _loc2_;
         this._context.locale.fixTextFieldFormat(this._text);
         this._text.width = this._text.textWidth + 10;
         this._bg.scaleX = this._text.width;
         this._bg.scaleY = this._text.height;
         var _loc3_:Number = this.width - _loc1_;
         if(this._rightAligned && Boolean(this.parent))
         {
            this.x -= _loc3_;
         }
      }
   }
}

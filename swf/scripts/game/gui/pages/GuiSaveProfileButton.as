package game.gui.pages
{
   import engine.core.locale.LocaleCategory;
   import engine.core.util.StringUtil;
   import engine.gui.GuiButtonState;
   import engine.saga.Saga;
   import engine.saga.save.SagaSave;
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.IGuiContext;
   
   public class GuiSaveProfileButton extends ButtonWithIndex
   {
       
      
      private var _ss:SagaSave;
      
      public var bk:String;
      
      public var _text_header:TextField;
      
      public var _text_date:TextField;
      
      public var _text_day:TextField;
      
      public var _text$profile_empty:TextField;
      
      public function GuiSaveProfileButton()
      {
         super();
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.guiButtonContext = param1;
         this._text_header = getChildByName("text_header") as TextField;
         this._text_date = getChildByName("text_date") as TextField;
         this._text_day = getChildByName("text_day") as TextField;
         this._text$profile_empty = getChildByName("text$profile_empty") as TextField;
         visible = false;
      }
      
      override public function set state(param1:GuiButtonState) : void
      {
         super.state = param1;
         if(!_context)
         {
            return;
         }
      }
      
      public function setupButton(param1:int, param2:SagaSave, param3:String) : void
      {
         var _loc5_:String = null;
         var _loc9_:int = 0;
         var _loc10_:* = null;
         var _loc11_:String = null;
         this.index = param1;
         this.ss = param2;
         this._text_header.htmlText = _context.translate("profile") + " " + (param1 + 1);
         _context.currentLocale.fixTextFieldFormat(this._text_header);
         if(!param2)
         {
            this._text$profile_empty.visible = true;
            this._text_date.htmlText = "";
            this._text_day.htmlText = "";
            _context.currentLocale.fixTextFieldFormat(this._text$profile_empty);
            visible = true;
            return;
         }
         this._text$profile_empty.visible = false;
         var _loc4_:int = param2.day;
         var _loc6_:Number = Number(param2.id);
         if(_loc6_.toString() != param2.id)
         {
            _loc5_ = _context.translateCategory(param2.id,LocaleCategory.LOCATION);
         }
         else
         {
            _loc5_ = param2.id;
         }
         var _loc7_:String = StringUtil.dateStringSansTZ(param2.date);
         this._text_date.htmlText = _loc7_;
         var _loc8_:Saga = _context.saga;
         if(_loc8_.isSurvival)
         {
            _loc9_ = param2.getDifficulty(_loc8_);
            _loc10_ = _loc8_.getDifficultyStringHtml(_loc9_) + " ";
            _loc10_ += param2.survivalProgress + "/" + _loc8_.survivalTotal;
            this._text_day.htmlText = _loc10_;
         }
         else
         {
            _loc11_ = _context.translate("day") + " " + _loc4_;
            if(param3)
            {
               _loc11_ = param3 + " " + _loc11_;
            }
            this._text_day.htmlText = _loc11_;
         }
         visible = true;
         _context.currentLocale.fixTextFieldFormat(this._text_header);
         _context.currentLocale.fixTextFieldFormat(this._text_date);
         _context.currentLocale.fixTextFieldFormat(this._text_day);
      }
      
      public function get ss() : SagaSave
      {
         return this._ss;
      }
      
      public function set ss(param1:SagaSave) : void
      {
         if(this._ss == param1)
         {
            return;
         }
         this._ss = param1;
      }
   }
}

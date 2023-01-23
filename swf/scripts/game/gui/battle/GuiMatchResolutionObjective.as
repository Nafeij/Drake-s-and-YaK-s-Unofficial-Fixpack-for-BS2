package game.gui.battle
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Bounce;
   import engine.core.locale.LocaleCategory;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiMatchResolutionObjective extends GuiBase
   {
       
      
      public var _text:TextField;
      
      public var _check:MovieClip;
      
      public var _cross:MovieClip;
      
      public var _token:String;
      
      public function GuiMatchResolutionObjective()
      {
         super();
         this.visible = false;
         this._text = getChildByName("text") as TextField;
         this._check = getChildByName("check") as MovieClip;
         this._cross = getChildByName("cross") as MovieClip;
         this._check.visible = false;
         this._cross.visible = false;
      }
      
      private static function showResultMc(param1:MovieClip) : void
      {
         param1.visible = true;
         param1.scaleX = param1.scaleY = 0;
         TweenMax.to(param1,0.5,{
            "scaleX":1,
            "scaleY":1,
            "ease":Bounce.easeOut
         });
      }
      
      public function init(param1:IGuiContext, param2:String, param3:Boolean) : void
      {
         super.initGuiBase(param1);
         this.visible = true;
         this._token = param2;
         registerScalableTextfield(this._text);
         this._text.htmlText = param1.translateCategory(param2 + "_brief",LocaleCategory.BATTLE_OBJ);
         _context.locale.fixTextFieldFormat(this._text);
         if(param3)
         {
            showResultMc(this._check);
            _context.playSound("ui_stats_glisten");
         }
         else
         {
            showResultMc(this._cross);
            _context.playSound("ui_error");
         }
         scaleTextfields();
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         this._text.htmlText = context.translate(this._token);
         _context.locale.fixTextFieldFormat(this._text);
         scaleTextfields();
      }
   }
}

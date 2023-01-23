package game.gui
{
   import engine.gui.GuiUtil;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class GuiIconInjury extends GuiBase
   {
       
      
      public var _text:TextField;
      
      public var _label$injury:TextField;
      
      public var _censor:MovieClip;
      
      public function GuiIconInjury()
      {
         super();
         this._text = getChildByName("text") as TextField;
         this._label$injury = getChildByName("label$injury") as TextField;
         this._censor = getChildByName("censor") as MovieClip;
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
         this.days = 0;
         GuiUtil.performCensor(this._censor,_context.censorId,_context.logger);
      }
      
      public function get days() : int
      {
         return -1;
      }
      
      public function set days(param1:int) : void
      {
         if(param1 <= 0)
         {
            visible = false;
         }
         else
         {
            visible = true;
            if(this._text)
            {
               this._text.text = param1.toString();
            }
         }
      }
   }
}

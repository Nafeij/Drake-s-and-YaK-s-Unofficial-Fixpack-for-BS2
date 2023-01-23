package game.gui
{
   public class GuiChit extends GuiBase
   {
       
      
      private var _highlighted:Boolean;
      
      public function GuiChit()
      {
         super();
         this.highlighted = false;
      }
      
      public function get highlighted() : Boolean
      {
         return this._highlighted;
      }
      
      public function set highlighted(param1:Boolean) : void
      {
         this._highlighted = param1;
         gotoAndStop(this._highlighted ? 2 : 1);
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
      }
   }
}

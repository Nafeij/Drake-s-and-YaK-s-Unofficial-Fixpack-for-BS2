package game.gui.battle
{
   import flash.text.TextField;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiHornEnemy extends GuiBase
   {
       
      
      public var _enemyPendent:ButtonWithIndex;
      
      public var _hornCount:TextField;
      
      private var _enemyCount:int;
      
      public function GuiHornEnemy()
      {
         super();
         this._enemyPendent = requireGuiChild("enemyPendent") as ButtonWithIndex;
         this._hornCount = requireGuiChild("hornCount") as TextField;
      }
      
      public function cleanup() : void
      {
         super.cleanupGuiBase();
         this._enemyPendent.cleanup();
      }
      
      public function init(param1:IGuiContext) : void
      {
         initGuiBase(param1);
         this._hornCount.mouseEnabled = false;
         this._hornCount.text = "0";
         gotoAndStop(1);
      }
      
      public function set enemyCount(param1:int) : void
      {
         if(this._enemyCount == param1)
         {
            return;
         }
         this._enemyCount = param1;
         this._hornCount.text = this._enemyCount.toString();
      }
      
      public function get enemyCount() : int
      {
         return this._enemyCount;
      }
   }
}

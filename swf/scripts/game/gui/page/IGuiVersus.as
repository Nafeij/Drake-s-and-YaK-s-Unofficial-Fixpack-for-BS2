package game.gui.page
{
   import engine.entity.def.IEntityListDef;
   import game.gui.IGuiContext;
   
   public interface IGuiVersus
   {
       
      
      function init(param1:IGuiContext, param2:int, param3:IGuiVersusListener) : void;
      
      function setOpponent(param1:IEntityListDef, param2:String, param3:Boolean) : void;
      
      function reset() : void;
      
      function cleanup() : void;
      
      function get chatAlignmentGlobalY() : Number;
   }
}

package game.gui.page
{
   import game.gui.IGuiContext;
   
   public interface IGuiSagaSelector
   {
       
      
      function init(param1:IGuiContext, param2:IGuiSagaSelectorListener) : void;
      
      function update(param1:int) : void;
      
      function cleanup() : void;
      
      function performButtonPress(param1:int) : void;
   }
}

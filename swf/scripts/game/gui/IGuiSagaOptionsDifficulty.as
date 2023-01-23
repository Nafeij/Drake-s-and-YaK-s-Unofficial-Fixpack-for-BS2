package game.gui
{
   public interface IGuiSagaOptionsDifficulty
   {
       
      
      function init(param1:IGuiContext, param2:IGuiSagaOptionsDifficultyListener) : void;
      
      function setSize(param1:Number, param2:Number) : void;
      
      function cleanup() : void;
      
      function closeOptionsDifficulty() : Boolean;
      
      function showSagaOptionsDifficulty(param1:int) : void;
      
      function handleLocaleChange() : void;
      
      function get visible() : Boolean;
      
      function ensureTopGp() : void;
   }
}

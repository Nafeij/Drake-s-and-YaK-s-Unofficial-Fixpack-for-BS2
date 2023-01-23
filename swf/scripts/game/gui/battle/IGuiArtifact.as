package game.gui.battle
{
   import engine.gui.GuiGpBitmap;
   import engine.saga.ISaga;
   import engine.sound.ISoundDriver;
   import game.gui.IGuiContext;
   
   public interface IGuiArtifact
   {
       
      
      function init(param1:IGuiContext, param2:IGuiArtifactListener, param3:ISaga, param4:GuiGpBitmap, param5:ISoundDriver = null) : void;
      
      function set count(param1:int) : void;
      
      function get count() : int;
      
      function set enemyCount(param1:int) : void;
      
      function get enemyCount() : int;
      
      function set artifactVisible(param1:Boolean) : void;
      
      function get artifactVisible() : Boolean;
      
      function cleanup() : void;
      
      function handleResize() : void;
      
      function get hornFinishedAnimating() : Boolean;
      
      function get maxCount() : int;
   }
}

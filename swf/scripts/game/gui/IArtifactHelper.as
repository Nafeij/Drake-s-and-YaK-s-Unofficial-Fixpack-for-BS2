package game.gui
{
   import engine.battle.board.model.BattleBoard;
   import engine.core.logging.ILogger;
   import game.gui.battle.IGuiArtifact;
   
   public interface IArtifactHelper
   {
       
      
      function get artifact() : IGuiArtifact;
      
      function showArtifact(param1:Boolean) : void;
      
      function resizeHandler() : void;
      
      function get logger() : ILogger;
      
      function cleanup() : void;
      
      function get board() : BattleBoard;
      
      function set board(param1:BattleBoard) : void;
      
      function useArtifact() : void;
      
      function guiArtifactUse() : void;
      
      function getMaxUse() : int;
   }
}

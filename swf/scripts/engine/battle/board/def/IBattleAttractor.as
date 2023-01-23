package engine.battle.board.def
{
   import engine.tile.def.TileRect;
   
   public interface IBattleAttractor
   {
       
      
      function get core() : TileRect;
      
      function get leash() : int;
      
      function get leashRect() : TileRect;
      
      function get def() : BattleAttractorDef;
      
      function get enabled() : Boolean;
      
      function set enabled(param1:Boolean) : void;
      
      function toString() : String;
   }
}

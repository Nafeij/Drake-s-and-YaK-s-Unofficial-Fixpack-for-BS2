package engine.saga.vars
{
   import engine.battle.board.model.IBattleEntity;
   import engine.tile.def.TileRect;
   
   public interface IBattleEntityProvider
   {
       
      
      function getEntityByDefId(param1:String, param2:TileRect, param3:Boolean) : IBattleEntity;
      
      function getEntityByIdOrByDefId(param1:String, param2:TileRect, param3:Boolean) : IBattleEntity;
   }
}

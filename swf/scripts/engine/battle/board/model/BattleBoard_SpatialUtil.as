package engine.battle.board.model
{
   public class BattleBoard_SpatialUtil
   {
       
      
      public function BattleBoard_SpatialUtil()
      {
         super();
      }
      
      public static function checkAdjacentEnemies(param1:IBattleEntity, param2:Vector.<IBattleEntity>, param3:Boolean) : Boolean
      {
         var _loc4_:IBattleEntity = null;
         if(!param2)
         {
            param2 = new Vector.<IBattleEntity>();
         }
         else
         {
            param2.splice(0,param2.length);
         }
         param1.board.findAllAdjacentEntities(param1,param1.rect,param2,param3);
         for each(_loc4_ in param2)
         {
            if(_loc4_ != param1 && _loc4_.team != param1.team)
            {
               return true;
            }
         }
         return false;
      }
   }
}

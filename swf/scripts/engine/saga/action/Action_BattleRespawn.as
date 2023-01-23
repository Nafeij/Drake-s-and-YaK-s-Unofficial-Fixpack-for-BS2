package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_BattleRespawn extends Action
   {
       
      
      public function Action_BattleRespawn(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:int = def.varvalue;
         var _loc2_:String = def.param;
         var _loc3_:String = def.bucket;
         var _loc4_:String = def.spawn_tags;
         saga.performWarRespawn(_loc1_,_loc2_,_loc3_,_loc4_);
         end();
      }
   }
}

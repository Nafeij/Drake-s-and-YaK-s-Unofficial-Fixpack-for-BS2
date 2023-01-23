package engine.saga.action
{
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   import engine.saga.SagaLegend;
   import engine.stat.def.StatType;
   
   public class Action_UnitKillAdd extends Action
   {
       
      
      public function Action_UnitKillAdd(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc2_:IEntityDef = null;
         var _loc4_:SagaLegend = null;
         var _loc5_:int = 0;
         var _loc1_:String = def.id;
         var _loc3_:int = def.varvalue;
         if(_loc1_ == "*roster")
         {
            _loc4_ = saga.caravan._legend;
            _loc5_ = 0;
            while(_loc5_ < _loc4_.roster.numCombatants)
            {
               _loc2_ = _loc4_.roster.getEntityDef(_loc5_);
               this._addKill(_loc2_,_loc3_);
               _loc5_++;
            }
         }
         else
         {
            _loc2_ = saga.getCastMember(_loc1_);
            if(!_loc2_)
            {
               throw new ArgumentError("invalid entity not in cast: " + def.id);
            }
            this._addKill(_loc2_,_loc3_);
         }
         end();
      }
      
      private function _addKill(param1:IEntityDef, param2:int) : void
      {
         var _loc3_:int = int(param1.stats.getValue(StatType.KILLS));
         param1.stats.setBase(StatType.KILLS,_loc3_ + param2);
      }
   }
}

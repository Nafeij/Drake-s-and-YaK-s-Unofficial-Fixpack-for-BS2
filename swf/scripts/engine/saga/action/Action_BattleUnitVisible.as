package engine.saga.action
{
   import com.greensock.TweenMax;
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.model.IEntity;
   import engine.saga.Saga;
   
   public class Action_BattleUnitVisible extends Action
   {
       
      
      public function Action_BattleUnitVisible(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc7_:IBattleEntity = null;
         if(!def.id)
         {
            return;
         }
         var _loc1_:String = def.param;
         var _loc2_:Boolean = Boolean(_loc1_) && _loc1_.indexOf("allowDead") >= 0;
         var _loc3_:* = def.varvalue != 0;
         var _loc4_:int = def.time * 1000;
         var _loc5_:String = def.id;
         var _loc6_:Vector.<IEntity> = extractEntities(_loc5_,_loc2_);
         for each(_loc7_ in _loc6_)
         {
            _loc7_.setVisible(_loc3_,_loc4_);
         }
         if(def.instant || !_loc4_)
         {
            end();
         }
         else
         {
            TweenMax.delayedCall(_loc4_ / 1000,this.fadeComplete);
         }
      }
      
      override protected function handleEnded() : void
      {
         TweenMax.killDelayedCallsTo(this.fadeComplete);
      }
      
      private function fadeComplete() : void
      {
         end();
      }
   }
}

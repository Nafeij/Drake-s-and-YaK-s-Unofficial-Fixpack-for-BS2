package engine.saga.action
{
   import engine.battle.board.model.IBattleEntity;
   import engine.saga.Saga;
   
   public class Action_PropSetUsability extends Action
   {
       
      
      public function Action_PropSetUsability(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:IBattleEntity = saga.getEntityByIdOrByDefId(def.id,null,true);
         if(!_loc1_)
         {
            throw new ArgumentError("invalid entity not found on battleboard: " + def.id);
         }
         if(!_loc1_.usability)
         {
            throw new ArgumentError("entity does not have a valid Usability: " + def.id);
         }
         var _loc2_:* = def.varvalue != 0;
         _loc1_.usable = _loc2_;
         end();
      }
   }
}

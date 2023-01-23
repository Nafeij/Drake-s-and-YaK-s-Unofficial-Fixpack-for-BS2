package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.def.EffectTagReqs;
   import engine.battle.ability.effect.def.EffectTagReqsVars;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.model.BattleBoardTrigger;
   import engine.tile.def.TileLocation;
   
   public class Op_ExpireEffects extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_ExpireEffects",
         "properties":{"tagReqs":{
            "type":EffectTagReqsVars.schema,
            "optional":true
         }}
      };
       
      
      private var tagReqs:EffectTagReqs;
      
      public function Op_ExpireEffects(param1:EffectDefOp, param2:Effect)
      {
         super(param1,param2);
         if(param1.params.tagReqs)
         {
            this.tagReqs = new EffectTagReqsVars(param1.params.tagReqs,manager.logger);
         }
      }
      
      override public function apply() : void
      {
         var _loc1_:BattleBoardTrigger = null;
         var _loc2_:Number = NaN;
         var _loc3_:Boolean = false;
         var _loc4_:IBattleAbility = null;
         caster.logger.debug("Op_ExpireEffects.apply ENTER");
         for each(_loc1_ in caster.board.triggers.triggers)
         {
            if(_loc1_.effect)
            {
               _loc2_ = TileLocation.manhattanDistance(tile.x,tile.y,_loc1_.rect.left,_loc1_.rect.front);
               if(_loc2_ <= 1)
               {
                  if(this.tagReqs.checkTags(_loc1_.effect,logger))
                  {
                     _loc3_ = true;
                     _loc4_ = this.effect.ability;
                     while(_loc4_ != null)
                     {
                        if(_loc4_ == _loc1_.effect.ability)
                        {
                           _loc3_ = false;
                           break;
                        }
                        _loc4_ = _loc4_.parent;
                     }
                     if(_loc3_ == true)
                     {
                        caster.logger.debug("Op_ExpireEffects.apply FORCING EXPIRATION");
                        _loc1_.effect.forceExpiration();
                     }
                  }
               }
            }
         }
      }
   }
}

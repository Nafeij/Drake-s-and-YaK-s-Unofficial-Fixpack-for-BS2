package engine.battle.board.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.ability.effect.model.PersistedEffects;
   import engine.core.logging.ILogger;
   
   public class PersistedRule
   {
      
      public static const schema:Object = {
         "name":"PersistedRule",
         "type":"object",
         "properties":{
            "ability":{"type":"string"},
            "check_casted":{"type":"boolean"},
            "check_targeted":{"type":"boolean"},
            "effect":{"type":"string"},
            "num_min":{"type":"number"},
            "num_max":{"type":"number"}
         }
      };
       
      
      public var check_casted:Boolean;
      
      public var check_targeted:Boolean;
      
      public var abilityId:String;
      
      public var effectId:String;
      
      public var num_min:int = 1;
      
      public var num_max:int = -1;
      
      public function PersistedRule()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : PersistedRule
      {
         this.check_casted = param1.check_casted;
         this.check_targeted = param1.check_targeted;
         this.abilityId = param1.ability;
         this.effectId = param1.effect;
         if(param1.num_min != undefined)
         {
            this.num_min = param1.num_min;
         }
         if(param1.num_max != undefined)
         {
            this.num_max = param1.num_max;
         }
         return this;
      }
      
      public function checkPersistedRule(param1:PersistedEffects) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = this.num_max + 1;
         if(param1)
         {
            if(this.check_targeted)
            {
               _loc2_ = this._countEffects(param1._effects,_loc3_);
               if(this.num_min > 0)
               {
                  if(this.num_min > _loc2_)
                  {
                     return false;
                  }
               }
               if(this.num_max >= 0)
               {
                  if(this.num_max < _loc2_)
                  {
                     return false;
                  }
               }
            }
            if(this.check_casted)
            {
               _loc2_ = this._countEffects(param1.casted,_loc3_);
               if(this.num_min >= 0)
               {
                  if(this.num_min > _loc2_)
                  {
                     return false;
                  }
               }
               if(this.num_max >= 0)
               {
                  if(this.num_max < _loc2_)
                  {
                     return false;
                  }
               }
            }
         }
         return true;
      }
      
      private function _countEffects(param1:Vector.<IEffect>, param2:int) : int
      {
         var _loc4_:Effect = null;
         var _loc3_:int = 0;
         for each(_loc4_ in param1)
         {
            if(!(Boolean(this.effectId) && this.effectId != _loc4_.def.name))
            {
               if(!(Boolean(this.abilityId) && this.abilityId != _loc4_.ability.def.id))
               {
                  _loc3_++;
                  if(_loc3_ >= param2)
                  {
                     break;
                  }
               }
            }
         }
         return _loc3_;
      }
   }
}

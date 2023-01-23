package engine.battle.board.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.PersistedEffects;
   import engine.core.logging.ILogger;
   
   public class PersistedRules
   {
      
      public static const schema:Object = {
         "name":"BattleObjective_AbilityEvent_PersistedRules",
         "type":"object",
         "properties":{"any":{
            "type":"array",
            "items":PersistedRule.schema,
            "optional":true
         }}
      };
       
      
      public var all:Vector.<PersistedRule>;
      
      public var any:Vector.<PersistedRule>;
      
      public var none:Vector.<PersistedRule>;
      
      public function PersistedRules()
      {
         super();
      }
      
      protected static function captureRules(param1:Array, param2:ILogger) : Vector.<PersistedRule>
      {
         var _loc4_:Object = null;
         var _loc5_:PersistedRule = null;
         if(!param1 || !param1.length)
         {
            return null;
         }
         var _loc3_:Vector.<PersistedRule> = new Vector.<PersistedRule>();
         for each(_loc4_ in param1)
         {
            _loc5_ = new PersistedRule().fromJson(_loc4_,param2);
            _loc3_.push(_loc5_);
         }
         return _loc3_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : PersistedRules
      {
         this.all = captureRules(param1.all,param2);
         this.any = captureRules(param1.any,param2);
         this.none = captureRules(param1.none,param2);
         return this;
      }
      
      public function checkPersistedRules(param1:PersistedEffects) : Boolean
      {
         var _loc3_:PersistedRule = null;
         var _loc4_:Effect = null;
         var _loc2_:int = 0;
         if(Boolean(this.all) && Boolean(this.all.length))
         {
            for each(_loc3_ in this.all)
            {
               if(!_loc3_.checkPersistedRule(param1))
               {
                  return false;
               }
            }
         }
         if(Boolean(this.any) && Boolean(this.any.length))
         {
            for each(_loc3_ in this.any)
            {
               if(_loc3_.checkPersistedRule(param1))
               {
                  _loc2_++;
                  break;
               }
            }
            if(_loc2_ <= 0)
            {
               return false;
            }
         }
         if(this.none)
         {
            for each(_loc3_ in this.none)
            {
               if(_loc3_.checkPersistedRule(param1))
               {
                  return false;
               }
            }
         }
         return true;
      }
   }
}

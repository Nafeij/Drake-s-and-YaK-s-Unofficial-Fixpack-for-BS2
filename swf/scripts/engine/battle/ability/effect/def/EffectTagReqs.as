package engine.battle.ability.effect.def
{
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.model.IEffectTagProvider;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   
   public class EffectTagReqs
   {
      
      public static const empty:EffectTagReqs = new EffectTagReqs();
       
      
      public var all:Vector.<EffectTag>;
      
      public var any:Vector.<EffectTag>;
      
      public var none:Vector.<EffectTag>;
      
      public function EffectTagReqs()
      {
         super();
      }
      
      protected static function captureTagSet(param1:Array) : Vector.<EffectTag>
      {
         var _loc3_:String = null;
         var _loc4_:EffectTag = null;
         var _loc2_:Vector.<EffectTag> = new Vector.<EffectTag>();
         for each(_loc3_ in param1)
         {
            _loc4_ = Enum.parse(EffectTag,_loc3_) as EffectTag;
            _loc2_.push(_loc4_);
         }
         return _loc2_;
      }
      
      public function get isEmpty() : Boolean
      {
         return (!this.all || !this.all.length) && (!this.any || !this.any.length) && (!this.none || !this.none.length);
      }
      
      public function toString() : String
      {
         var _loc2_:EffectTag = null;
         var _loc1_:* = "";
         if(this.all)
         {
            _loc1_ += "all=[";
            for each(_loc2_ in this.all)
            {
               _loc1_ += _loc2_.name + ",";
            }
            _loc1_ += "]";
         }
         if(this.any)
         {
            if(_loc1_)
            {
               _loc1_ += ", ";
            }
            _loc1_ += "any=[";
            for each(_loc2_ in this.any)
            {
               _loc1_ += _loc2_.name + ",";
            }
            _loc1_ += "]";
         }
         if(this.none)
         {
            if(_loc1_)
            {
               _loc1_ += ", ";
            }
            _loc1_ += "none=[";
            for each(_loc2_ in this.none)
            {
               _loc1_ += _loc2_.name + ",";
            }
            _loc1_ += "]";
         }
         return _loc1_;
      }
      
      public function checkTags(param1:IEffectTagProvider, param2:ILogger, param3:AbilityReason = null) : Boolean
      {
         var _loc6_:EffectTag = null;
         var _loc4_:int = 0;
         var _loc5_:EffectTag = null;
         if(!param1)
         {
            return false;
         }
         if(this.all)
         {
            for each(_loc6_ in this.all)
            {
               if(!param1.hasTag(_loc6_))
               {
                  AbilityReason.setMessage(param3,"no_tag_" + _loc6_);
                  return false;
               }
            }
         }
         if(this.any)
         {
            for each(_loc6_ in this.any)
            {
               _loc5_ = _loc6_;
               if(param1.hasTag(_loc6_))
               {
                  _loc4_++;
                  break;
               }
            }
         }
         if(Boolean(_loc5_) && _loc4_ <= 0)
         {
            AbilityReason.setMessage(param3,"no_tag_" + _loc5_);
            return false;
         }
         if(this.none)
         {
            for each(_loc6_ in this.none)
            {
               if(param1.hasTag(_loc6_))
               {
                  AbilityReason.setMessage(param3,"has_tag_" + _loc6_);
                  return false;
               }
            }
         }
         return true;
      }
   }
}

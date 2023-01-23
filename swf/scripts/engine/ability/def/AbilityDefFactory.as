package engine.ability.def
{
   import engine.core.logging.ILogger;
   import flash.utils.Dictionary;
   
   public class AbilityDefFactory implements IAbilityDefFactory
   {
       
      
      public var abilityDefList:Vector.<AbilityDef>;
      
      public var abilityDefs:Dictionary;
      
      public var _logger:ILogger;
      
      public var errors:int;
      
      public var params:Dictionary;
      
      public function AbilityDefFactory()
      {
         this.abilityDefList = new Vector.<AbilityDef>();
         this.abilityDefs = new Dictionary();
         this.params = new Dictionary();
         super();
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      public function link() : void
      {
         var abld:AbilityDef = null;
         var i:int = 0;
         var abilityDef:AbilityDef = null;
         for each(abld in this.abilityDefs)
         {
            i = 0;
            while(i < abld.maxLevel)
            {
               abilityDef = abld.getAbilityDefForLevel(i + 1) as AbilityDef;
               try
               {
                  abilityDef.link(this);
               }
               catch(e:Error)
               {
                  _logger.error("Failed to link [" + abilityDef.id + "]:\n" + e.getStackTrace());
               }
               i++;
            }
         }
      }
      
      public function register(param1:AbilityDef) : void
      {
         if(this.abilityDefs[param1.id])
         {
            throw new ArgumentError("Already registered duplicate ability [" + param1 + "]");
         }
         this.abilityDefList.push(param1);
         this.abilityDefs[param1.id] = param1;
      }
      
      public function fetch(param1:String, param2:Boolean = true) : AbilityDef
      {
         var _loc3_:AbilityDef = this.abilityDefs[param1];
         if(!_loc3_)
         {
            if(param2)
            {
               throw new ArgumentError("invalid/unknown ability id [" + param1 + "]");
            }
         }
         return _loc3_;
      }
      
      public function getAbilityDefParam(param1:String, param2:int) : int
      {
         if(param1 in this.params)
         {
            return this.params[param1];
         }
         return param2;
      }
      
      public function updateAbilityDefDescriptions() : void
      {
         var _loc1_:AbilityDef = null;
         var _loc2_:int = 0;
         var _loc3_:AbilityDef = null;
         for each(_loc1_ in this.abilityDefs)
         {
            _loc1_.factory = this;
            _loc2_ = 1;
            while(_loc2_ <= _loc1_.maxLevel)
            {
               _loc3_ = _loc1_.getAbilityDefForLevel(_loc2_) as AbilityDef;
               _loc3_.factory = this;
               _loc3_.updateRankDescription(this._logger);
               _loc2_++;
            }
         }
      }
   }
}

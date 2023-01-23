package engine.battle.board.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.saga.vars.IVariableProvider;
   import engine.saga.vars.VariableKey;
   import engine.saga.vars.VariableKeyVars;
   import flash.utils.Dictionary;
   
   public class BattleBoardTipsDef
   {
      
      public static const schema:Object = {
         "name":"BattleBoardTipsDef",
         "type":"object",
         "properties":{
            "tips":{
               "type":"array",
               "items":BattleBoardTipDef.schema
            },
            "quicktips":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "randomVarPrefix":{"type":"string"},
            "randomTokenPrefix":{"type":"string"},
            "speakAnchor":{"type":"string"},
            "randomCount":{"type":"number"},
            "prereqs":{
               "type":"array",
               "items":VariableKeyVars.schema,
               "optional":true
            }
         }
      };
       
      
      public var tipsByAbilityId:Dictionary;
      
      public var tips:Vector.<BattleBoardTipDef>;
      
      public var randomVarPrefix:String;
      
      public var randomTokenPrefix:String;
      
      public var randomCount:int;
      
      public var speakAnchor:String;
      
      public var delayVarname:String = "trn_speak_delay";
      
      public var delayRandom:int = 2;
      
      public var prereqs:Vector.<VariableKey>;
      
      public function BattleBoardTipsDef()
      {
         this.tipsByAbilityId = new Dictionary();
         this.tips = new Vector.<BattleBoardTipDef>();
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleBoardTipsDef
      {
         var _loc3_:BattleBoardTipDef = null;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:VariableKey = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         if(param1.quicktips)
         {
            for each(_loc4_ in param1.quicktips)
            {
               _loc3_ = new BattleBoardTipDef().setupTip(_loc4_);
               _loc3_.quick = true;
               this.tips.push(_loc3_);
               this.tipsByAbilityId[_loc3_.abilityId] = _loc3_;
            }
         }
         for each(_loc6_ in param1.tips)
         {
            _loc3_ = new BattleBoardTipDef().fromJson(_loc6_,param2);
            this.tips.push(_loc3_);
            this.tipsByAbilityId[_loc3_.abilityId] = _loc3_;
         }
         this.randomTokenPrefix = param1.randomTokenPrefix;
         this.randomVarPrefix = param1.randomVarPrefix;
         this.randomCount = param1.randomCount;
         this.speakAnchor = param1.speakAnchor;
         if(param1.prereqs)
         {
            for each(_loc5_ in param1.prereqs)
            {
               if(!this.prereqs)
               {
                  this.prereqs = new Vector.<VariableKey>();
               }
               _loc7_ = new VariableKeyVars().fromJson(_loc5_,param2);
               this.prereqs.push(_loc7_);
            }
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc2_:Array = null;
         var _loc3_:BattleBoardTipDef = null;
         var _loc4_:VariableKey = null;
         var _loc1_:Object = {
            "tips":[],
            "randomVarPrefix":(!!this.randomVarPrefix ? this.randomVarPrefix : ""),
            "randomTokenPrefix":(!!this.randomTokenPrefix ? this.randomTokenPrefix : ""),
            "speakAnchor":(!!this.speakAnchor ? this.speakAnchor : ""),
            "randomCount":this.randomCount
         };
         for each(_loc3_ in this.tips)
         {
            if(!_loc3_.quick)
            {
               _loc1_.tips.push(_loc3_.toJson());
            }
            else
            {
               if(!_loc2_)
               {
                  _loc2_ = [];
               }
               _loc2_.push(_loc3_.abilityId);
            }
         }
         if(_loc2_)
         {
            _loc2_.sort();
            _loc1_.quicktips = _loc2_;
         }
         if(Boolean(this.prereqs) && this.prereqs.length > 0)
         {
            _loc1_.prereqs = [];
            for each(_loc4_ in this.prereqs)
            {
               _loc1_.prereqs.push(VariableKeyVars.save(_loc4_));
            }
         }
         return _loc1_;
      }
      
      public function checkPrereqs(param1:IVariableProvider, param2:Array) : Boolean
      {
         var _loc3_:VariableKey = null;
         if(!this.prereqs || this.prereqs.length == 0)
         {
            return true;
         }
         for each(_loc3_ in this.prereqs)
         {
            if(!_loc3_.check(param1))
            {
               if(Boolean(param2) && param2.length > 0)
               {
                  param2[0] = _loc3_.toString();
               }
               return false;
            }
         }
         return true;
      }
   }
}

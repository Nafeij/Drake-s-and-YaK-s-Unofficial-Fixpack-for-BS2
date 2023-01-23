package engine.battle.music
{
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class BattleMusicDef
   {
      
      public static const schema:Object = {
         "name":"BattleMusicDef",
         "properties":{
            "start":{"type":"string"},
            "killMusic":{
               "type":"boolean",
               "optional":true
            },
            "triggers":{
               "type":"array",
               "items":BattleMusicTriggerDef.schema
            },
            "states":{
               "type":"array",
               "items":BattleMusicStateDef.schema
            }
         }
      };
       
      
      private var _url:String;
      
      public var baseName:String;
      
      public var start:String;
      
      public var triggers:Vector.<BattleMusicTriggerDef>;
      
      public var states:Vector.<BattleMusicStateDef>;
      
      public var killMusic:Boolean = true;
      
      public function BattleMusicDef()
      {
         this.triggers = new Vector.<BattleMusicTriggerDef>();
         this.states = new Vector.<BattleMusicStateDef>();
         super();
      }
      
      public static function save(param1:BattleMusicDef) : Object
      {
         var _loc3_:BattleMusicTriggerDef = null;
         var _loc4_:BattleMusicStateDef = null;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         var _loc2_:Object = {
            "start":param1.start,
            "triggers":[],
            "states":[]
         };
         for each(_loc3_ in param1.triggers)
         {
            _loc5_ = BattleMusicTriggerDef.save(_loc3_);
            _loc2_.triggers.push(_loc5_);
         }
         for each(_loc4_ in param1.states)
         {
            _loc6_ = BattleMusicStateDef.save(_loc4_);
            _loc2_.states.push(_loc6_);
         }
         _loc2_.killMusic = param1.killMusic;
         return _loc2_;
      }
      
      public function cleanup() : void
      {
         this.triggers = null;
         this.states = null;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function set url(param1:String) : void
      {
         this._url = param1;
         this.baseName = StringUtil.getBasename(this._url);
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleMusicDef
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:BattleMusicTriggerDef = null;
         var _loc6_:BattleMusicStateDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.start = param1.start;
         for each(_loc3_ in param1.triggers)
         {
            _loc5_ = new BattleMusicTriggerDef().fromJson(_loc3_,param2);
            this.triggers.push(_loc5_);
         }
         for each(_loc4_ in param1.states)
         {
            _loc6_ = new BattleMusicStateDef().fromJson(_loc4_,param2);
            this.states.push(_loc6_);
         }
         this.killMusic = BooleanVars.parse(param1.killMusic,this.killMusic);
         return this;
      }
      
      public function getStateById(param1:String) : BattleMusicStateDef
      {
         var _loc2_:BattleMusicStateDef = null;
         for each(_loc2_ in this.states)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function findTraumaTrigger(param1:Number, param2:Number, param3:Boolean) : BattleMusicTriggerDef
      {
         var _loc4_:BattleMusicTriggerDef = null;
         for each(_loc4_ in this.triggers)
         {
            if(_loc4_.type == BattleMusicTriggerType.TRAUMA_UP)
            {
               if(param1 < _loc4_.trauma && param2 >= _loc4_.trauma)
               {
                  if(_loc4_.checkWinning(param3))
                  {
                     return _loc4_;
                  }
               }
            }
         }
         return null;
      }
      
      public function findTriggerByType(param1:BattleMusicTriggerType, param2:Boolean) : BattleMusicTriggerDef
      {
         var _loc3_:BattleMusicTriggerDef = null;
         for each(_loc3_ in this.triggers)
         {
            if(_loc3_.type == param1)
            {
               if(_loc3_.checkWinning(param2))
               {
                  return _loc3_;
               }
            }
         }
         return null;
      }
   }
}

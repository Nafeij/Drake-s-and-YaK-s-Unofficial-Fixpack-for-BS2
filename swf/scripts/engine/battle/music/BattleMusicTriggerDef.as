package engine.battle.music
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   
   public class BattleMusicTriggerDef
   {
      
      public static const schema:Object = {
         "name":"BattleMusicTriggerDef",
         "properties":{
            "target":{"type":"string"},
            "trauma":{
               "type":"number",
               "optional":true
            },
            "type":{"type":"string"},
            "winning":{
               "type":"number",
               "optional":true
            },
            "clobber":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public var target:String;
      
      public var trauma:Number = 0;
      
      public var type:BattleMusicTriggerType = null;
      
      public var clobber:Boolean;
      
      public var winning:int = 0;
      
      public function BattleMusicTriggerDef()
      {
         super();
      }
      
      public static function save(param1:BattleMusicTriggerDef) : Object
      {
         var _loc2_:Object = {
            "target":param1.target,
            "type":param1.type.name
         };
         if(param1.type == BattleMusicTriggerType.TRAUMA_UP)
         {
            _loc2_.trauma = param1.trauma;
         }
         if(param1.clobber)
         {
            _loc2_.clobber = param1.clobber;
         }
         if(param1.winning)
         {
            _loc2_.winning = param1.winning;
         }
         return _loc2_;
      }
      
      public function toString() : String
      {
         return "[" + this.target + "] " + this.type.name + ", tr=" + this.trauma.toFixed(0.2) + ", cl=" + this.clobber + ", w=" + this.winning;
      }
      
      public function checkWinning(param1:Boolean) : Boolean
      {
         if(this.winning > 0 && !param1)
         {
            return false;
         }
         if(this.winning < 0 && param1)
         {
            return false;
         }
         return true;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleMusicTriggerDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.target = param1.target;
         if(param1.trauma != undefined)
         {
            this.trauma = param1.trauma;
         }
         this.type = Enum.parse(BattleMusicTriggerType,param1.type) as BattleMusicTriggerType;
         if(param1.clobber != undefined)
         {
            this.clobber = param1.clobber;
         }
         else if(this.type == BattleMusicTriggerType.WIN || this.type == BattleMusicTriggerType.LOSE)
         {
            this.clobber = true;
         }
         if(this.type == BattleMusicTriggerType.WIN || this.type == BattleMusicTriggerType.LOSE)
         {
            this.winning = 0;
         }
         else if(param1.winning != undefined)
         {
            this.winning = param1.winning;
         }
         return this;
      }
   }
}

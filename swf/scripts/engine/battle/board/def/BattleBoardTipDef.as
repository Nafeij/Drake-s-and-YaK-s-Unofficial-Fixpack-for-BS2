package engine.battle.board.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class BattleBoardTipDef
   {
      
      public static const schema:Object = {
         "name":"BattleBoardTipDef",
         "type":"object",
         "properties":{
            "abilityId":{"type":"string"},
            "varname":{
               "type":"string",
               "optional":true
            },
            "token":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public var abilityId:String;
      
      public var playerOnly:Boolean = true;
      
      public var varname:String;
      
      public var token:String;
      
      public var quick:Boolean;
      
      public function BattleBoardTipDef()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleBoardTipDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.varname = param1.varname;
         this.token = param1.token;
         this.setupTip(param1.abilityId);
         return this;
      }
      
      public function setupTip(param1:String) : BattleBoardTipDef
      {
         this.abilityId = param1;
         if(!this.varname)
         {
            this.varname = "trn_tip_" + this.abilityId;
         }
         if(!this.token)
         {
            this.token = "$TUTORIAL:" + this.varname;
         }
         return this;
      }
      
      public function toJson() : Object
      {
         return {
            "abilityId":(!!this.abilityId ? this.abilityId : ""),
            "varname":(!!this.varname ? this.varname : ""),
            "token":(!!this.token ? this.token : "")
         };
      }
   }
}

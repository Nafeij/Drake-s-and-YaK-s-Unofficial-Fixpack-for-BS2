package engine.talent
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   import engine.stat.def.StatType;
   
   public class TalentRankDef
   {
      
      public static const schema:Object = {
         "name":"TalentRankDef",
         "properties":{
            "percent":{
               "type":"number",
               "optional":true
            },
            "value":{
               "type":"number",
               "optional":true
            },
            "affects":{
               "type":"string",
               "optional":true
            }
         }
      };
      
      public static var PERCENT_OVERRIDE:int = -1;
       
      
      public var percent:int;
      
      public var value:int;
      
      public var affectedStatType:StatType;
      
      public var talentDef:TalentDef;
      
      public var rank:int;
      
      public function TalentRankDef()
      {
         super();
      }
      
      public function fromJson(param1:TalentDef, param2:TalentRankDef, param3:Object, param4:ILogger) : TalentRankDef
      {
         EngineJsonDef.validateThrow(param3,schema,param4);
         this.talentDef = param1;
         if(param2)
         {
            this.affectedStatType = param2.affectedStatType;
            this.percent = param2.percent;
            this.value = param2.value;
            this.rank = param2.rank + 1;
         }
         if(!param3.affects)
         {
            if(!param2)
            {
               throw new ArgumentError("TalentRankDef affects required");
            }
         }
         else
         {
            this.affectedStatType = Enum.parse(StatType,param3.affects) as StatType;
         }
         if(param3.value == undefined)
         {
            if(!param2)
            {
               throw new ArgumentError("TalentRankDef value required");
            }
         }
         else
         {
            this.value = param3.value;
         }
         if(param3.percent == undefined)
         {
            if(!param2)
            {
               throw new ArgumentError("TalentRankDef percent required");
            }
         }
         else if(PERCENT_OVERRIDE >= 0)
         {
            this.percent = PERCENT_OVERRIDE;
         }
         else
         {
            this.percent = param3.percent;
         }
         return this;
      }
   }
}

package engine.talent
{
   import engine.core.locale.Locale;
   import engine.core.locale.LocaleCategory;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   import engine.stat.def.StatType;
   
   public class TalentDef
   {
      
      public static const schema:Object = {
         "name":"TalentDef",
         "properties":{
            "id":{"type":"string"},
            "stat":{"type":"string"},
            "ranks":{
               "type":"array",
               "items":TalentRankDef.schema
            }
         }
      };
       
      
      public var id:String;
      
      public var parentStatType:StatType;
      
      private var ranks:Vector.<TalentRankDef>;
      
      public var defs:TalentDefs;
      
      public function TalentDef(param1:TalentDefs)
      {
         this.ranks = new Vector.<TalentRankDef>();
         super();
         this.defs = param1;
         this.ranks.push(null);
      }
      
      public function get maxTotalRankIndex() : int
      {
         return this.ranks.length - 1;
      }
      
      public function get maxUpgradableRankIndex() : int
      {
         return Math.min(this.defs.maxAvailableRanks,this.ranks.length - 1);
      }
      
      public function getRank(param1:int) : TalentRankDef
      {
         return this.ranks[param1];
      }
      
      public function fromJson(param1:Object, param2:ILogger) : TalentDef
      {
         var _loc3_:Object = null;
         var _loc4_:TalentRankDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         this.parentStatType = Enum.parse(StatType,param1.stat) as StatType;
         for each(_loc3_ in param1.ranks)
         {
            _loc4_ = new TalentRankDef().fromJson(this,_loc4_,_loc3_,param2);
            this.ranks.push(_loc4_);
         }
         return this;
      }
      
      public function getLocalizedName(param1:Locale) : String
      {
         return param1.translate(LocaleCategory.TALENT,this.id + "_name");
      }
      
      public function getLocalizedDesc(param1:Locale) : String
      {
         return param1.translate(LocaleCategory.TALENT,this.id + "_desc");
      }
      
      public function getLocalizedRank(param1:Locale, param2:int) : String
      {
         return param1.translate(LocaleCategory.TALENT,this.id + "_rank_" + param2);
      }
      
      public function getIconPath() : String
      {
         return "common/character/talent/icon/" + this.id + ".png";
      }
   }
}

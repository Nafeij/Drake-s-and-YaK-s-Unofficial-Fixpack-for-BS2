package engine.battle.wave.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class LootTableEntryDef
   {
      
      public static const schema:Object = {
         "name":"LootTableEntryDef",
         "type":"object",
         "properties":{
            "randomItem":{
               "type":"boolean",
               "optional":true
            },
            "itemId":{
               "type":"string",
               "optional":true
            },
            "weight":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public var itemId:String;
      
      public var weight:int;
      
      public var randomItem:Boolean;
      
      public function LootTableEntryDef()
      {
         super();
         this.weight = 1;
      }
      
      public static function vctor() : Vector.<LootTableEntryDef>
      {
         return new Vector.<LootTableEntryDef>();
      }
      
      public function clone(param1:LootTableEntryDef) : LootTableEntryDef
      {
         if(!param1)
         {
            return null;
         }
         this.randomItem = param1.randomItem;
         this.itemId = param1.itemId;
         this.weight = param1.weight;
         return this;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : LootTableEntryDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         if(param1.itemId)
         {
            this.itemId = param1.itemId;
         }
         if(param1.weight)
         {
            this.weight = param1.weight;
         }
         if(param1.randomItem)
         {
            this.randomItem = param1.randomItem;
         }
         if(this.itemId == null)
         {
            this.randomItem = true;
         }
         if(this.weight < 0)
         {
            param2.error("ERROR: LootTableEntry configured with invalid weight!\nitemId: " + this.itemId + "\tweight: " + this.weight);
            this.weight = 1;
         }
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {};
         if(this.itemId)
         {
            _loc1_.itemId = this.itemId;
         }
         else
         {
            this.randomItem = true;
         }
         if(this.weight != 1 && Boolean(this.weight))
         {
            _loc1_.weight = this.weight;
         }
         if(this.randomItem)
         {
            _loc1_.randomItem = this.randomItem;
         }
         return _loc1_;
      }
   }
}

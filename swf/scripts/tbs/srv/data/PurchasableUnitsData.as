package tbs.srv.data
{
   import engine.core.logging.ILogger;
   
   public class PurchasableUnitsData
   {
      
      public static const schema:Object = {
         "name":"PurchasableUnitsData",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "units":{
               "type":"array",
               "items":PurchasableUnitData.schema
            },
            "class":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public var id:String;
      
      public var units:Vector.<PurchasableUnitData>;
      
      public function PurchasableUnitsData()
      {
         this.units = new Vector.<PurchasableUnitData>();
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         var _loc3_:Object = null;
         var _loc4_:PurchasableUnitData = null;
         this.id = param1.id;
         for each(_loc3_ in param1.units)
         {
            _loc4_ = new PurchasableUnitData();
            _loc4_.parseJson(_loc3_,param2);
            this.units.push(_loc4_);
         }
      }
   }
}

package game.cfg
{
   import engine.entity.def.IPurchasableUnit;
   import tbs.srv.data.PurchasableUnitData;
   import tbs.srv.data.PurchasableUnitsData;
   
   public class PurchasableUnits
   {
       
      
      private var config:GameConfig;
      
      public var units:Vector.<IPurchasableUnit>;
      
      public function PurchasableUnits(param1:GameConfig)
      {
         this.units = new Vector.<IPurchasableUnit>();
         super();
         this.config = param1;
      }
      
      public function getPurchasableUnit(param1:String) : IPurchasableUnit
      {
         var _loc2_:IPurchasableUnit = null;
         for each(_loc2_ in this.units)
         {
            if(_loc2_.def.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function update(param1:PurchasableUnitsData) : void
      {
         var _loc2_:PurchasableUnitData = null;
         var _loc3_:PurchasableUnit = null;
         this.units.splice(0,this.units.length);
         for each(_loc2_ in param1.units)
         {
            _loc3_ = new PurchasableUnit();
            _loc3_.parseData(_loc2_,this.config);
            if(!this.config.runMode.isClassAvailable(_loc3_.def.entityClass.id))
            {
               this.config.logger.info("PurchasableUnits SKIPPING " + _loc3_);
            }
            else
            {
               this.units.push(_loc3_);
            }
         }
      }
   }
}

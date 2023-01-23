package engine.saga.save
{
   import engine.core.logging.ILogger;
   import engine.entity.def.LegendSave;
   import engine.landscape.travel.def.TravelLocator;
   import engine.saga.Caravan;
   import engine.saga.vars.VariableBag;
   import flash.utils.Dictionary;
   
   public class CaravanSave
   {
       
      
      public var vars:Dictionary;
      
      public var name:String;
      
      public var legend:LegendSave;
      
      public var map_spline_id:String;
      
      public var map_spline_key:String;
      
      public var map_spline_t:Number = 0;
      
      public var leader:String;
      
      public var travel_locator:TravelLocator;
      
      public function CaravanSave()
      {
         super();
      }
      
      public function toString() : String
      {
         return this.name;
      }
      
      public function fromCaravan(param1:Caravan) : CaravanSave
      {
         this.name = param1.def.name;
         this.vars = param1.vars.toDictionary(param1.logger);
         this.map_spline_id = param1.map_spline_id;
         this.map_spline_key = param1.map_spline_key;
         this.map_spline_t = isNaN(param1.map_spline_t) ? 0 : param1.map_spline_t;
         this.leader = param1.leader;
         this.travel_locator = param1.travel_locator;
         this.legend = new LegendSave().fromLegend(param1._legend);
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {
            "name":(!!this.name ? this.name : ""),
            "legend":this.legend.toJson(),
            "leader":(!!this.leader ? this.leader : ""),
            "map_spline_id":(!!this.map_spline_id ? this.map_spline_id : ""),
            "map_spline_key":(!!this.map_spline_key ? this.map_spline_key : ""),
            "map_spline_t":(isNaN(this.map_spline_t) ? 0 : this.map_spline_t)
         };
         if(this.vars)
         {
            _loc1_.vars = VariableBag.toJsonFromDictionary(this.vars);
         }
         if(this.travel_locator)
         {
            _loc1_.travel_locator = this.travel_locator.toJson();
         }
         return _loc1_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : CaravanSave
      {
         this.name = param1.name;
         if(param1.vars)
         {
            this.vars = VariableBag.fromJsonToDictionary(param1.vars);
         }
         if(param1.travel_locator)
         {
            this.travel_locator = new TravelLocator().fromJson(param1.travel_locator);
         }
         this.legend = new LegendSave().fromJson(param1.legend,param2);
         this.map_spline_id = param1.map_spline_id;
         this.map_spline_key = param1.map_spline_key;
         this.map_spline_t = param1.map_spline_t;
         this.leader = param1.leader;
         return this;
      }
   }
}

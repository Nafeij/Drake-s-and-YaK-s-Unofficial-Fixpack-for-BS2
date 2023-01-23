package engine.landscape.travel.def
{
   import engine.landscape.travel.model.Travel_FallData;
   
   public class TravelLocator
   {
       
      
      public var travel_id:String;
      
      public var travel_location:String;
      
      public var travel_position:Number = -1;
      
      public var old_format:Boolean;
      
      public var fallData:Travel_FallData;
      
      public function TravelLocator()
      {
         super();
      }
      
      public function setup(param1:String, param2:String, param3:Number = -1) : TravelLocator
      {
         this.travel_id = param1;
         this.travel_location = param2;
         this.travel_position = param3;
         return this;
      }
      
      public function toString() : String
      {
         return "(" + this.travel_id + "," + this.travel_location + "," + this.travel_position + ")";
      }
      
      public function clone() : TravelLocator
      {
         return new TravelLocator().setup(this.travel_id,this.travel_location,this.travel_position);
      }
      
      public function reset() : void
      {
         this.travel_id = null;
         this.travel_location = null;
         this.travel_position = -1;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {};
         if(this.travel_id)
         {
            _loc1_.travel_id = this.travel_id;
         }
         if(this.travel_location)
         {
            _loc1_.travel_location = this.travel_location;
         }
         if(this.travel_position >= 0)
         {
            _loc1_.travel_position_str = this.travel_position.toFixed(4);
         }
         return _loc1_;
      }
      
      public function fromJson(param1:Object) : TravelLocator
      {
         this.travel_id = param1.travel_id;
         this.travel_location = param1.travel_location;
         if(param1.travel_position_str)
         {
            this.travel_position = param1.travel_position_str;
         }
         else if(param1.travel_position != undefined)
         {
            this.old_format = true;
            this.travel_position = param1.travel_position;
         }
         return this;
      }
   }
}

package engine.landscape.travel.def
{
   public interface ITravelDef
   {
       
      
      function getLocationDefs(param1:String, param2:Vector.<ITravelLocationDef>) : Vector.<ITravelLocationDef>;
      
      function get numTravelLocations() : int;
      
      function getTravelLocation(param1:int) : ITravelLocationDef;
      
      function getId() : String;
   }
}

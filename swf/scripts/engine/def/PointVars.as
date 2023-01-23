package engine.def
{
   import engine.core.logging.ILogger;
   import flash.geom.Point;
   
   public class PointVars
   {
      
      public static const schema:Object = {
         "name":"PointVars",
         "type":"object",
         "properties":{
            "x":{"type":"number"},
            "y":{"type":"number"}
         }
      };
       
      
      public function PointVars()
      {
         super();
      }
      
      public static function parse(param1:Object, param2:ILogger, param3:Point) : Point
      {
         if(!param1)
         {
            return param3;
         }
         EngineJsonDef.validateThrow(param1,schema,param2);
         if(!param3)
         {
            return new Point(param1.x,param1.y);
         }
         param3.setTo(param1.x,param1.y);
         return param3;
      }
      
      public static function parseString(param1:String, param2:Point) : Point
      {
         if(!param1)
         {
            return param2;
         }
         var _loc3_:int = param1.indexOf(" ");
         if(_loc3_ < 0)
         {
            throw new ArgumentError("invalid tile location string [" + param1 + "]");
         }
         var _loc4_:Number = Number(param1.substring(0,_loc3_));
         var _loc5_:Number = Number(param1.substring(_loc3_ + 1));
         if(!param2)
         {
            return new Point(_loc4_,_loc5_);
         }
         param2.setTo(_loc4_,_loc5_);
         return param2;
      }
      
      public static function saveString(param1:Point) : String
      {
         return param1.x.toString() + " " + param1.y.toString();
      }
      
      public static function save(param1:Point) : Object
      {
         return {
            "x":param1.x,
            "y":param1.y
         };
      }
   }
}

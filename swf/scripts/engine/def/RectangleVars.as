package engine.def
{
   import engine.core.logging.ILogger;
   import flash.geom.Rectangle;
   
   public class RectangleVars
   {
      
      public static const schema:Object = {
         "name":"Rectangle",
         "type":"object",
         "properties":{
            "x":{"type":"number"},
            "y":{"type":"number"},
            "width":{"type":"number"},
            "height":{"type":"number"}
         }
      };
       
      
      public function RectangleVars()
      {
         super();
      }
      
      public static function parse(param1:Object, param2:ILogger, param3:Rectangle) : Rectangle
      {
         if(!param1)
         {
            return param3;
         }
         EngineJsonDef.validateThrow(param1,schema,param2);
         if(!param3)
         {
            return new Rectangle(param1.x,param1.y,param1.width,param1.height);
         }
         param3.setTo(param1.x,param1.y,param1.width,param1.height);
         return param3;
      }
      
      public static function parseString(param1:String, param2:Rectangle, param3:ILogger) : Rectangle
      {
         if(!param1)
         {
            return param2;
         }
         var _loc4_:Array = param1.split(" ");
         if(_loc4_.length != 4)
         {
            throw new ArgumentError("invalid rect string [" + param1 + "]");
         }
         if(!param2)
         {
            param2 = new Rectangle();
         }
         param2.setTo(_loc4_[0],_loc4_[1],_loc4_[2],_loc4_[3]);
         return param2;
      }
      
      public static function save(param1:Rectangle) : Object
      {
         return {
            "x":param1.x,
            "y":param1.y,
            "width":param1.width,
            "height":param1.height
         };
      }
   }
}

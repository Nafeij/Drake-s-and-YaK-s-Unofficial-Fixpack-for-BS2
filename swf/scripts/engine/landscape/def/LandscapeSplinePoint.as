package engine.landscape.def
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class LandscapeSplinePoint extends EventDispatcher
   {
      
      public static const EVENT_ID:String = "LandscapeSplinePoint.EVENT_ID";
       
      
      public var pos:Point;
      
      public var zoom:Number = 1;
      
      internal var _id:String;
      
      public var keyIndex:int;
      
      public function LandscapeSplinePoint()
      {
         this.pos = new Point();
         super();
      }
      
      public static function ctor(param1:Number, param2:Number) : LandscapeSplinePoint
      {
         var _loc3_:LandscapeSplinePoint = new LandscapeSplinePoint();
         _loc3_.pos.setTo(param1,param2);
         return _loc3_;
      }
      
      internal function internalSetId(param1:String) : void
      {
         if(this._id == param1)
         {
            return;
         }
         this._id = param1;
         dispatchEvent(new Event(EVENT_ID));
      }
      
      public function get id() : String
      {
         return this._id;
      }
   }
}

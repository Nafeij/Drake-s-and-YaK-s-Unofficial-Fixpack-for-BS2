package engine.landscape.def
{
   import flash.errors.IllegalOperationError;
   import flash.geom.Rectangle;
   
   public class AnimPathNodeDef
   {
       
      
      public var continuous:Boolean = false;
      
      private var _startTimeSecs:Number = -1;
      
      protected var _durationSecs:Number = 0;
      
      public function AnimPathNodeDef()
      {
         super();
      }
      
      public static function constructBase(param1:AnimPathNodeDef, param2:Object) : void
      {
         if(param2.start_secs != undefined && !isNaN(param2.start_secs))
         {
            param1.startTimeSecs = param2.start_secs;
         }
         else
         {
            param1.startTimeSecs = -1;
         }
      }
      
      public function get labelString() : String
      {
         return "AnimPathNode";
      }
      
      public function clone() : AnimPathNodeDef
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      public function getBounds(param1:Rectangle) : Rectangle
      {
         return param1;
      }
      
      public function copyFromBase(param1:AnimPathNodeDef) : void
      {
         this.startTimeSecs = param1.startTimeSecs;
         this.durationSecs = param1.durationSecs;
      }
      
      public function get startTimeSecs() : Number
      {
         return this._startTimeSecs;
      }
      
      public function set startTimeSecs(param1:Number) : void
      {
         if(!isNaN(param1))
         {
            this._startTimeSecs = param1;
         }
      }
      
      public function get durationSecs() : Number
      {
         return this._durationSecs;
      }
      
      public function set durationSecs(param1:Number) : void
      {
         if(!isNaN(param1))
         {
            this._durationSecs = param1;
         }
      }
   }
}

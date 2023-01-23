package engine.landscape.travel.def
{
   import engine.landscape.def.LandscapeDef;
   import engine.math.MathUtil;
   import engine.scene.def.ISceneDef;
   
   public class TravelLocationDef implements ITravelLocationDef
   {
      
      public static var DECIMAL_PRECISION:int = 1;
       
      
      public var _id:String;
      
      public var _position:Number;
      
      public var mapx:Number;
      
      public var mapkey:Boolean;
      
      public var loadBarrier:Boolean;
      
      public var _travelDef:TravelDef;
      
      public function TravelLocationDef(param1:TravelDef)
      {
         super();
         this._travelDef = param1;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function toString() : String
      {
         return "Location " + this._id + " @" + this._position;
      }
      
      public function get position() : Number
      {
         return this._position;
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         this._position = MathUtil.stripDecimalPrecision(param1,DECIMAL_PRECISION);
         this.mapx = param2;
      }
      
      public function get travelDef() : ITravelDef
      {
         return this._travelDef;
      }
      
      public function get sceneDef() : ISceneDef
      {
         var _loc1_:LandscapeDef = !!this._travelDef ? this._travelDef.landscapeDef : null;
         return !!_loc1_ ? _loc1_.sceneDef : null;
      }
   }
}

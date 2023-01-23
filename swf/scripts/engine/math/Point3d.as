package engine.math
{
   public class Point3d
   {
       
      
      private var _x:Number;
      
      private var _y:Number;
      
      private var _z:Number;
      
      public function Point3d(param1:Number, param2:Number, param3:Number)
      {
         super();
         this._x = param1;
         this._y = param2;
         this._z = param3;
      }
      
      public function get z() : Number
      {
         return this._z;
      }
      
      public function get y() : Number
      {
         return this._y;
      }
      
      public function get x() : Number
      {
         return this._x;
      }
   }
}

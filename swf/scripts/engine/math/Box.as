package engine.math
{
   public class Box
   {
       
      
      private var _size:Point3d;
      
      private var _center:Point3d;
      
      public function Box(param1:Number, param2:Number, param3:Number)
      {
         super();
         this._size = new Point3d(param1,param2,param3);
         this._center = new Point3d(param1 / 2,param2 / 2,param3 / 2);
      }
      
      public function get size() : Point3d
      {
         return this._size;
      }
      
      public function get center() : Point3d
      {
         return this._center;
      }
      
      public function get height() : Number
      {
         return this._size.z;
      }
      
      public function get length() : Number
      {
         return this._size.y;
      }
      
      public function get width() : Number
      {
         return this._size.x;
      }
      
      public function get square() : Boolean
      {
         return this._size.x == this._size.y;
      }
   }
}

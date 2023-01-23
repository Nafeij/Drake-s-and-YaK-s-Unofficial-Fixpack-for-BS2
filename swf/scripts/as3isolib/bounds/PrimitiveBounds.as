package as3isolib.bounds
{
   import as3isolib.core.IIsoDisplayObject;
   import as3isolib.geom.Pt;
   
   public class PrimitiveBounds implements IBounds
   {
       
      
      private var _target:IIsoDisplayObject;
      
      public function PrimitiveBounds(param1:IIsoDisplayObject)
      {
         super();
         this._target = param1;
      }
      
      public function get volume() : Number
      {
         return this._target.width * this._target.length * this._target.height;
      }
      
      public function get width() : Number
      {
         return this._target.width;
      }
      
      public function get length() : Number
      {
         return this._target.length;
      }
      
      public function get height() : Number
      {
         return this._target.height;
      }
      
      public function get left() : Number
      {
         return this._target.x;
      }
      
      public function get right() : Number
      {
         return this._target.x + this._target.width;
      }
      
      public function get back() : Number
      {
         return this._target.y;
      }
      
      public function get front() : Number
      {
         return this._target.y + this._target.length;
      }
      
      public function get bottom() : Number
      {
         return this._target.z;
      }
      
      public function get top() : Number
      {
         return this._target.z + this._target.height;
      }
      
      public function get centerPt() : Pt
      {
         var _loc1_:Pt = null;
         _loc1_ = new Pt();
         _loc1_.x = this._target.x + this._target.width / 2;
         _loc1_.y = this._target.y + this._target.length / 2;
         _loc1_.z = this._target.z + this._target.height / 2;
         return _loc1_;
      }
      
      public function getPts() : Array
      {
         var _loc1_:Array = [];
         _loc1_.push(new Pt(this.left,this.back,this.bottom));
         _loc1_.push(new Pt(this.right,this.back,this.bottom));
         _loc1_.push(new Pt(this.right,this.front,this.bottom));
         _loc1_.push(new Pt(this.left,this.front,this.bottom));
         _loc1_.push(new Pt(this.left,this.back,this.top));
         _loc1_.push(new Pt(this.right,this.back,this.top));
         _loc1_.push(new Pt(this.right,this.front,this.top));
         _loc1_.push(new Pt(this.left,this.front,this.top));
         return _loc1_;
      }
      
      public function intersects(param1:IBounds) : Boolean
      {
         if(Math.abs(this.centerPt.x - param1.centerPt.x) <= this._target.width / 2 + param1.width / 2 && Math.abs(this.centerPt.y - param1.centerPt.y) <= this._target.length / 2 + param1.length / 2 && Math.abs(this.centerPt.z - param1.centerPt.z) <= this._target.height / 2 + param1.height / 2)
         {
            return true;
         }
         return false;
      }
      
      public function containsPt(param1:Pt) : Boolean
      {
         if(this.left <= param1.x && param1.x <= this.right && (this.back <= param1.y && param1.y <= this.front) && (this.bottom <= param1.z && param1.z <= this.top))
         {
            return true;
         }
         return false;
      }
   }
}

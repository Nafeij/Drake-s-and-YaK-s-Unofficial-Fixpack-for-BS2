package as3isolib.bounds
{
   import as3isolib.core.IIsoDisplayObject;
   import as3isolib.display.scene.IIsoScene;
   import as3isolib.geom.Pt;
   
   public class SceneBounds implements IBounds
   {
       
      
      private var _left:Number;
      
      private var _right:Number;
      
      private var _back:Number;
      
      private var _front:Number;
      
      private var _bottom:Number;
      
      private var _top:Number;
      
      private var _target:IIsoScene;
      
      public function SceneBounds(param1:IIsoScene)
      {
         super();
         this._target = param1;
         this.calculateBounds();
      }
      
      public function get volume() : Number
      {
         return this.width * this.length * this.height;
      }
      
      public function get width() : Number
      {
         return this._right - this._left;
      }
      
      public function get length() : Number
      {
         return this._front - this._back;
      }
      
      public function get height() : Number
      {
         return this._top - this._bottom;
      }
      
      public function get left() : Number
      {
         return this._left;
      }
      
      public function get right() : Number
      {
         return this._right;
      }
      
      public function get back() : Number
      {
         return this._back;
      }
      
      public function get front() : Number
      {
         return this._front;
      }
      
      public function get bottom() : Number
      {
         return this._bottom;
      }
      
      public function get top() : Number
      {
         return this._top;
      }
      
      public function get centerPt() : Pt
      {
         var _loc1_:Pt = null;
         _loc1_ = new Pt();
         _loc1_.x = (this._right - this._left) / 2;
         _loc1_.y = (this._front - this._back) / 2;
         _loc1_.z = (this._top - this._bottom) / 2;
         return _loc1_;
      }
      
      public function getPts() : Array
      {
         var _loc1_:Array = [];
         _loc1_.push(new Pt(this._left,this._back,this._bottom));
         _loc1_.push(new Pt(this._right,this._back,this._bottom));
         _loc1_.push(new Pt(this._right,this._front,this._bottom));
         _loc1_.push(new Pt(this._left,this._front,this._bottom));
         _loc1_.push(new Pt(this._left,this._back,this._top));
         _loc1_.push(new Pt(this._right,this._back,this._top));
         _loc1_.push(new Pt(this._right,this._front,this._top));
         _loc1_.push(new Pt(this._left,this._front,this._top));
         return _loc1_;
      }
      
      public function intersects(param1:IBounds) : Boolean
      {
         return false;
      }
      
      public function containsPt(param1:Pt) : Boolean
      {
         if(this._left <= param1.x && param1.x <= this._right && (this._back <= param1.y && param1.y <= this._front) && (this._bottom <= param1.z && param1.z <= this._top))
         {
            return true;
         }
         return false;
      }
      
      private function calculateBounds() : void
      {
         var _loc1_:IIsoDisplayObject = null;
         for each(_loc1_ in this._target.displayListChildren)
         {
            if(isNaN(this._left) || _loc1_.isoBounds.left < this._left)
            {
               this._left = _loc1_.isoBounds.left;
            }
            if(isNaN(this._right) || _loc1_.isoBounds.right > this._right)
            {
               this._right = _loc1_.isoBounds.right;
            }
            if(isNaN(this._back) || _loc1_.isoBounds.back < this._back)
            {
               this._back = _loc1_.isoBounds.back;
            }
            if(isNaN(this._front) || _loc1_.isoBounds.front > this._front)
            {
               this._front = _loc1_.isoBounds.front;
            }
            if(isNaN(this._bottom) || _loc1_.isoBounds.bottom < this._bottom)
            {
               this._bottom = _loc1_.isoBounds.bottom;
            }
            if(isNaN(this._top) || _loc1_.isoBounds.top > this._top)
            {
               this._top = _loc1_.isoBounds.top;
            }
         }
         if(isNaN(this._left))
         {
            this._left = 0;
         }
         if(isNaN(this._right))
         {
            this._right = 0;
         }
         if(isNaN(this._back))
         {
            this._back = 0;
         }
         if(isNaN(this._front))
         {
            this._front = 0;
         }
         if(isNaN(this._bottom))
         {
            this._bottom = 0;
         }
         if(isNaN(this._top))
         {
            this._top = 0;
         }
      }
   }
}

package engine.landscape.view
{
   import flash.geom.Point;
   
   public class SimpleTooltipsLayerHandle
   {
       
      
      protected var _visible:Boolean;
      
      public var name:String;
      
      public var layer:SimpleTooltipsLayer;
      
      protected var _scaleX:Number = 1;
      
      private var _internalPos:Point;
      
      private var _groupPos:Point;
      
      public var _groupId:String;
      
      public function SimpleTooltipsLayerHandle(param1:String, param2:SimpleTooltipsLayer)
      {
         this._internalPos = new Point();
         this._groupPos = new Point();
         super();
         this.name = param1;
         this.layer = param2;
      }
      
      public function toString() : String
      {
         return this._groupId + "/" + this.name;
      }
      
      public function get groupId() : String
      {
         return this._groupId;
      }
      
      public function cleanup() : void
      {
      }
      
      final public function set visible(param1:Boolean) : void
      {
         if(this._visible == param1)
         {
            return;
         }
         this._visible = param1;
         this.handleVisible();
      }
      
      final public function set x(param1:Number) : void
      {
         if(this._internalPos.x == param1)
         {
            return;
         }
         this._internalPos.x = param1;
         this.handlePosition(this._internalPos.x + this._groupPos.x,this._internalPos.y + this._groupPos.y);
      }
      
      final public function set y(param1:Number) : void
      {
         if(this._internalPos.y == param1)
         {
            return;
         }
         this._internalPos.y = param1;
         this.handlePosition(this._internalPos.x + this._groupPos.x,this._internalPos.y + this._groupPos.y);
      }
      
      final public function set scaleX(param1:Number) : void
      {
         if(this._scaleX == param1)
         {
            return;
         }
         this._scaleX = param1;
         this.handleScale();
      }
      
      final public function get scaleX() : Number
      {
         return this._scaleX;
      }
      
      final public function get x() : Number
      {
         return this._internalPos.x;
      }
      
      final public function get y() : Number
      {
         return this._internalPos.y;
      }
      
      final public function setGroupPos(param1:Number, param2:Number) : void
      {
         if(this._groupPos.x == param1 && this._groupPos.y == param2)
         {
            return;
         }
         this._groupPos.setTo(param1,param2);
         this.handlePosition(this._internalPos.x + this._groupPos.x,this._internalPos.y + this._groupPos.y);
      }
      
      protected function handleVisible() : void
      {
      }
      
      protected function handleScale() : void
      {
      }
      
      protected function handlePosition(param1:Number, param2:Number) : void
      {
      }
   }
}

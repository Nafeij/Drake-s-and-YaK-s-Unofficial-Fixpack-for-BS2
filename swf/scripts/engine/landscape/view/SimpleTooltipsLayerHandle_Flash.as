package engine.landscape.view
{
   import engine.resource.BitmapResource;
   import flash.display.BitmapData;
   import flash.geom.Point;
   
   public class SimpleTooltipsLayerHandle_Flash extends SimpleTooltipsLayerHandle implements ISimpleTooltipsLayerHandle
   {
       
      
      public var bmpr:BitmapResource;
      
      public var bmpd:BitmapData;
      
      public var dow:DisplayObjectWrapperFlash;
      
      public var layer_flash:SimpleTooltipsLayer_Flash;
      
      private var _internalPos:Point;
      
      private var _groupPos:Point;
      
      public function SimpleTooltipsLayerHandle_Flash(param1:String, param2:SimpleTooltipsLayer, param3:BitmapResource, param4:BitmapData)
      {
         this._internalPos = new Point();
         this._groupPos = new Point();
         super(param1,param2);
         this.layer_flash = param2 as SimpleTooltipsLayer_Flash;
         this.bmpr = param3;
         this.bmpd = param4;
         if(param3)
         {
            param3.addReference();
            this.dow = param3.getWrapper() as DisplayObjectWrapperFlash;
            _groupId = param3.url;
         }
         else if(param4)
         {
            this.dow = this.layer_flash.dowg.createDisplayObjectWrapperForBitmapData(this,param4) as DisplayObjectWrapperFlash;
         }
         this.dow.name = param1;
         this.dow.visible = _visible;
      }
      
      override public function cleanup() : void
      {
         this.dow.cleanup();
         this.dow = null;
         if(this.bmpr)
         {
            this.bmpr.release();
            this.bmpr = null;
         }
         if(this.bmpd)
         {
            this.bmpd.dispose();
            this.bmpd = null;
         }
         super.cleanup();
      }
      
      public function remove() : void
      {
         this.dow.removeFromParent();
         this.cleanup();
      }
      
      public function get width() : Number
      {
         return this.dow.width;
      }
      
      override protected function handleVisible() : void
      {
         this.dow.visible = _visible;
      }
      
      override protected function handleScale() : void
      {
         this.dow.scaleX = this._scaleX;
      }
      
      override protected function handlePosition(param1:Number, param2:Number) : void
      {
         this.dow.x = param1;
         this.dow.y = param2;
      }
   }
}

package engine.landscape.view
{
   import engine.resource.BitmapResource;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.textures.Texture;
   import starling.utils.VertexData;
   
   public class SimpleTooltipsLayerHandle_Starling extends SimpleTooltipsLayerHandle implements ISimpleTooltipsLayerHandle
   {
       
      
      public var bmpr:BitmapResource;
      
      public var bmpd:BitmapData;
      
      public var dow:DisplayObjectWrapperStarling;
      
      public var layer_starling:SimpleTooltipsLayer_Starling;
      
      private var _internalPos:Point;
      
      private var _groupPos:Point;
      
      public var texture:Texture;
      
      public var quadIndex:int;
      
      public var qb:SimpleTooltipsQuadBatch;
      
      private var _quadRect:Rectangle;
      
      public function SimpleTooltipsLayerHandle_Starling(param1:String, param2:SimpleTooltipsLayer, param3:BitmapResource, param4:BitmapData)
      {
         this._internalPos = new Point();
         this._groupPos = new Point();
         this._quadRect = new Rectangle();
         super(param1,param2);
         this.layer_starling = param2 as SimpleTooltipsLayer_Starling;
         this.bmpr = param3;
         this.bmpd = param4;
         if(param3)
         {
            param3.addReference();
            this.texture = param3.getTexture();
            _groupId = param3.url;
         }
         else if(param4)
         {
            this.dow = this.layer_starling.dowg.createDisplayObjectWrapperForBitmapData(this,param4) as DisplayObjectWrapperStarling;
         }
         if(this.dow)
         {
            this.dow.name = param1;
            this.dow.visible = _visible;
         }
      }
      
      override public function toString() : String
      {
         return super.toString() + " qi=" + this.quadIndex + " tex=" + this.texture;
      }
      
      override public function cleanup() : void
      {
         this.texture = null;
         if(this.dow)
         {
            this.layer_starling.dowg.destroyBitmapDataWrapper(this.dow);
            this.dow.cleanup();
            this.dow = null;
         }
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
         this.qb = null;
         this.quadIndex = -1;
         layer = null;
         super.cleanup();
      }
      
      public function remove() : void
      {
         layer.forgetHandle(this);
         this.qb = null;
         this.quadIndex = -1;
         if(this.dow)
         {
            this.dow.removeFromParent();
         }
         this.cleanup();
      }
      
      public function get width() : Number
      {
         if(this.texture)
         {
            return this.texture.width;
         }
         if(this.dow)
         {
            return this.dow.width;
         }
         return 0;
      }
      
      override protected function handleVisible() : void
      {
         if(this.dow)
         {
            this.dow.visible = _visible;
         }
         if(this.qb)
         {
            this._applyVd();
         }
      }
      
      override protected function handleScale() : void
      {
         if(this.dow)
         {
            this.dow.scaleX = this._scaleX;
         }
      }
      
      override protected function handlePosition(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this.dow)
         {
            this.dow.x = param1;
            this.dow.y = param2;
         }
         if(Boolean(this.qb) && Boolean(this.texture))
         {
            _loc3_ = param1 + this.texture.width * _scaleX;
            _loc4_ = param2 + this.texture.height;
            this._quadRect.setTo(param1,param2,_loc3_ - param1,_loc4_ - param2);
            this._applyVd();
         }
      }
      
      public function updateVd() : void
      {
         var _loc1_:VertexData = this.layer_starling.vd;
         if(_visible)
         {
            _loc1_.setPosition(0,this._quadRect.x,this._quadRect.y);
            _loc1_.setPosition(1,this._quadRect.right,this._quadRect.y);
            _loc1_.setPosition(2,this._quadRect.x,this._quadRect.bottom);
            _loc1_.setPosition(3,this._quadRect.right,this._quadRect.bottom);
         }
         var _loc2_:Number = _visible ? 1 : 0;
         var _loc3_:Number = _visible ? 16777215 : 0;
         _loc1_.setColorAndAlpha(0,_loc3_,_loc2_);
         _loc1_.setColorAndAlpha(1,_loc3_,_loc2_);
         _loc1_.setColorAndAlpha(2,_loc3_,_loc2_);
         _loc1_.setColorAndAlpha(3,_loc3_,_loc2_);
      }
      
      private function _applyVd() : void
      {
         var _loc1_:VertexData = this.layer_starling.vd;
         this.updateVd();
         this.qb.updateQuadVerts(this.quadIndex,_loc1_);
         this.qb.notifyChange();
      }
   }
}

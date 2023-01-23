package engine.landscape.view
{
   import engine.core.logging.ILogger;
   import engine.resource.BitmapResource;
   import engine.scene.IDisplayObjectWrapperGenerator;
   import flash.display.BitmapData;
   import flash.utils.Dictionary;
   import starling.display.BlendMode;
   import starling.display.Sprite;
   import starling.textures.Texture;
   import starling.textures.TextureSmoothing;
   import starling.utils.VertexData;
   
   public class SimpleTooltipsLayer_Starling extends SimpleTooltipsLayer
   {
       
      
      public var dow:DisplayObjectWrapperStarling;
      
      public var dowg:IDisplayObjectWrapperGenerator;
      
      public var qrs_bmpd:Dictionary;
      
      public var qbs:Dictionary;
      
      public var qba:Array;
      
      public var vd:VertexData;
      
      public function SimpleTooltipsLayer_Starling(param1:IDisplayObjectWrapperGenerator, param2:ILogger)
      {
         this.qrs_bmpd = new Dictionary();
         this.qbs = new Dictionary();
         this.qba = [];
         this.vd = new VertexData(4);
         super(param2);
         this.dow = new DisplayObjectWrapperStarling(new Sprite());
         this.dowg = param1;
         this.vd.setTexCoords(0,0,0);
         this.vd.setTexCoords(1,1,0);
         this.vd.setTexCoords(2,0,1);
         this.vd.setTexCoords(3,1,1);
         this.vd.setColorAndAlpha(0,16777215,0);
         this.vd.setColorAndAlpha(1,16777215,0);
         this.vd.setColorAndAlpha(2,16777215,0);
         this.vd.setColorAndAlpha(3,16777215,0);
         this.vd.setPosition(0,20,0);
         this.vd.setPosition(1,180,0);
         this.vd.setPosition(2,0,200);
         this.vd.setPosition(3,200,180);
      }
      
      final override public function cleanup() : void
      {
         if(this.dow)
         {
            this.dow.cleanup();
            this.dow = null;
         }
      }
      
      private function findQuadBatch(param1:int, param2:Texture) : SimpleTooltipsQuadBatch
      {
         var _loc3_:SimpleTooltipsQuadBatch = this.qbs[param2];
         if(!_loc3_)
         {
            _loc3_ = new SimpleTooltipsQuadBatch(param1);
            this.qbs[param2] = _loc3_;
            this.qba.push(_loc3_);
            this.dow.doc.addChild(_loc3_);
         }
         return _loc3_;
      }
      
      final override public function addQuad_BitmapResource(param1:int, param2:String, param3:BitmapResource) : ISimpleTooltipsLayerHandle
      {
         if(!param3 || !param3.ok)
         {
            return null;
         }
         var _loc4_:SimpleTooltipsLayerHandle_Starling = new SimpleTooltipsLayerHandle_Starling(param2,this,param3,null);
         var _loc5_:SimpleTooltipsQuadBatch = this.findQuadBatch(param1,_loc4_.texture);
         _loc4_.quadIndex = _loc5_.numQuads;
         _loc4_.qb = _loc5_;
         _loc4_.updateVd();
         _loc5_.addVertexData(this.vd,1,_loc4_.texture,TextureSmoothing.BILINEAR,BlendMode.NORMAL);
         return _loc4_;
      }
      
      final override public function addQuad_BitmapData(param1:String, param2:BitmapData) : ISimpleTooltipsLayerHandle
      {
         if(!param2)
         {
            return null;
         }
         var _loc3_:SimpleTooltipsLayerHandle_Starling = new SimpleTooltipsLayerHandle_Starling(param1,this,null,param2);
         this.dow.addChild(_loc3_.dow);
         this.qrs_bmpd[_loc3_] = _loc3_;
         return _loc3_;
      }
      
      final override public function sort() : void
      {
         var _loc1_:SimpleTooltipsLayerHandle_Starling = null;
         var _loc2_:SimpleTooltipsQuadBatch = null;
         this.dow.removeAllChildren();
         this.qba.sortOn("depth");
         for each(_loc2_ in this.qba)
         {
            this.dow.doc.addChild(_loc2_);
         }
         for each(_loc1_ in this.qrs_bmpd)
         {
            this.dow.addChild(_loc1_.dow);
         }
      }
      
      final override public function forgetHandle(param1:ISimpleTooltipsLayerHandle) : void
      {
         var qi:int = 0;
         var qb:SimpleTooltipsQuadBatch = null;
         var qh:ISimpleTooltipsLayerHandle = param1;
         var qhs:SimpleTooltipsLayerHandle_Starling = qh as SimpleTooltipsLayerHandle_Starling;
         if(this.qrs_bmpd[qh])
         {
            delete this.qrs_bmpd[qh];
         }
         else
         {
            try
            {
               qi = qhs.quadIndex;
               qb = qhs.qb;
               qb.setQuadAlpha(qi,0);
            }
            catch(e:Error)
            {
               logger.error("Failed to forget handle [" + qh + "]:\n" + e.getStackTrace());
            }
         }
      }
   }
}

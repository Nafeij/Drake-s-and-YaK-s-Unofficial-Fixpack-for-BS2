package engine.landscape.view
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.resource.BitmapResource;
   import engine.scene.IDisplayObjectWrapperGenerator;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.utils.Dictionary;
   
   public class SimpleTooltipsLayer_Flash extends SimpleTooltipsLayer
   {
       
      
      public var dow:DisplayObjectWrapperFlash;
      
      public var dowg:IDisplayObjectWrapperGenerator;
      
      public var qrs_bmpr:Array;
      
      public var qrs_bmpd:Dictionary;
      
      public function SimpleTooltipsLayer_Flash(param1:IDisplayObjectWrapperGenerator, param2:ILogger)
      {
         this.qrs_bmpr = [];
         this.qrs_bmpd = new Dictionary();
         super(param2);
         this.dow = new DisplayObjectWrapperFlash(new Sprite());
         this.dowg = param1;
      }
      
      final override public function cleanup() : void
      {
         if(this.dow)
         {
            this.dow.cleanup();
            this.dow = null;
         }
      }
      
      final override public function addQuad_BitmapResource(param1:int, param2:String, param3:BitmapResource) : ISimpleTooltipsLayerHandle
      {
         if(!param3 || !param3.ok)
         {
            return null;
         }
         var _loc4_:SimpleTooltipsLayerHandle_Flash = new SimpleTooltipsLayerHandle_Flash(param2,this,param3,null);
         this.dow.addChild(_loc4_.dow);
         return _loc4_;
      }
      
      final override public function addQuad_BitmapData(param1:String, param2:BitmapData) : ISimpleTooltipsLayerHandle
      {
         if(!param2)
         {
            return null;
         }
         var _loc3_:SimpleTooltipsLayerHandle_Flash = new SimpleTooltipsLayerHandle_Flash(param1,this,null,param2);
         this.dow.addChild(_loc3_.dow);
         return _loc3_;
      }
      
      final override public function sort() : void
      {
         var _loc1_:SimpleTooltipsLayerHandle_Flash = null;
         this.dow.removeAllChildren();
         this.qrs_bmpr.sortOn("groupId");
         for each(_loc1_ in this.qrs_bmpr)
         {
            this.dow.addChild(_loc1_.dow);
         }
         for each(_loc1_ in this.qrs_bmpd)
         {
            this.dow.addChild(_loc1_.dow);
         }
      }
      
      final override public function forgetHandle(param1:ISimpleTooltipsLayerHandle) : void
      {
         var _loc3_:int = 0;
         var _loc2_:SimpleTooltipsLayerHandle_Flash = param1 as SimpleTooltipsLayerHandle_Flash;
         if(this.qrs_bmpd[param1])
         {
            delete this.qrs_bmpd[param1];
         }
         else
         {
            _loc3_ = this.qrs_bmpr.indexOf(param1);
            if(_loc3_ >= 0)
            {
               ArrayUtil.removeAt(this.qrs_bmpr,_loc3_);
            }
         }
      }
   }
}

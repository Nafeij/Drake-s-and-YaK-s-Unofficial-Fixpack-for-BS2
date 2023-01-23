package engine.landscape.def
{
   import flash.geom.Rectangle;
   
   public class LandscapeAnimPathDef
   {
       
      
      public var nodes:Vector.<AnimPathNodeDef>;
      
      public var looping:Boolean = true;
      
      public var autostart:Boolean = true;
      
      public var start_visible:Boolean = false;
      
      public var manage_visibility:Boolean = true;
      
      public var start_segment:int = 0;
      
      public var start_t:Number = 0;
      
      public var sprite:LandscapeSpriteDef;
      
      public function LandscapeAnimPathDef(param1:LandscapeSpriteDef)
      {
         this.nodes = new Vector.<AnimPathNodeDef>();
         super();
         this.sprite = param1;
      }
      
      public function promoteNode(param1:AnimPathNodeDef) : void
      {
         var _loc2_:int = this.nodes.indexOf(param1);
         if(_loc2_ > 0)
         {
            this.nodes.splice(_loc2_,1);
            this.nodes.splice(_loc2_ - 1,0,param1);
         }
      }
      
      public function demoteNode(param1:AnimPathNodeDef) : void
      {
         var _loc2_:int = this.nodes.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this.nodes.length - 1)
         {
            this.nodes.splice(_loc2_,1);
            this.nodes.splice(_loc2_ + 1,0,param1);
         }
      }
      
      public function removeNode(param1:AnimPathNodeDef) : void
      {
         var _loc2_:int = this.nodes.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.nodes.splice(_loc2_,1);
         }
      }
      
      public function clone(param1:LandscapeSpriteDef) : LandscapeAnimPathDef
      {
         var _loc3_:AnimPathNodeDef = null;
         var _loc2_:LandscapeAnimPathDef = new LandscapeAnimPathDef(param1);
         for each(_loc3_ in this.nodes)
         {
            _loc2_.nodes.push(_loc3_.clone());
         }
         _loc2_.looping = this.looping;
         _loc2_.autostart = this.autostart;
         _loc2_.manage_visibility = this.manage_visibility;
         _loc2_.start_visible = this.start_visible;
         return _loc2_;
      }
      
      public function getBounds() : Rectangle
      {
         var _loc1_:Rectangle = null;
         var _loc2_:AnimPathNodeDef = null;
         for each(_loc2_ in this.nodes)
         {
            _loc1_ = _loc2_.getBounds(_loc1_);
         }
         return _loc1_;
      }
   }
}

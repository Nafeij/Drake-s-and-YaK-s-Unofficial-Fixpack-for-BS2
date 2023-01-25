package engine.vfx
{
   import engine.anim.def.IAnimFacing;
   import flash.utils.Dictionary;
   
   public class OrientedVfxDef
   {
       
      
      public var vfxByFacing:Dictionary;
      
      public var fallbackVfx:String;
      
      public var name:String;
      
      public var fallback:IAnimFacing;
      
      public function OrientedVfxDef()
      {
         this.vfxByFacing = new Dictionary();
         super();
      }
      
      public function addVfx(param1:IAnimFacing, param2:String) : void
      {
         this.vfxByFacing[param1] = param2;
      }
      
      public function setFallback(param1:IAnimFacing) : void
      {
         this.fallback = param1;
         this.fallbackVfx = this.vfxByFacing[param1];
      }
      
      public function getVfx(param1:IAnimFacing) : String
      {
         var _loc2_:String = String(this.vfxByFacing[param1]);
         if(_loc2_)
         {
            return _loc2_;
         }
         return this.fallbackVfx;
      }
   }
}

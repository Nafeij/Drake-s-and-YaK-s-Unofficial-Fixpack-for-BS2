package engine.anim.def
{
   import flash.utils.Dictionary;
   
   public class OrientedAnimsDef
   {
       
      
      public var animsByFacing:Dictionary;
      
      public var fallbackAnim:String;
      
      public var name:String;
      
      public var fallback:IAnimFacing;
      
      public var flipsFacing:Boolean;
      
      public function OrientedAnimsDef()
      {
         this.animsByFacing = new Dictionary();
         super();
      }
      
      public function addAnim(param1:IAnimFacing, param2:String) : void
      {
         this.animsByFacing[param1] = param2;
      }
      
      public function setFallback(param1:IAnimFacing) : void
      {
         this.fallback = param1;
         this.fallbackAnim = this.animsByFacing[param1];
      }
      
      public function getAnim(param1:IAnimFacing) : String
      {
         var _loc2_:String = this.animsByFacing[param1];
         if(_loc2_)
         {
            return _loc2_;
         }
         return this.fallbackAnim;
      }
   }
}

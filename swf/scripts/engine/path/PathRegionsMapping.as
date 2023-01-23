package engine.path
{
   import flash.utils.Dictionary;
   
   public class PathRegionsMapping
   {
       
      
      public var region2regions:Dictionary;
      
      public function PathRegionsMapping()
      {
         this.region2regions = new Dictionary();
         super();
      }
      
      public function canLink(param1:int, param2:int) : Boolean
      {
         if(param1 == param2)
         {
            return true;
         }
         var _loc3_:Dictionary = this.region2regions[param1];
         return Boolean(_loc3_) && Boolean(_loc3_[param2]);
      }
      
      public function addLink(param1:int, param2:int) : void
      {
         if(param1 == param2)
         {
            return;
         }
         var _loc3_:Dictionary = this.region2regions[param1];
         if(!_loc3_)
         {
            _loc3_ = new Dictionary();
            this.region2regions[param1] = _loc3_;
         }
         _loc3_[param2] = true;
      }
   }
}

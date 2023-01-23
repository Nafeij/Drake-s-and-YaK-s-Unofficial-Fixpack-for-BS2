package engine.saga
{
   public class SagaBannerDef
   {
       
      
      public var lengths_world:Vector.<SagaBannerLengthDef>;
      
      public var lengths_close:Vector.<SagaBannerLengthDef>;
      
      public var hud_name:String;
      
      public function SagaBannerDef()
      {
         this.lengths_world = new Vector.<SagaBannerLengthDef>();
         this.lengths_close = new Vector.<SagaBannerLengthDef>();
         super();
      }
      
      public function getBannerLength(param1:Boolean, param2:int) : SagaBannerLengthDef
      {
         var _loc4_:SagaBannerLengthDef = null;
         var _loc3_:Vector.<SagaBannerLengthDef> = param1 ? this.lengths_close : this.lengths_world;
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.min_population <= param2)
            {
               return _loc4_;
            }
         }
         return !!_loc3_.length ? _loc3_[0] : null;
      }
   }
}

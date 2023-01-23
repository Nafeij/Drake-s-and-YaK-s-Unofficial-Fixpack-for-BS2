package engine.saga
{
   public final class SagaIap
   {
      
      private static var _impl:ISagaIap;
       
      
      public function SagaIap()
      {
         super();
      }
      
      public static function get impl() : ISagaIap
      {
         return _impl;
      }
      
      public static function set impl(param1:ISagaIap) : void
      {
         _impl = param1;
      }
      
      public static function setSaga(param1:Saga) : void
      {
         if(_impl)
         {
            _impl.setSaga(param1);
         }
      }
   }
}

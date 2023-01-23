package engine.landscape.def
{
   public class ClickMaskTestResult
   {
       
      
      public var nomask:Boolean;
      
      public var outside:Boolean;
      
      public var partial:Boolean;
      
      public var complete:Boolean;
      
      public function ClickMaskTestResult()
      {
         super();
      }
      
      public function reset() : void
      {
         this.nomask = false;
         this.outside = false;
         this.partial = false;
         this.complete = false;
      }
   }
}

package engine.core.render
{
   public class FitData
   {
       
      
      public var height:Number;
      
      public var width:Number;
      
      public var innerScale:Number;
      
      public var outerScale:Number = 1;
      
      public function FitData()
      {
         super();
      }
      
      public function toString() : String
      {
         return "w=" + this.width + " h=" + this.height + " is=" + this.innerScale + " os=" + this.outerScale;
      }
   }
}

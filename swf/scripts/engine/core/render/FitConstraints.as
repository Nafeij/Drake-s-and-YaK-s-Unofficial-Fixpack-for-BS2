package engine.core.render
{
   public class FitConstraints
   {
       
      
      public var minWidth:Number = 0;
      
      public var maxWidth:Number = 1.7976931348623157e+308;
      
      public var minHeight:Number = 0;
      
      public var maxHeight:Number = 1.7976931348623157e+308;
      
      public var cinemascope:Boolean;
      
      public var width:Number = 0;
      
      public var height:Number = 0;
      
      public function FitConstraints()
      {
         super();
      }
      
      public function setupMax(param1:Number, param2:Number) : FitConstraints
      {
         this.maxWidth = param1;
         this.maxHeight = param2;
         return this;
      }
      
      public function setupMin(param1:Number, param2:Number) : FitConstraints
      {
         this.minWidth = param1;
         this.minHeight = param2;
         return this;
      }
      
      public function copyFrom(param1:FitConstraints) : FitConstraints
      {
         this.maxWidth = param1.maxWidth;
         this.maxHeight = param1.maxHeight;
         this.minWidth = param1.minWidth;
         this.minHeight = param1.minHeight;
         return this;
      }
   }
}

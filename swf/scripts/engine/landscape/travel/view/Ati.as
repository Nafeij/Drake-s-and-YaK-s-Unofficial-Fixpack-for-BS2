package engine.landscape.travel.view
{
   import engine.math.MathUtil;
   
   public class Ati
   {
       
      
      public var type:CaravanViewTypeInfo;
      
      public var index:int;
      
      public function Ati(param1:CaravanViewTypeInfo)
      {
         super();
         this.type = param1;
         if(param1.rands > 0)
         {
            this.index = MathUtil.randomInt(1,param1.rands);
         }
      }
   }
}

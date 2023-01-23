package engine.expression.exp.operator
{
   import flash.errors.IllegalOperationError;
   
   public class OperatorUnary extends Operator
   {
      
      public static const NEGATE:OperatorUnary = new OperatorUnary("!");
      
      public static const MINUS:OperatorUnary = new OperatorUnary("-");
      
      public static const INV:OperatorUnary = new OperatorUnary("~");
      
      public static const order:Array = [[NEGATE,INV,MINUS]];
       
      
      public function OperatorUnary(param1:String)
      {
         super(param1);
      }
      
      public static function fetch(param1:String) : OperatorUnary
      {
         var _loc2_:Array = null;
         var _loc3_:OperatorUnary = null;
         for each(_loc2_ in order)
         {
            for each(_loc3_ in _loc2_)
            {
               if(param1 == _loc3_.str)
               {
                  return _loc3_;
               }
            }
         }
         return null;
      }
      
      public function evaluate(param1:Number) : Number
      {
         switch(this)
         {
            case NEGATE:
               return _b2n(!Boolean(param1));
            case INV:
               return ~param1;
            case MINUS:
               return -param1;
            default:
               throw new IllegalOperationError("Unsupported operator " + this);
         }
      }
   }
}

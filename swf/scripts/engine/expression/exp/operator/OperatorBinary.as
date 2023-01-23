package engine.expression.exp.operator
{
   import flash.errors.IllegalOperationError;
   
   public class OperatorBinary extends Operator
   {
      
      public static const LOR:OperatorBinary = new OperatorBinary("||");
      
      public static const LAND:OperatorBinary = new OperatorBinary("&&");
      
      public static const BIOR:OperatorBinary = new OperatorBinary("|");
      
      public static const BXOR:OperatorBinary = new OperatorBinary("^");
      
      public static const BAND:OperatorBinary = new OperatorBinary("&");
      
      public static const EQ1:OperatorBinary = new OperatorBinary("=");
      
      public static const EQ:OperatorBinary = new OperatorBinary("==");
      
      public static const NEQ:OperatorBinary = new OperatorBinary("!=");
      
      public static const LT:OperatorBinary = new OperatorBinary("<");
      
      public static const LTE:OperatorBinary = new OperatorBinary("<=");
      
      public static const GT:OperatorBinary = new OperatorBinary(">");
      
      public static const GTE:OperatorBinary = new OperatorBinary(">=");
      
      public static const BTL:OperatorBinary = new OperatorBinary("<<");
      
      public static const BTR:OperatorBinary = new OperatorBinary(">>");
      
      public static const ADD:OperatorBinary = new OperatorBinary("+");
      
      public static const SUB:OperatorBinary = new OperatorBinary("-");
      
      public static const MUL:OperatorBinary = new OperatorBinary("*");
      
      public static const DIV:OperatorBinary = new OperatorBinary("/");
      
      public static const MOD:OperatorBinary = new OperatorBinary("%");
      
      public static const order:Array = [LOR,LAND,BIOR,BXOR,BAND,EQ,NEQ,LT,LTE,GT,GTE,EQ1,BTL,BTR,ADD,SUB,MUL,DIV,MOD];
       
      
      public function OperatorBinary(param1:String)
      {
         super(param1);
      }
      
      public static function fetch(param1:String) : OperatorBinary
      {
         var _loc2_:OperatorBinary = null;
         for each(_loc2_ in order)
         {
            if(param1 == _loc2_.str)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function evaluate(param1:Number, param2:Number) : Number
      {
         switch(this)
         {
            case LOR:
               return param1 || param2;
            case LAND:
               return param1 && param2;
            case BIOR:
               return param1 | param2;
            case BXOR:
               return param1 ^ param2;
            case BAND:
               return param1 & param2;
            case EQ:
            case EQ1:
               return _b2n(param1 == param2);
            case NEQ:
               return _b2n(param1 != param2);
            case LT:
               return _b2n(param1 < param2);
            case LTE:
               return _b2n(param1 <= param2);
            case GT:
               return _b2n(param1 > param2);
            case GTE:
               return _b2n(param1 >= param2);
            case BTL:
               return param1 << param2;
            case BTR:
               return param1 >> param2;
            case ADD:
               return param1 + param2;
            case SUB:
               return param1 - param2;
            case MUL:
               return param1 * param2;
            case DIV:
               return param1 / param2;
            case MOD:
               return param1 % param2;
            default:
               throw new IllegalOperationError("Unsupported operator " + this);
         }
      }
   }
}

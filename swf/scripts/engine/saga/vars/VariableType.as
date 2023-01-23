package engine.saga.vars
{
   import engine.core.util.Enum;
   import flash.utils.getQualifiedClassName;
   
   public class VariableType extends Enum
   {
      
      public static const INTEGER:VariableType = new VariableType("INTEGER",enumCtorKey);
      
      public static const DECIMAL:VariableType = new VariableType("DECIMAL",enumCtorKey);
      
      public static const BOOLEAN:VariableType = new VariableType("BOOLEAN",enumCtorKey);
      
      public static const STRING:VariableType = new VariableType("STRING",enumCtorKey);
       
      
      public function VariableType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
      
      public static function findType(param1:*) : VariableType
      {
         if(param1 == null || param1 == undefined)
         {
            throw new ArgumentError("don\'t pass me a null value");
         }
         if(param1 is String)
         {
            return STRING;
         }
         if(param1 is Boolean)
         {
            return BOOLEAN;
         }
         if(param1 is int)
         {
            return INTEGER;
         }
         if(param1 is Number)
         {
            return DECIMAL;
         }
         throw new ArgumentError("Invalid type [" + param1 + "] " + getQualifiedClassName(param1));
      }
   }
}

package engine.core.analytic
{
   import engine.core.util.Enum;
   
   public class GaOptState extends Enum
   {
      
      public static const NA:GaOptState = new GaOptState("NA");
      
      public static const QUERY:GaOptState = new GaOptState("QUERY");
      
      public static const IN:GaOptState = new GaOptState("IN");
      
      public static const OUT:GaOptState = new GaOptState("OUT");
       
      
      public function GaOptState(param1:String)
      {
         super(param1,enumCtorKey);
      }
      
      public static function optStateFromString(param1:String) : GaOptState
      {
         return Enum.parse(GaOptState,param1,false) as GaOptState;
      }
      
      public function get isSendOk() : Boolean
      {
         return this == NA || this == IN;
      }
      
      public function get isDefer() : Boolean
      {
         return this == QUERY;
      }
      
      public function get isNa() : Boolean
      {
         return this == NA;
      }
   }
}

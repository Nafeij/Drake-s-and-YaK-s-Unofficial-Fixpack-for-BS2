package engine.saga
{
   public class SagaSurvivalDef_Leaderboard
   {
       
      
      public var name:String;
      
      public var accum:Boolean;
      
      public var varname:String;
      
      public function SagaSurvivalDef_Leaderboard()
      {
         super();
      }
      
      public function toString() : String
      {
         return "[lbname=" + this.name + " varname=" + this.varname + " accum=" + this.accum + "]";
      }
      
      public function fromJson(param1:Object) : SagaSurvivalDef_Leaderboard
      {
         this.name = param1.name;
         this.accum = param1.accum;
         this.varname = param1.varname;
         return this;
      }
   }
}

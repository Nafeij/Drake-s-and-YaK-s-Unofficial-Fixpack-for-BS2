package engine.saga
{
   public class SagaDlcVariableData
   {
       
      
      public var varname:String;
      
      public var varvalue:Number;
      
      public function SagaDlcVariableData()
      {
         super();
      }
      
      public function applyVariable(param1:Saga) : void
      {
         param1.setVar(this.varname,this.varvalue);
      }
   }
}

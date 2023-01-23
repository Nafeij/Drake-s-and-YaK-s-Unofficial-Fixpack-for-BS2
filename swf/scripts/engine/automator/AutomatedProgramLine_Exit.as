package engine.automator
{
   public class AutomatedProgramLine_Exit extends AutomatedProgramLine
   {
       
      
      public function AutomatedProgramLine_Exit(param1:AutomatedProgram, param2:int, param3:String, param4:Array)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function handleExecuted() : void
      {
         context.exit(true);
      }
   }
}

package engine.automator
{
   public class AutomatedProgramLine_FastForward extends AutomatedProgramLine
   {
       
      
      public var until:String;
      
      public function AutomatedProgramLine_FastForward(param1:AutomatedProgram, param2:int, param3:String, param4:Array)
      {
         super(param1,param2,param3,param4);
         if(param4.length > 1)
         {
            this.until = param4[1];
         }
      }
      
      override protected function handleExecuted() : void
      {
         context.fastForward.performFastForward();
         if(!this.until)
         {
            if(!finished)
            {
               finish();
            }
            return;
         }
         reexecute = true;
      }
      
      override public function consumeNotification(param1:String) : Boolean
      {
         if(param1 == this.until)
         {
            if(!finished)
            {
               finish();
            }
            return true;
         }
         return false;
      }
   }
}

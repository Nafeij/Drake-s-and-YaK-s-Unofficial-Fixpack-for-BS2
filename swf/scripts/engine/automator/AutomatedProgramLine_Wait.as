package engine.automator
{
   public class AutomatedProgramLine_Wait extends AutomatedProgramLine
   {
       
      
      public var what:String;
      
      public function AutomatedProgramLine_Wait(param1:AutomatedProgram, param2:int, param3:String, param4:Array)
      {
         super(param1,param2,param3,param4);
         this.what = param4[1];
      }
      
      override public function consumeNotification(param1:String) : Boolean
      {
         if(this.what == this.what)
         {
            finish();
            return true;
         }
         return false;
      }
   }
}

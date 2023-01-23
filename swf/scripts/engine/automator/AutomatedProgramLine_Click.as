package engine.automator
{
   public class AutomatedProgramLine_Click extends AutomatedProgramLine
   {
       
      
      public var id:String;
      
      public var prohibited:Boolean;
      
      public function AutomatedProgramLine_Click(param1:AutomatedProgram, param2:int, param3:String, param4:Array)
      {
         super(param1,param2,param3,param4);
         this.id = param4[1];
         param4.shift();
         param4.shift();
         if(param4.indexOf("prohibited") >= 0)
         {
            this.prohibited = true;
         }
      }
      
      override protected function handleExecuted() : void
      {
         var _loc1_:Boolean = program.context.clicker.performClick(this.id);
         if(_loc1_ && this.prohibited)
         {
            throw new AutomatedProgramError("clicked on prohibited [" + this.id + "]");
         }
         if(!_loc1_ && !this.prohibited)
         {
            throw new AutomatedProgramError("unable to click on [" + this.id + "]");
         }
         finish();
      }
   }
}

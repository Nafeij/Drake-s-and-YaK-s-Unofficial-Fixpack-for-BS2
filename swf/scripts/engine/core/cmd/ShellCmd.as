package engine.core.cmd
{
   public class ShellCmd extends Cmd
   {
       
      
      public var isAlias:Boolean;
      
      public function ShellCmd(param1:String, param2:Function, param3:* = null, param4:Boolean = false, param5:Boolean = true)
      {
         super(param1,param2,param3,param4,param5);
      }
      
      public function setShellCheat() : void
      {
         cheat = true;
      }
   }
}

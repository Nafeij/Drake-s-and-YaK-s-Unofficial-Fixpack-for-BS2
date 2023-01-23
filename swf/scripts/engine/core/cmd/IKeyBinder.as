package engine.core.cmd
{
   public interface IKeyBinder
   {
       
      
      function performKeyDown(param1:Boolean, param2:Boolean, param3:Boolean, param4:uint) : Cmd;
      
      function performKeyUp(param1:uint) : Cmd;
      
      function bind(param1:Boolean, param2:Boolean, param3:Boolean, param4:uint, param5:Cmd, param6:String, param7:Cmd = null) : void;
      
      function bindUp(param1:uint, param2:Cmd, param3:String) : void;
      
      function unbind(param1:Cmd) : void;
   }
}

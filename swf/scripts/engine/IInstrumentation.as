package engine
{
   public interface IInstrumentation
   {
       
      
      function instrument(param1:String, param2:* = undefined) : void;
      
      function get isInstrumented() : Boolean;
      
      function set isInstrumented(param1:Boolean) : void;
   }
}

package engine.anim.view
{
   public interface IAnimControllerListener
   {
       
      
      function animControllerHandler_current(param1:AnimController) : void;
      
      function animControllerHandler_event(param1:AnimController, param2:String, param3:String) : void;
      
      function animControllerHandler_loco(param1:AnimController, param2:String) : void;
   }
}

package engine.session
{
   public interface IAuthentication
   {
       
      
      function requestAuthSessionTicket(param1:Function) : String;
      
      function getUserID() : String;
      
      function getAccountID(param1:String) : int;
      
      function getDisplayName() : String;
      
      function getUserLanguage() : String;
      
      function get enabled() : Boolean;
      
      function get initialized() : Boolean;
   }
}

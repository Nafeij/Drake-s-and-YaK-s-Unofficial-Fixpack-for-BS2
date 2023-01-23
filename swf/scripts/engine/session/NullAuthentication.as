package engine.session
{
   public final class NullAuthentication implements IAuthentication
   {
       
      
      public function NullAuthentication()
      {
         super();
      }
      
      public function requestAuthSessionTicket(param1:Function) : String
      {
         return null;
      }
      
      public function getUserID() : String
      {
         return null;
      }
      
      public function getAccountID(param1:String) : int
      {
         return 0;
      }
      
      public function getDisplayName() : String
      {
         return "unknown user";
      }
      
      public function getUserLanguage() : String
      {
         return null;
      }
      
      public function get enabled() : Boolean
      {
         return false;
      }
      
      public function get initialized() : Boolean
      {
         return true;
      }
   }
}

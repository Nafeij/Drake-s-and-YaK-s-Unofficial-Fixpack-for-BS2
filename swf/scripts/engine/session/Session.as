package engine.session
{
   import engine.core.http.HttpCommunicator;
   
   public class Session
   {
       
      
      public var communicator:HttpCommunicator;
      
      public var credentials:Credentials;
      
      public function Session(param1:HttpCommunicator, param2:Credentials)
      {
         super();
         this.communicator = param1;
         this.credentials = param2;
      }
   }
}

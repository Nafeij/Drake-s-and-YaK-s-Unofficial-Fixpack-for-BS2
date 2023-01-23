package engine.user
{
   import flash.events.Event;
   
   public class UserEvent extends Event
   {
      
      public static const USER_CHANGED:String = "UserEvent.USER_CHANGED";
      
      public static const INITIAL_USER_ESTABLISHED:String = "UserEvent.INITIAL_USER_ESTABLISHED";
      
      public static const ACTIVE_USER_LOST:String = "UserEvent.ACTIVE_USER_LOST";
      
      public static const ACCOUNT_PICKER_OPENED:String = "UserEvent.ACCOUNT_PICKER_OPENED";
      
      public static const ACCOUNT_PICKER_CLOSED:String = "UserEvent.ACCOUNT_PICKER_CLOSED";
       
      
      public var userName:String;
      
      public var userSelected:Boolean;
      
      public function UserEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:String = null, param5:Boolean = false)
      {
         this.userName = param4;
         this.userSelected = param5;
         super(param1,param2,param3);
      }
   }
}

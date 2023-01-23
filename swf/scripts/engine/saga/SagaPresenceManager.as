package engine.saga
{
   public class SagaPresenceManager
   {
      
      public static const StateNone:String = "none";
      
      public static const StateInBattle:String = "presence_battle";
      
      public static const StateCamping:String = "presence_camping";
      
      public static const StateInConversation:String = "presence_conversation";
      
      public static const StateStartingGame:String = "presence_main_menu";
      
      public static const StateAtMarket:String = "presence_market";
      
      public static const StateDecision:String = "presence_poppening";
      
      public static const StateTraveling:String = "presence_traveling";
      
      private static var _impl:ISagaPresenceManager;
       
      
      public function SagaPresenceManager()
      {
         super();
      }
      
      public static function get impl() : ISagaPresenceManager
      {
         if(_impl == null)
         {
            throw new Error("SagaPresenceManager impl has not been set.");
         }
         return _impl;
      }
      
      public static function set impl(param1:ISagaPresenceManager) : void
      {
         SagaPresenceManager._impl = param1;
      }
      
      public static function setBaseState(param1:String) : void
      {
         if(_impl)
         {
            _impl.setBaseState(param1);
         }
      }
      
      public static function pushNewState(param1:String) : SagaPresenceState
      {
         if(_impl)
         {
            return _impl.pushNewState(param1);
         }
         return null;
      }
      
      public static function update(param1:Number) : void
      {
         if(_impl)
         {
            _impl.update(param1);
         }
      }
   }
}

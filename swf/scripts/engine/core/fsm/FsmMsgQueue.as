package engine.core.fsm
{
   public class FsmMsgQueue
   {
       
      
      private var fsm:Fsm;
      
      private var deferred:Vector.<Object>;
      
      public function FsmMsgQueue(param1:Fsm)
      {
         this.deferred = new Vector.<Object>();
         super();
         this.fsm = param1;
      }
      
      public function popMessages() : void
      {
         var _loc2_:Object = null;
         if(this.deferred.length == 0)
         {
            return;
         }
         var _loc1_:int = 0;
         while(_loc1_ < this.deferred.length)
         {
            _loc2_ = this.deferred[_loc1_];
            if(!this.fsm.handleOneMessage(_loc2_))
            {
               _loc1_++;
            }
            else
            {
               this.deferred.splice(_loc1_,1);
            }
         }
      }
      
      public function pushMessage(param1:Object) : Boolean
      {
         this.popMessages();
         if(!this.fsm.handleOneMessage(param1))
         {
            this.deferred.push(param1);
            return true;
         }
         return true;
      }
   }
}

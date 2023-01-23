package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_Decamp extends Action
   {
       
      
      private var decampingScene:String;
      
      private var decampedScene:Boolean;
      
      public function Action_Decamp(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.camped = false;
         if(def.restore_scene)
         {
            this.decampingScene = saga.campSceneStateRestore();
            if(!this.decampingScene)
            {
               saga.logger.info("   ‡‡‡ DECAMP NO-RESTORE " + this);
               this.decampedScene = true;
            }
            else if(curScene == this.decampingScene)
            {
               saga.logger.info("   ‡‡‡ DECAMP QUICK-RESTORED " + this + " scene " + this.decampingScene);
               this.decampedScene = true;
            }
            if(!this.decampedScene)
            {
               saga.logger.info("   ‡‡‡ DECAMP RESTORE-END-WAIT " + this + " for scene [" + this.decampingScene + "] in curScene [" + curScene + "]");
               return;
            }
         }
         end();
      }
      
      override protected function handleTriggerSceneLoaded(param1:String, param2:int) : void
      {
         super.handleTriggerSceneLoaded(param1,param2);
         if(param1 == this.decampingScene)
         {
            if(!this.decampedScene)
            {
               saga.logger.info("   ‡‡‡ DECAMP RESTORED " + this + " scene " + curScene);
               this.decampedScene = true;
               end();
            }
         }
      }
      
      override public function triggerSceneExit(param1:String, param2:int) : void
      {
         super.triggerSceneExit(param1,param2);
         if(param1 == this.decampingScene)
         {
            if(!this.decampedScene)
            {
               saga.logger.info("   ‡‡‡ DECAMP RESTORE INTERRUPTED " + this + " scene " + curScene + " by " + param1);
               this.decampedScene = true;
               end();
            }
         }
      }
   }
}

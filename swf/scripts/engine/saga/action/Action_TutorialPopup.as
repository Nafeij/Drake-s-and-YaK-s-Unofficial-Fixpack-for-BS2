package engine.saga.action
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.core.util.StringUtil;
   import engine.saga.Saga;
   
   public class Action_TutorialPopup extends Action
   {
       
      
      private var handle:int;
      
      private var attach:String;
      
      private var msg:String;
      
      private var offset:int;
      
      private var location:String;
      
      private var useArrow:Boolean;
      
      private var useButton:Boolean;
      
      private var adjust:int;
      
      public function Action_TutorialPopup(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleTriggerSceneLoaded(param1:String, param2:int) : void
      {
         if(def.instant)
         {
            return;
         }
         if(this.handle)
         {
            logger.info("Action_TutorialPopup.handleTriggerSceneLoaded removing old " + this.handle);
            saga.performTutorialRemove(this.handle);
         }
         this.handle = saga.performTutorialPopup(this.attach,this.msg,this.offset,this.location,this.useArrow,this.useButton,this.adjust,this.tutorialClosedHandler);
         logger.info("Action_TutorialPopup.handleTriggerSceneLoaded replacement " + this.handle);
      }
      
      override protected function handleStarted() : void
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:* = null;
         this.msg = def.msg;
         if(!this.msg)
         {
            throw new ArgumentError("No msg for " + this);
         }
         this.attach = def.anchor;
         this.offset = def.varvalue;
         this.location = def.location;
         var _loc1_:String = def.param;
         if(_loc1_)
         {
            _loc3_ = _loc1_.split(";");
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = _loc4_.split("=");
               _loc6_ = _loc5_[0];
               _loc7_ = _loc5_.length > 1 ? _loc5_[1] : null;
               switch(_loc6_)
               {
                  case "arrow":
                     this.useArrow = true;
                     break;
                  case "button":
                     this.useButton = true;
                     break;
                  case "adjust":
                     this.adjust = int(_loc7_);
                     break;
                  case "offset":
                     this.offset = int(_loc7_);
                     break;
               }
            }
         }
         if(StringUtil.startsWith(this.msg,"$"))
         {
            _loc4_ = this.msg.substr(1);
            this.msg = null;
            if(PlatformInput.lastInputGp)
            {
               _loc8_ = _loc4_ + "_gp";
               this.msg = saga.locale.translateEncodedToken(_loc8_,true);
            }
            if(!this.msg)
            {
               this.msg = saga.locale.translateEncodedToken(_loc4_,false);
            }
         }
         this.msg = saga.performStringReplacement_SagaVar(this.msg);
         var _loc2_:Function = def.instant ? null : this.tutorialClosedHandler;
         saga.performTutorialRemoveAll(this.toString());
         this.handle = saga.performTutorialPopup(this.attach,this.msg,this.offset,this.location,this.useArrow,this.useButton,this.adjust,_loc2_);
         logger.info("Action_TutorialPopup.handleTriggerSceneLoaded created " + this.handle);
         if(def.instant)
         {
            end();
         }
      }
      
      private function tutorialClosedHandler(param1:int) : void
      {
         if(this.handle == param1)
         {
            end();
         }
      }
      
      public function getTooltipId() : int
      {
         return this.handle;
      }
   }
}

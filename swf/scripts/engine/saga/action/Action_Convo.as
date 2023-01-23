package engine.saga.action
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.resource.ConvoDefResource;
   import engine.resource.event.ResourceLoadedEvent;
   import engine.saga.Saga;
   import engine.saga.convo.Convo;
   import engine.saga.convo.ConvoEvent;
   import engine.saga.convo.def.ConvoDefVars;
   import engine.saga.convo.def.ConvoNodeDef;
   import engine.scene.model.Scene;
   import flash.errors.IllegalOperationError;
   
   public class Action_Convo extends Action
   {
       
      
      public var convo:Convo;
      
      private var res:ConvoDefResource;
      
      private var _url:String;
      
      public function Action_Convo(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
         ConvoNodeDef.war_risk_str = null;
         if(!param1.url)
         {
            throw new IllegalOperationError("No url for " + this);
         }
         this._url = this.processUrl(param1.url);
         if(this._url != param1.url)
         {
            logger.info("Action_Convo url [" + param1.url + "] processed to [" + this._url + "]");
         }
      }
      
      private function processUrl(param1:String) : String
      {
         var _loc2_:int = param1.indexOf("{");
         var _loc3_:int = _loc2_ >= 0 ? param1.indexOf("}",_loc2_) : -1;
         if(_loc2_ < 0 || _loc3_ < 0)
         {
            return param1;
         }
         var _loc4_:String = param1.substring(_loc2_,_loc3_);
         var _loc5_:int = _loc4_.indexOf(":");
         if(_loc5_ < 0)
         {
            throw new ArgumentError("missing token type [" + _loc4_ + "] in url [" + param1 + "]");
         }
         var _loc6_:String = _loc4_.substring(1,_loc5_);
         if(_loc6_ != "plat")
         {
            throw new ArgumentError("unknown token type [" + _loc6_ + "] in url [" + param1 + "]");
         }
         _loc4_ = _loc4_.substring(_loc5_ + 1);
         var _loc7_:Array = _loc4_.split(",");
         if(_loc7_.length == 0)
         {
            throw new ArgumentError("invalid token string [" + _loc4_ + "] in url [" + param1 + "]");
         }
         var _loc8_:String = PlatformInput.platformInputString;
         var _loc9_:String = param1.substring(0,_loc2_);
         var _loc10_:String = param1.substring(_loc3_ + 1);
         if(_loc7_.indexOf(_loc8_) < 0)
         {
            _loc8_ = _loc7_[_loc7_.length - 1];
         }
         if(_loc8_)
         {
            return _loc9_ + "_" + _loc8_ + _loc10_;
         }
         return _loc9_ + _loc10_;
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:Scene = null;
         if(def.type == ActionType.POPUP)
         {
            _loc1_ = saga.getScene();
            if(Boolean(_loc1_) && !_loc1_.ready)
            {
               logger.error("Poppening happened before scene was ready: " + this);
            }
         }
         paused = true;
         this.res = saga.resman.getResource(this._url,ConvoDefResource) as ConvoDefResource;
         this.res.addResourceListener(this.resHandler);
      }
      
      override protected function handleEnded() : void
      {
         if(this.convo)
         {
            this.convo.removeEventListener(ConvoEvent.FINISHED,this.convoFinishedHandler);
            this.convo = null;
         }
         if(this.res)
         {
            this.res.removeResourceListener(this.resHandler);
            this.res.release();
            this.res = null;
         }
      }
      
      private function resHandler(param1:ResourceLoadedEvent) : void
      {
         this.res.removeResourceListener(this.resHandler);
         if(!this.res.ok)
         {
            end();
            return;
         }
         this._showConvo();
      }
      
      private function _showConvo() : void
      {
         var _loc1_:ConvoDefVars = this.res.convoDef;
         if(def.type == ActionType.CONVO)
         {
            _loc1_.checkMarkless(saga.logger);
         }
         var _loc2_:String = def.scene;
         this.convo = new Convo(_loc1_,saga,saga.expression,saga._vars,saga,_loc2_,saga.logger);
         this.convo.poppening_top = def.poppening_top;
         this.convo.addEventListener(ConvoEvent.FINISHED,this.convoFinishedHandler);
         this.convo.start();
         if(def.type == ActionType.CONVO)
         {
            if(!_loc2_)
            {
               throw new ArgumentError("CONVO requires a scene!");
            }
            if(def.restore_scene && !def.instant)
            {
               this.sceneStateSave();
            }
            saga.performConversationStart(this.convo);
         }
         else
         {
            saga.performPoppening(this.convo,def.war);
         }
         if(def.instant)
         {
            end();
         }
      }
      
      public function convoFinishedHandler(param1:ConvoEvent) : void
      {
         this.convo = null;
         end();
      }
   }
}

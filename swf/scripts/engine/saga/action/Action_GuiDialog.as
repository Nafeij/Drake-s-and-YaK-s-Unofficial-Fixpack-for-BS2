package engine.saga.action
{
   import engine.saga.Saga;
   import engine.saga.happening.Happening;
   import flash.events.Event;
   
   public class Action_GuiDialog extends Action
   {
       
      
      private var _waitHappening:Happening;
      
      private var _buttons:Array;
      
      private var _happeningIds:Array;
      
      public function Action_GuiDialog(param1:ActionDef, param2:Saga)
      {
         this._buttons = [];
         this._happeningIds = [];
         super(param1,param2);
      }
      
      private function _parseButtonHappening(param1:Array, param2:Array) : void
      {
         var _loc3_:int = this._buttons.length;
         var _loc4_:String = param1.length > _loc3_ ? param1[_loc3_] : null;
         if(!_loc4_ && _loc3_ == 0)
         {
            _loc4_ = "$ok";
         }
         var _loc5_:String = param2.length > _loc3_ ? param2[_loc3_] : null;
         _loc4_ = translateMsg(_loc4_);
         this._buttons.push(_loc4_);
         this._happeningIds.push(_loc5_);
      }
      
      override protected function handleStarted() : void
      {
         paused = true;
         var _loc1_:String = def.speaker;
         _loc1_ = translateMsg(_loc1_);
         if(_loc1_ == null)
         {
            _loc1_ = "";
         }
         var _loc2_:String = def.msg;
         _loc2_ = translateMsg(_loc2_);
         _loc2_ = saga.performStringReplacement_SagaVar(_loc2_);
         var _loc3_:String = def.param;
         var _loc4_:String = def.anchor;
         var _loc5_:Array = !!_loc3_ ? _loc3_.split(",") : [];
         var _loc6_:Array = !!_loc4_ ? _loc4_.split(",") : [];
         if(_loc5_.length > 0)
         {
            this._parseButtonHappening(_loc5_,_loc6_);
            if(_loc5_.length > 1)
            {
               this._parseButtonHappening(_loc5_,_loc6_);
            }
         }
         saga.performGuiDialog(_loc1_,_loc2_,this._buttons[0],this._buttons[1],this.dialogClosedHandler);
      }
      
      private function findHappeningIdForButtonString(param1:String) : String
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._buttons.length)
         {
            if(param1 == this._buttons[_loc2_])
            {
               return this._happeningIds[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      private function dialogClosedHandler(param1:String) : void
      {
         var _loc2_:String = this.findHappeningIdForButtonString(param1);
         if(_loc2_)
         {
            this._waitHappening = saga.executeHappeningById(_loc2_,null,this) as Happening;
            if(!def.instant)
            {
               if(this._waitHappening)
               {
                  if(!this._waitHappening.ended)
                  {
                     this._waitHappening.addEventListener(Event.COMPLETE,this.happeningCompleteHandler);
                     return;
                  }
               }
            }
         }
         end();
      }
      
      private function happeningCompleteHandler(param1:Event) : void
      {
         end();
      }
      
      override public function fastForward() : Boolean
      {
         saga.performClearGuiDialog();
         return true;
      }
   }
}

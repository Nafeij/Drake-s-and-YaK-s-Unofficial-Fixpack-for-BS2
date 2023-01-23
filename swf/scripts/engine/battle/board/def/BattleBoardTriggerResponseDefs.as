package engine.battle.board.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BattleBoardTriggerResponseDefs extends EventDispatcher
   {
      
      public static const EVENT_PULSE:String = "BattleBoardTriggerResponseDefs.EVENT_PULSE";
      
      public static var WITH_EVENTS:Boolean;
       
      
      public var responses:Vector.<BattleBoardTriggerResponseDef>;
      
      private var _pulse:Boolean;
      
      public function BattleBoardTriggerResponseDefs()
      {
         this.responses = new Vector.<BattleBoardTriggerResponseDef>();
         super();
      }
      
      public function get pulse() : Boolean
      {
         return this._pulse;
      }
      
      public function set pulse(param1:Boolean) : void
      {
         if(param1 == this._pulse)
         {
            return;
         }
         this._pulse = param1;
         if(WITH_EVENTS)
         {
            dispatchEvent(new Event(EVENT_PULSE));
         }
      }
      
      override public function toString() : String
      {
         var _loc1_:String = "";
         return _loc1_ + (!!this.responses ? this.responses.join(", ") : "[NO RESPONSES]");
      }
      
      public function get hasResponseDefs() : Boolean
      {
         return Boolean(this.responses) && Boolean(this.responses.length);
      }
      
      public function hasResponseDef(param1:BattleBoardTriggerResponseDef) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         return this.responses.indexOf(param1) >= 0;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : BattleBoardTriggerResponseDefs
      {
         var vars:Object = param1;
         var logger:ILogger = param2;
         var va:Array = vars as Array;
         if(!va)
         {
            throw new ArgumentError("nope");
         }
         this.responses = ArrayUtil.arrayToDefVector(va,BattleBoardTriggerResponseDef,logger,this.responses) as Vector.<BattleBoardTriggerResponseDef>;
         if(WITH_EVENTS)
         {
            ArrayUtil.visit(this.responses,function(param1:BattleBoardTriggerResponseDef):void
            {
               param1.addEventListener(BattleBoardTriggerResponseDef.EVENT_PULSE,pulseHandler);
            });
         }
         this._computePulse();
         return this;
      }
      
      public function toJson() : Object
      {
         if(this.responses)
         {
            return ArrayUtil.defVectorToArray(this.responses,true);
         }
         return [];
      }
      
      private function pulseHandler(param1:Event) : void
      {
         this._computePulse();
      }
      
      public function addResponse(param1:BattleBoardTriggerResponseDef) : void
      {
         if(!this.responses)
         {
            this.responses = new Vector.<BattleBoardTriggerResponseDef>();
         }
         this.responses.push(param1);
         if(WITH_EVENTS)
         {
            param1.addEventListener(BattleBoardTriggerResponseDef.EVENT_PULSE,this.pulseHandler);
         }
         this.pulse = this.pulse || param1.pulse;
      }
      
      public function removeResponse(param1:BattleBoardTriggerResponseDef) : void
      {
         param1.removeEventListener(BattleBoardTriggerResponseDef.EVENT_PULSE,this.pulseHandler);
         var _loc2_:int = this.responses.indexOf(param1);
         if(_loc2_ >= 0)
         {
            ArrayUtil.removeAt(this.responses,_loc2_);
            this._computePulse();
         }
      }
      
      private function _computePulse() : void
      {
         var _loc1_:BattleBoardTriggerResponseDef = null;
         if(this.responses)
         {
            for each(_loc1_ in this.responses)
            {
               if(_loc1_.pulse)
               {
                  this.pulse = true;
                  return;
               }
            }
         }
         this.pulse = false;
      }
   }
}

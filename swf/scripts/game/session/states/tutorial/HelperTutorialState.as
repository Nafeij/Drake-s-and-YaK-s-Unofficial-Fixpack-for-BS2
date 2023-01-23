package game.session.states.tutorial
{
   import engine.core.fsm.Fsm;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   import game.view.TutorialTooltip;
   
   public class HelperTutorialState
   {
       
      
      private var _index:int = -1;
      
      private var _mode:Function;
      
      private var _modes:Array;
      
      private var fsm:Fsm;
      
      private var _state:GameState;
      
      private var _tt:TutorialTooltip;
      
      public var logger:ILogger;
      
      public function HelperTutorialState(param1:GameState, param2:Array)
      {
         super();
         this.fsm = param1.fsm;
         this._modes = param2;
         this._state = param1;
         this.logger = this.fsm.logger;
      }
      
      public function get isActive() : Boolean
      {
         return this._mode != null;
      }
      
      public function cleanup() : void
      {
         this.clearToolTip();
         this._mode = null;
         this._modes = null;
         this._state = null;
      }
      
      public function get mode() : Function
      {
         return this._mode;
      }
      
      public function toString() : String
      {
         return this._state.toString();
      }
      
      public function next(param1:Object) : void
      {
         if(!this._modes)
         {
            return;
         }
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("^^^^ HelperTutorialState.next " + this + " with cur = " + param1);
         }
         if(this.fsm.current != this._state)
         {
            return;
         }
         if(param1 && this._index >= 0 && this._index < this._modes.length && param1 != this._modes[this._index])
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("^^^^ HelperTutorialState.next " + this + " bailing out with wrong mode ");
            }
            return;
         }
         ++this._index;
         if(this._index < this._modes.length)
         {
            this._mode = this._modes[this._index];
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("^^^^ HelperTutorialState.next " + this + " _mode set to" + this._mode);
            }
         }
         else
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("^^^^ HelperTutorialState.next " + this + " _mode set to null");
            }
            this._mode = null;
         }
         if(this._mode != null)
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("^^^^ HelperTutorialState.next " + this + " calling _mode");
            }
            this._mode(this._mode);
         }
         else
         {
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("^^^^ HelperTutorialState.next " + this + " _mode is null");
            }
            this.tt = null;
         }
      }
      
      public function get tt() : TutorialTooltip
      {
         return this._tt;
      }
      
      public function set tt(param1:TutorialTooltip) : void
      {
         if(this._tt == param1)
         {
            return;
         }
         if(this._tt)
         {
            this._tt.layer.removeTooltip(this._tt);
            this._tt = null;
         }
         this._tt = param1;
         if(!this._tt)
         {
         }
      }
      
      public function clearToolTip() : void
      {
         if(this._tt != null)
         {
            this._tt.layer.removeTooltip(this._tt);
            this._tt = null;
         }
      }
   }
}

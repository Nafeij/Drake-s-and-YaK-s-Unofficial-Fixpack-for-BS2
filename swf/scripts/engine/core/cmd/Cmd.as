package engine.core.cmd
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class Cmd extends EventDispatcher
   {
      
      public static const EVENT_ENABLED_CHANGED:String = "EVENT_ENABLED_CHANGED";
      
      public static const EVENT_TOGGLED_CHANGED:String = "EVENT_TOGGLED_CHANGED";
       
      
      public var name:String;
      
      public var func:Function;
      
      public var config;
      
      public var undoable:Boolean = false;
      
      private var _enabled:Boolean = true;
      
      public var toggle:Boolean;
      
      public var global:Boolean;
      
      public var cheat:Boolean;
      
      public var hotkey:int;
      
      public var _toggled:Boolean;
      
      public var isShell:Boolean;
      
      public function Cmd(param1:String, param2:Function, param3:* = null, param4:Boolean = false, param5:Boolean = true, param6:Boolean = false)
      {
         super();
         this.name = param1;
         this.func = param2;
         this.config = param3;
         this.undoable = param4;
         this.enabled = param5;
         this.toggle = param6;
      }
      
      public function setHotkey(param1:int) : Cmd
      {
         this.hotkey = param1;
         return this;
      }
      
      public function cleanup() : void
      {
         this.func = null;
         this.config = null;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         dispatchEvent(new Event(EVENT_ENABLED_CHANGED));
      }
      
      public function get disabled() : Boolean
      {
         return !this._enabled;
      }
      
      public function set disabled(param1:Boolean) : void
      {
         this.enabled = !param1;
      }
      
      override public function toString() : String
      {
         return this.name + (!this._enabled ? " Disabled" : "") + (this.global ? " Global" : "") + (!!this.config ? " c=" + this.config : "");
      }
      
      public function get toggled() : Boolean
      {
         return this._toggled;
      }
      
      public function set toggled(param1:Boolean) : void
      {
         if(this._toggled == param1)
         {
            return;
         }
         this._toggled = param1;
         dispatchEvent(new Event(EVENT_TOGGLED_CHANGED));
      }
   }
}

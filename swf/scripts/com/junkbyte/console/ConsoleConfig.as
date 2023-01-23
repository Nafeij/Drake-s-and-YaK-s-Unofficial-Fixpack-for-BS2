package com.junkbyte.console
{
   import flash.utils.getQualifiedClassName;
   
   public class ConsoleConfig
   {
       
      
      public var keystrokePassword:String;
      
      public var remotingPassword:String;
      
      public var maxLines:uint = 1000;
      
      public var maxRepeats:int = 75;
      
      public var autoStackPriority:int = 10;
      
      public var defaultStackDepth:int = 2;
      
      public var useObjectLinking:Boolean = true;
      
      public var objectHardReferenceTimer:uint = 0;
      
      public var tracing:Boolean;
      
      public var traceCall:Function;
      
      public var showTimestamp:Boolean = false;
      
      public var timeStampFormatter:Function;
      
      public var showLineNumber:Boolean = false;
      
      private var _stackIgnoredExp:RegExp;
      
      public var remotingConnectionName:String = "_Console";
      
      public var allowedRemoteDomain:String = "*";
      
      public var commandLineAllowed:Boolean;
      
      public var commandLineAutoScope:Boolean;
      
      public var commandLineInputPassThrough:Function;
      
      public var commandLineAutoCompleteEnabled:Boolean = true;
      
      public var keyBindsEnabled:Boolean = true;
      
      public var displayRollerEnabled:Boolean = true;
      
      public var sharedObjectName:String = "com.junkbyte/Console/UserData";
      
      public var sharedObjectPath:String = "/";
      
      public var rememberFilterSettings:Boolean;
      
      public var alwaysOnTop:Boolean = true;
      
      private var _style:ConsoleStyle;
      
      public function ConsoleConfig()
      {
         this.traceCall = function(param1:String, param2:String, ... rest):void
         {
            trace("[" + param1 + "] " + param2);
         };
         this.timeStampFormatter = function(param1:uint):String
         {
            var _loc2_:uint = param1 * 0.001;
            return this.makeTimeDigit(_loc2_ / 60) + ":" + this.makeTimeDigit(_loc2_ % 60);
         };
         this._stackIgnoredExp = new RegExp("Function|" + this.addDotSlash(getQualifiedClassName(Console)) + "|" + this.addDotSlash(getQualifiedClassName(Cc)));
         super();
         this._style = new ConsoleStyle();
      }
      
      private function makeTimeDigit(param1:uint) : String
      {
         if(param1 < 10)
         {
            return "0" + param1;
         }
         return String(param1);
      }
      
      public function get stackTraceIgnoreExpression() : RegExp
      {
         return this._stackIgnoredExp;
      }
      
      public function addStackTraceIgnoreClass(param1:Class) : void
      {
         var _loc2_:String = "|" + this.addDotSlash(getQualifiedClassName(param1));
         var _loc3_:String = this._stackIgnoredExp.source;
         var _loc4_:int = _loc3_.indexOf(_loc2_);
         var _loc5_:int = _loc4_ + _loc2_.length;
         if(_loc4_ < 0 || _loc5_ < _loc3_.length && _loc3_.charAt(_loc5_) != "|")
         {
            _loc3_ += _loc2_;
            this._stackIgnoredExp = new RegExp(_loc3_ + _loc2_);
         }
      }
      
      private function addDotSlash(param1:String) : String
      {
         return param1.replace(/\./g,"\\.");
      }
      
      public function get style() : ConsoleStyle
      {
         return this._style;
      }
   }
}

package com.google.analytics.data
{
   import com.google.analytics.utils.Timespan;
   
   public class UTMA extends UTMCookie
   {
       
      
      private var _domainHash:Number;
      
      private var _sessionId:Number;
      
      private var _firstTime:Number;
      
      private var _lastTime:Number;
      
      private var _currentTime:Number;
      
      private var _sessionCount:Number;
      
      public function UTMA(param1:Number = NaN, param2:Number = NaN, param3:Number = NaN, param4:Number = NaN, param5:Number = NaN, param6:Number = NaN)
      {
         super("utma","__utma",["domainHash","sessionId","firstTime","lastTime","currentTime","sessionCount"],Timespan.twoyears * 1000);
         this.domainHash = param1;
         this.sessionId = param2;
         this.firstTime = param3;
         this.lastTime = param4;
         this.currentTime = param5;
         this.sessionCount = param6;
      }
      
      public function get domainHash() : Number
      {
         return this._domainHash;
      }
      
      public function set domainHash(param1:Number) : void
      {
         this._domainHash = param1;
         update();
      }
      
      public function get sessionId() : Number
      {
         return this._sessionId;
      }
      
      public function set sessionId(param1:Number) : void
      {
         this._sessionId = param1;
         update();
      }
      
      public function get firstTime() : Number
      {
         return this._firstTime;
      }
      
      public function set firstTime(param1:Number) : void
      {
         this._firstTime = param1;
         update();
      }
      
      public function get lastTime() : Number
      {
         return this._lastTime;
      }
      
      public function set lastTime(param1:Number) : void
      {
         this._lastTime = param1;
         update();
      }
      
      public function get currentTime() : Number
      {
         return this._currentTime;
      }
      
      public function set currentTime(param1:Number) : void
      {
         this._currentTime = param1;
         update();
      }
      
      public function get sessionCount() : Number
      {
         return this._sessionCount;
      }
      
      public function set sessionCount(param1:Number) : void
      {
         this._sessionCount = param1;
         update();
      }
   }
}

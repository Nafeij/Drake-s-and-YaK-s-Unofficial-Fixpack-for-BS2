package com.google.analytics.core
{
   import com.google.analytics.data.X10;
   import com.google.analytics.utils.Variables;
   
   public class EventInfo
   {
       
      
      private var _isEventHit:Boolean;
      
      private var _x10:X10;
      
      private var _ext10:X10;
      
      public function EventInfo(param1:Boolean, param2:X10, param3:X10 = null)
      {
         super();
         this._isEventHit = param1;
         this._x10 = param2;
         this._ext10 = param3;
      }
      
      public function get utmt() : String
      {
         return "event";
      }
      
      public function get utme() : String
      {
         return this._x10.renderMergedUrlString(this._ext10);
      }
      
      public function toVariables() : Variables
      {
         var _loc1_:Variables = new Variables();
         _loc1_.URIencode = true;
         if(this._isEventHit)
         {
            _loc1_.utmt = this.utmt;
         }
         _loc1_.utme = this.utme;
         return _loc1_;
      }
      
      public function toURLString() : String
      {
         var _loc1_:Variables = this.toVariables();
         return _loc1_.toString();
      }
   }
}

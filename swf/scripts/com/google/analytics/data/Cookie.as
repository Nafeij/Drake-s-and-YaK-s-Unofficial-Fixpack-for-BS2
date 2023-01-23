package com.google.analytics.data
{
   public interface Cookie
   {
       
      
      function get creation() : Date;
      
      function set creation(param1:Date) : void;
      
      function get expiration() : Date;
      
      function set expiration(param1:Date) : void;
      
      function isExpired() : Boolean;
      
      function toURLString() : String;
      
      function fromSharedObject(param1:Object) : void;
      
      function toSharedObject() : Object;
   }
}

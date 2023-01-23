package com.google.analytics.campaign
{
   import com.google.analytics.utils.Variables;
   
   public class CampaignInfo
   {
       
      
      private var _empty:Boolean;
      
      private var _new:Boolean;
      
      public function CampaignInfo(param1:Boolean = true, param2:Boolean = false)
      {
         super();
         this._empty = param1;
         this._new = param2;
      }
      
      public function get utmcn() : String
      {
         return "1";
      }
      
      public function get utmcr() : String
      {
         return "1";
      }
      
      public function isEmpty() : Boolean
      {
         return this._empty;
      }
      
      public function isNew() : Boolean
      {
         return this._new;
      }
      
      public function toVariables() : Variables
      {
         var _loc1_:Variables = new Variables();
         _loc1_.URIencode = true;
         if(!this.isEmpty() && this.isNew())
         {
            _loc1_.utmcn = this.utmcn;
         }
         if(!this.isEmpty() && !this.isNew())
         {
            _loc1_.utmcr = this.utmcr;
         }
         return _loc1_;
      }
      
      public function toURLString() : String
      {
         var _loc1_:Variables = this.toVariables();
         return _loc1_.toString();
      }
   }
}
